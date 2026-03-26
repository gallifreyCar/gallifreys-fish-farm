import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fish.dart';
import '../models/player.dart';
import '../models/achievement.dart';
import '../models/daily_quest.dart';
import '../utils/fish_data.dart';
import '../utils/constants.dart';

/// 游戏状态
class GameState {
  final Player player;
  final bool isFishing;
  final Fish? lastCaughtFish;
  final String? notification;
  final Map<String, AchievementProgress> achievementProgress;
  final DailyQuestData dailyQuests;

  // 缓存计算结果，避免重复计算
  int? _cachedIncomePerSecond;
  int? _cachedTotalPower;

  GameState({
    required this.player,
    this.isFishing = true,
    this.lastCaughtFish,
    this.notification,
    Map<String, AchievementProgress>? achievementProgress,
    DailyQuestData? dailyQuests,
  }) : achievementProgress = achievementProgress ?? _initAchievements(),
       dailyQuests = dailyQuests ?? DailyQuestData.generate(DateTime.now());

  /// 初始化成就进度
  static Map<String, AchievementProgress> _initAchievements() {
    return {
      for (final a in Achievement.allAchievements)
        a.id: AchievementProgress(achievementId: a.id)
    };
  }

  /// 缓存的每秒收入
  int get incomePerSecond {
    return _cachedIncomePerSecond ??= player.incomePerSecond;
  }

  /// 缓存的总战力
  int get totalPower {
    if (_cachedTotalPower != null) return _cachedTotalPower!;
    _cachedTotalPower = player.ownedFish.fold<int>(0, (sum, fish) => sum + fish.power);
    return _cachedTotalPower!;
  }

  /// 获取已完成的成就数量
  int get completedAchievements {
    return achievementProgress.values.where((p) => p.isCompleted).length;
  }

  /// 获取可领取的成就数量
  int get claimableAchievements {
    return achievementProgress.values.where((p) => p.isCompleted && !p.isClaimed).length;
  }

  /// 获取可领取的每日任务数量
  int get claimableDailyQuests {
    return dailyQuests.claimableCount;
  }

  GameState copyWith({
    Player? player,
    bool? isFishing,
    Fish? lastCaughtFish,
    String? notification,
    Map<String, AchievementProgress>? achievementProgress,
    DailyQuestData? dailyQuests,
    bool clearNotification = false,
    bool clearLastCaughtFish = false,
  }) {
    return GameState(
      player: player ?? this.player,
      isFishing: isFishing ?? this.isFishing,
      lastCaughtFish: clearLastCaughtFish ? null : (lastCaughtFish ?? this.lastCaughtFish),
      notification: clearNotification ? null : (notification ?? this.notification),
      achievementProgress: achievementProgress ?? this.achievementProgress,
      dailyQuests: dailyQuests ?? this.dailyQuests,
    );
  }
}

/// 游戏控制器
class GameNotifier extends StateNotifier<GameState> {
  Timer? _fishingTimer;
  Timer? _incomeTimer;
  Timer? _saveTimer;
  final void Function(Map<String, dynamic>)? onSave;

  GameNotifier({
    Player? player,
    this.onSave,
  }) : super(GameState(player: player ?? Player())) {
    _startGameLoop();
  }

  /// 开始游戏循环
  void _startGameLoop() {
    // 收入计时器（每秒结算）
    _incomeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _collectIncome();
    });

    // 钓鱼计时器
    _startFishing();

    // 自动保存（每30秒）
    _saveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _autoSave();
    });
  }

  /// 开始钓鱼
  void _startFishing() {
    _fishingTimer?.cancel();
    final interval = Duration(
      seconds: (GameConstants.baseFishingIntervalSeconds / state.player.equipment.fishingSpeedBonus).round(),
    );
    _fishingTimer = Timer.periodic(interval, (_) {
      _catchFish();
    });
  }

  /// 钓鱼
  void _catchFish() {
    if (!state.isFishing) return;
    if (state.player.isPondFull) {
      state = state.copyWith(
        notification: '鱼池已满！请出售一些鱼或升级鱼池。',
      );
      return;
    }

    final template = FishData.getRandomFish(state.player.equipment.rareFishBonus);
    final fish = template.createFish();

    final newPlayer = Player(
      coins: state.player.coins,
      fishFood: state.player.fishFood,
      ownedFish: [...state.player.ownedFish, fish],
      equipment: state.player.equipment,
      lastSaveTime: DateTime.now(),
      totalFishCaught: state.player.totalFishCaught + 1,
    );

    // 更新成就进度
    final newProgress = Map<String, AchievementProgress>.from(state.achievementProgress);

    // 钓鱼成就
    _updateAchievementProgress(newProgress, 'first_catch', newPlayer.totalFishCaught);
    _updateAchievementProgress(newProgress, 'fisherman_100', newPlayer.totalFishCaught);
    _updateAchievementProgress(newProgress, 'fisherman_1000', newPlayer.totalFishCaught);

    // 收集成就
    _updateCollectionAchievements(newProgress, newPlayer.ownedFish);

    // 更新每日任务进度
    final newDailyQuests = _updateDailyQuestProgress(DailyQuestType.fishing, 1);

    state = state.copyWith(
      player: newPlayer,
      lastCaughtFish: fish,
      notification: '钓到了 ${fish.emoji} ${fish.name}！',
      achievementProgress: newProgress,
      dailyQuests: newDailyQuests,
    );
  }

  /// 更新成就进度
  void _updateAchievementProgress(Map<String, AchievementProgress> progress, String achievementId, int value) {
    final achievement = Achievement.allAchievements.firstWhere((a) => a.id == achievementId);
    final current = progress[achievementId]!;
    if (current.isCompleted) return;

    progress[achievementId] = current.copyWith(
      currentValue: value,
      isCompleted: value >= achievement.targetValue,
    );
  }

  /// 更新收集类成就
  void _updateCollectionAchievements(Map<String, AchievementProgress> progress, List<Fish> fish) {
    // 拥有鱼数量
    _updateAchievementProgress(progress, 'collector_10', fish.length);

    // 稀有及以上数量
    final rareOrBetter = fish.where((f) =>
      f.rarity == Rarity.rare ||
      f.rarity == Rarity.epic ||
      f.rarity == Rarity.legendary
    ).length;
    _updateAchievementProgress(progress, 'rare_collector', rareOrBetter);

    // 传说数量
    final legendary = fish.where((f) => f.rarity == Rarity.legendary).length;
    _updateAchievementProgress(progress, 'legendary_collector', legendary);
  }

  /// 领取成就奖励
  bool claimAchievement(String achievementId) {
    final progress = state.achievementProgress[achievementId];
    if (progress == null || !progress.isCompleted || progress.isClaimed) return false;

    final achievement = Achievement.allAchievements.firstWhere((a) => a.id == achievementId);

    // 发放奖励
    final newPlayer = Player(
      coins: state.player.coins + achievement.rewardCoins,
      fishFood: state.player.fishFood + achievement.rewardFishFood,
      ownedFish: state.player.ownedFish,
      equipment: state.player.equipment,
      lastSaveTime: state.player.lastSaveTime,
      totalFishCaught: state.player.totalFishCaught,
    );

    // 标记已领取
    final newProgress = Map<String, AchievementProgress>.from(state.achievementProgress);
    newProgress[achievementId] = progress.copyWith(isClaimed: true);

    state = state.copyWith(
      player: newPlayer,
      notification: '🎉 成就【${achievement.name}】奖励已领取！',
      achievementProgress: newProgress,
    );

    return true;
  }

  /// 更新每日任务进度
  DailyQuestData _updateDailyQuestProgress(DailyQuestType type, int value) {
    var dailyQuests = DailyQuestData.getToday(state.dailyQuests);
    final newProgress = Map<String, DailyQuestProgress>.from(dailyQuests.progress);

    for (final quest in dailyQuests.quests) {
      if (quest.type != type) continue;
      final current = newProgress[quest.id]!;
      if (current.isCompleted) continue;

      final newValue = current.currentValue + value;
      newProgress[quest.id] = current.copyWith(
        currentValue: newValue,
        isCompleted: newValue >= quest.targetValue,
      );
    }

    return dailyQuests.copyWith(progress: newProgress);
  }

  /// 领取每日任务奖励
  bool claimDailyQuest(String questId) {
    var dailyQuests = DailyQuestData.getToday(state.dailyQuests);
    final progress = dailyQuests.progress[questId];
    if (progress == null || !progress.isCompleted || progress.isClaimed) return false;

    final quest = dailyQuests.quests.firstWhere((q) => q.id == questId);

    // 发放奖励
    final newPlayer = Player(
      coins: state.player.coins + quest.rewardCoins,
      fishFood: state.player.fishFood + quest.rewardFishFood,
      ownedFish: state.player.ownedFish,
      equipment: state.player.equipment,
      lastSaveTime: state.player.lastSaveTime,
      totalFishCaught: state.player.totalFishCaught,
    );

    // 标记已领取
    final newProgress = Map<String, DailyQuestProgress>.from(dailyQuests.progress);
    newProgress[questId] = progress.copyWith(isClaimed: true);
    dailyQuests = dailyQuests.copyWith(progress: newProgress);

    state = state.copyWith(
      player: newPlayer,
      notification: '✅ 每日任务【${quest.name}】完成！',
      dailyQuests: dailyQuests,
    );

    return true;
  }

  /// 融合鱼宠（3条相同稀有度的鱼融合成1条更高稀有度的鱼）
  FusionResult? fuseFish(List<String> fishIds) {
    if (fishIds.length != 3) return null;

    // 获取要融合的鱼
    final fishToFuse = fishIds.map((id) =>
      state.player.ownedFish.firstWhere((f) => f.id == id, orElse: () => throw Exception('鱼不存在'))
    ).toList();

    // 检查是否同稀有度
    final rarity = fishToFuse.first.rarity;
    if (!fishToFuse.every((f) => f.rarity == rarity)) {
      return FusionResult(success: false, message: '只能融合相同稀有度的鱼！');
    }

    // 检查是否已达最高稀有度
    if (rarity == Rarity.legendary) {
      return FusionResult(success: false, message: '传说鱼无法继续融合！');
    }

    // 计算新稀有度
    final newRarity = Rarity.values[rarity.index + 1];

    // 找到对应稀有度的鱼模板
    final templates = FishData.allFish.where((f) => f.rarity == newRarity).toList();
    if (templates.isEmpty) {
      return FusionResult(success: false, message: '没有可融合的目标！');
    }

    // 随机选择一个目标鱼
    final random = DateTime.now().millisecondsSinceEpoch % templates.length;
    final newFish = templates[random].createFish();

    // 继承等级（取最高等级+1）
    newFish.level = fishToFuse.map((f) => f.level).reduce((a, b) => a > b ? a : b) + 1;

    // 移除被融合的鱼
    final newOwnedFish = state.player.ownedFish
        .where((f) => !fishIds.contains(f.id))
        .toList();
    newOwnedFish.add(newFish);

    // 更新玩家数据
    final newPlayer = Player(
      coins: state.player.coins,
      fishFood: state.player.fishFood,
      ownedFish: newOwnedFish,
      equipment: state.player.equipment,
      lastSaveTime: DateTime.now(),
      totalFishCaught: state.player.totalFishCaught,
    );

    // 更新收集成就
    final newProgress = Map<String, AchievementProgress>.from(state.achievementProgress);
    _updateCollectionAchievements(newProgress, newOwnedFish);

    state = state.copyWith(
      player: newPlayer,
      notification: '✨ 融合成功！获得 ${newFish.emoji} ${newFish.name}！',
      achievementProgress: newProgress,
    );

    return FusionResult(
      success: true,
      message: '融合成功！',
      newFish: newFish,
    );
  }

  /// 收集收入
  void _collectIncome() {
    final income = state.player.incomePerSecond;
    if (income <= 0) return;

    state = state.copyWith(
      player: Player(
        coins: state.player.coins + income,
        fishFood: state.player.fishFood,
        ownedFish: state.player.ownedFish,
        equipment: state.player.equipment,
        lastSaveTime: DateTime.now(),
        totalFishCaught: state.player.totalFishCaught,
      ),
    );
  }

  /// 切换钓鱼状态
  void toggleFishing() {
    state = state.copyWith(isFishing: !state.isFishing);
  }

  /// 指派工作
  void assignJob(String fishId, JobType job) {
    final fishIndex = state.player.ownedFish.indexWhere((f) => f.id == fishId);
    if (fishIndex == -1) return;

    final fish = state.player.ownedFish[fishIndex];
    fish.currentJob = job;

    state = state.copyWith(player: state.player);
  }

  /// 喂食鱼
  bool feedFish(String fishId) {
    if (state.player.fishFood <= 0) return false;

    final fishIndex = state.player.ownedFish.indexWhere((f) => f.id == fishId);
    if (fishIndex == -1) return false;

    final fish = state.player.ownedFish[fishIndex];
    fish.addExp(20);
    state.player.fishFood--;

    state = state.copyWith(player: state.player);
    return true;
  }

  /// 出售鱼
  void sellFish(String fishId) {
    final price = state.player.sellFish(fishId);
    if (price > 0) {
      state = state.copyWith(
        player: state.player,
        notification: '出售成功！获得 $price 金币',
      );
    }
  }

  /// 升级鱼竿
  bool upgradeRod() {
    final cost = state.player.equipment.rodUpgradeCost;
    if (state.player.coins < cost) return false;

    state.player.coins -= cost;
    state.player.equipment.rodLevel++;
    state = state.copyWith(player: state.player);
    _startFishing(); // 重新计算钓鱼速度
    return true;
  }

  /// 升级鱼饵
  bool upgradeBait() {
    final cost = state.player.equipment.baitUpgradeCost;
    if (state.player.coins < cost) return false;

    state.player.coins -= cost;
    state.player.equipment.baitLevel++;
    state = state.copyWith(player: state.player);
    return true;
  }

  /// 升级鱼池
  bool upgradePond() {
    final cost = state.player.equipment.pondUpgradeCost;
    if (state.player.coins < cost) return false;

    state.player.coins -= cost;
    state.player.equipment.pondLevel++;
    state = state.copyWith(player: state.player);
    return true;
  }

  /// 清除通知
  void clearNotification() {
    state = state.copyWith(clearNotification: true);
  }

  /// 清除最后钓到的鱼
  void clearLastCaughtFish() {
    state = state.copyWith(clearLastCaughtFish: true);
  }

  /// 自动保存
  void _autoSave() {
    state.player.lastSaveTime = DateTime.now();
    onSave?.call(state.player.toJson());
  }

  /// 手动保存
  void save() {
    _autoSave();
  }

  /// 计算离线收益
  void calculateOfflineIncome() {
    final now = DateTime.now();
    final lastSave = state.player.lastSaveTime;
    final offlineSeconds = now.difference(lastSave).inSeconds;
    final maxOfflineSeconds = GameConstants.offlineIncomeCapHours * 3600;

    final effectiveSeconds = offlineSeconds.clamp(0, maxOfflineSeconds);
    final offlineIncome = state.player.incomePerSecond * effectiveSeconds;

    if (offlineIncome > 0) {
      state.player.coins += offlineIncome;
      state = state.copyWith(
        player: state.player,
        notification: '离线收益：$offlineIncome 金币',
      );
    }
  }

  @override
  void dispose() {
    _fishingTimer?.cancel();
    _incomeTimer?.cancel();
    _saveTimer?.cancel();
    super.dispose();
  }
}

/// 融合结果
class FusionResult {
  final bool success;
  final String message;
  final Fish? newFish;

  FusionResult({
    required this.success,
    required this.message,
    this.newFish,
  });
}

/// 游戏Provider
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});

/// 细粒度选择器 - 仅当金币变化时重建
final coinsProvider = Provider<int>((ref) {
  return ref.watch(gameProvider.select((state) => state.player.coins));
});

/// 细粒度选择器 - 仅当鱼数量变化时重建
final fishCountProvider = Provider<int>((ref) {
  return ref.watch(gameProvider.select((state) => state.player.ownedFish.length));
});

/// 细粒度选择器 - 仅当收入变化时重建
final incomeProvider = Provider<int>((ref) {
  return ref.watch(gameProvider.select((state) => state.incomePerSecond));
});

/// 细粒度选择器 - 仅当钓鱼状态变化时重建
final isFishingProvider = Provider<bool>((ref) {
  return ref.watch(gameProvider.select((state) => state.isFishing));
});

/// 细粒度选择器 - 通知消息
final notificationProvider = Provider<String?>((ref) {
  return ref.watch(gameProvider.select((state) => state.notification));
});

/// 细粒度选择器 - 成就进度
final achievementsProvider = Provider<Map<String, AchievementProgress>>((ref) {
  return ref.watch(gameProvider.select((state) => state.achievementProgress));
});

/// 细粒度选择器 - 可领取成就数量
final claimableAchievementsProvider = Provider<int>((ref) {
  return ref.watch(gameProvider.select((state) => state.claimableAchievements));
});
