import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fish.dart';
import '../models/player.dart';
import '../models/achievement.dart';
import '../models/daily_quest.dart';
import '../models/equipment.dart';
import '../models/prestige.dart';
import '../models/game_event.dart';
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
  final EventData eventData;

  // 缓存计算结果，避免重复计算
  int? _cachedIncomePerSecond;
  int? _cachedTotalPower;
  List<GameEvent>? _cachedActiveEvents;

  GameState({
    required this.player,
    this.isFishing = true,
    this.lastCaughtFish,
    this.notification,
    Map<String, AchievementProgress>? achievementProgress,
    DailyQuestData? dailyQuests,
    EventData? eventData,
  }) : achievementProgress = achievementProgress ?? _initAchievementsFromPlayer(player),
       dailyQuests = dailyQuests ?? DailyQuestData.generate(DateTime.now()),
       eventData = eventData ?? EventData();

  /// 从 Player 加载成就进度，如果没有则初始化
  static Map<String, AchievementProgress> _initAchievementsFromPlayer(Player player) {
    if (player.achievementProgress != null) {
      // 从存档加载
      final saved = player.achievementProgress!;
      return {
        for (final a in Achievement.allAchievements)
          a.id: saved[a.id] != null
              ? AchievementProgress.fromJson(saved[a.id] as Map<String, dynamic>)
              : AchievementProgress(achievementId: a.id)
      };
    }
    // 新游戏初始化
    return _initAchievements();
  }

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

  /// 获取当前活跃的活动
  List<GameEvent> get activeEvents {
    return _cachedActiveEvents ??= EventManager.getActiveEvents(eventData.customEvents);
  }

  /// 获取活动收入加成
  double get eventIncomeMultiplier {
    return EventManager.getIncomeMultiplier(activeEvents);
  }

  /// 获取活动经验加成
  double get eventExpMultiplier {
    return EventManager.getExpMultiplier(activeEvents);
  }

  /// 获取Boss奖励加成
  double get eventBossRewardMultiplier {
    return EventManager.getBossRewardMultiplier(activeEvents);
  }

  GameState copyWith({
    Player? player,
    bool? isFishing,
    Fish? lastCaughtFish,
    String? notification,
    Map<String, AchievementProgress>? achievementProgress,
    DailyQuestData? dailyQuests,
    EventData? eventData,
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
      eventData: eventData ?? this.eventData,
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
    _scheduleNextFishing();
  }

  /// 调度下一次钓鱼（带随机抖动）
  void _scheduleNextFishing() {
    final baseInterval = GameConstants.baseFishingIntervalSeconds / state.player.equipment.fishingSpeedBonus;
    // 添加 ±30% 随机抖动
    final jitter = baseInterval * 0.3 * (DateTime.now().millisecondsSinceEpoch % 100 / 50 - 1);
    final actualInterval = (baseInterval + jitter).clamp(1.0, 30.0);

    _fishingTimer = Timer(Duration(milliseconds: (actualInterval * 1000).round()), () {
      _catchFish();
      _scheduleNextFishing(); // 调度下一次
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

    // 钓鱼成就（ID 与 achievement.dart 定义一致）
    _updateAchievementProgress(newProgress, 'catch_1', newPlayer.totalFishCaught);
    _updateAchievementProgress(newProgress, 'catch_10', newPlayer.totalFishCaught);
    _updateAchievementProgress(newProgress, 'catch_50', newPlayer.totalFishCaught);
    _updateAchievementProgress(newProgress, 'catch_100', newPlayer.totalFishCaught);
    _updateAchievementProgress(newProgress, 'catch_500', newPlayer.totalFishCaught);
    _updateAchievementProgress(newProgress, 'catch_1000', newPlayer.totalFishCaught);
    _updateAchievementProgress(newProgress, 'catch_5000', newPlayer.totalFishCaught);

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
    _updateAchievementProgress(progress, 'fish_10', fish.length);
    _updateAchievementProgress(progress, 'fish_50', fish.length);
    _updateAchievementProgress(progress, 'fish_100', fish.length);

    // 稀有及以上数量
    final rareOrBetter = fish.where((f) =>
      f.rarity == Rarity.rare ||
      f.rarity == Rarity.epic ||
      f.rarity == Rarity.legendary
    ).length;
    _updateAchievementProgress(progress, 'rare_5', rareOrBetter);
    _updateAchievementProgress(progress, 'rare_20', rareOrBetter);

    // 史诗数量
    final epic = fish.where((f) => f.rarity == Rarity.epic).length;
    _updateAchievementProgress(progress, 'epic_5', epic);
    _updateAchievementProgress(progress, 'epic_10', epic);

    // 传说数量
    final legendary = fish.where((f) => f.rarity == Rarity.legendary).length;
    _updateAchievementProgress(progress, 'legendary_1', legendary);
    _updateAchievementProgress(progress, 'legendary_5', legendary);
    _updateAchievementProgress(progress, 'legendary_all', legendary);
  }

  /// 更新经济类成就
  void _updateEconomyAchievements(Map<String, AchievementProgress> progress, int coins, int incomePerSecond) {
    _updateAchievementProgress(progress, 'coins_1000', coins);
    _updateAchievementProgress(progress, 'coins_10000', coins);
    _updateAchievementProgress(progress, 'coins_100000', coins);
    _updateAchievementProgress(progress, 'coins_1000000', coins);
    _updateAchievementProgress(progress, 'income_10', incomePerSecond);
    _updateAchievementProgress(progress, 'income_100', incomePerSecond);
    _updateAchievementProgress(progress, 'income_1000', incomePerSecond);
  }

  /// 更新战斗类成就（公开方法）
  void updateBattleAchievements(int bossDefeated, int combo, int fishCount) {
    final newProgress = Map<String, AchievementProgress>.from(state.achievementProgress);
    _updateAchievementProgress(newProgress, 'defeat_boss_1', bossDefeated);
    _updateAchievementProgress(newProgress, 'defeat_boss_5', bossDefeated);
    _updateAchievementProgress(newProgress, 'defeat_boss_10', bossDefeated);
    _updateAchievementProgress(newProgress, 'combo_50', combo);
    _updateAchievementProgress(newProgress, 'combo_100', combo);
    if (fishCount == 1) {
      _updateAchievementProgress(newProgress, 'boss_solo', 1);
    }
    state = state.copyWith(achievementProgress: newProgress);
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
      // 更新经济成就
      final newProgress = Map<String, AchievementProgress>.from(state.achievementProgress);
      _updateEconomyAchievements(newProgress, state.player.coins, state.player.incomePerSecond);

      state = state.copyWith(
        player: state.player,
        notification: '出售成功！获得 $price 金币',
        achievementProgress: newProgress,
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
    // 保存成就进度到 Player
    state.player.achievementProgress = {
      for (final entry in state.achievementProgress.entries)
        entry.key: entry.value.toJson()
    };
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

  // ==================== 装备系统 ====================

  static final Random _random = Random();

  /// 生成装备掉落（战斗胜利后调用）
  Equipment? generateEquipmentDrop(int bossLevel) {
    // 根据Boss等级决定掉落概率
    final dropChance = 0.3 + (bossLevel * 0.05); // 基础30%，每级+5%
    if (_random.nextDouble() > dropChance) return null;

    // 根据Boss等级决定装备稀有度
    EquipmentRarity rarity;
    final roll = _random.nextDouble();
    if (bossLevel >= 4 && roll < 0.1) {
      rarity = EquipmentRarity.legendary;
    } else if (bossLevel >= 3 && roll < 0.25) {
      rarity = EquipmentRarity.epic;
    } else if (bossLevel >= 2 && roll < 0.5) {
      rarity = EquipmentRarity.rare;
    } else {
      rarity = EquipmentRarity.common;
    }

    final template = EquipmentTemplate.getRandomTemplate(rarity);
    return template.create();
  }

  /// 添加装备到背包
  void addEquipmentToInventory(Equipment equipment) {
    state.player.inventory.add(equipment);
    state = state.copyWith(
      player: state.player,
      notification: '🎁 获得装备 ${equipment.emoji} ${equipment.name}！',
    );
  }

  /// 给鱼装备道具
  bool equipItem(String fishId, String equipmentId) {
    final fish = state.player.ownedFish.firstWhere(
      (f) => f.id == fishId,
      orElse: () => throw Exception('鱼不存在'),
    );

    final equipment = state.player.inventory.firstWhere(
      (e) => e.id == equipmentId,
      orElse: () => throw Exception('装备不存在'),
    );

    // 检查槽位是否匹配
    Equipment? oldEquipment;
    switch (equipment.slot) {
      case EquipmentSlot.weapon:
        oldEquipment = fish.weapon;
        fish.equipWeapon(equipment);
        break;
      case EquipmentSlot.armor:
        oldEquipment = fish.armor;
        fish.equipArmor(equipment);
        break;
      case EquipmentSlot.accessory:
        oldEquipment = fish.accessory;
        fish.equipAccessory(equipment);
        break;
    }

    // 从背包移除新装备
    state.player.inventory.removeWhere((e) => e.id == equipmentId);

    // 如果有旧装备，放回背包
    if (oldEquipment != null) {
      state.player.inventory.add(oldEquipment);
    }

    state = state.copyWith(player: state.player);
    return true;
  }

  /// 卸下装备
  bool unequipItem(String fishId, EquipmentSlot slot) {
    final fish = state.player.ownedFish.firstWhere(
      (f) => f.id == fishId,
      orElse: () => throw Exception('鱼不存在'),
    );

    Equipment? equipment;
    switch (slot) {
      case EquipmentSlot.weapon:
        equipment = fish.weapon;
        fish.equipWeapon(null);
        break;
      case EquipmentSlot.armor:
        equipment = fish.armor;
        fish.equipArmor(null);
        break;
      case EquipmentSlot.accessory:
        equipment = fish.accessory;
        fish.equipAccessory(null);
        break;
    }

    if (equipment != null) {
      state.player.inventory.add(equipment);
      state = state.copyWith(player: state.player);
      return true;
    }

    return false;
  }

  /// 升级装备
  bool upgradeEquipment(String equipmentId) {
    final equipment = state.player.inventory.firstWhere(
      (e) => e.id == equipmentId,
      orElse: () => throw Exception('装备不存在'),
    );

    if (state.player.coins < equipment.upgradeCost) return false;

    state.player.coins -= equipment.upgradeCost;
    final index = state.player.inventory.indexOf(equipment);
    state.player.inventory[index] = equipment.upgrade();

    state = state.copyWith(
      player: state.player,
      notification: '⬆️ ${equipment.name} 升级到 Lv.${equipment.level + 1}！',
    );

    return true;
  }

  /// 出售装备
  bool sellEquipment(String equipmentId) {
    final index = state.player.inventory.indexWhere((e) => e.id == equipmentId);
    if (index == -1) return false;

    final equipment = state.player.inventory[index];
    final sellPrice = _calculateEquipmentSellPrice(equipment);

    state.player.inventory.removeAt(index);
    state.player.coins += sellPrice;

    state = state.copyWith(
      player: state.player,
      notification: '💰 出售 ${equipment.emoji} ${equipment.name} 获得 $sellPrice 金币',
    );

    return true;
  }

  /// 计算装备出售价格
  int _calculateEquipmentSellPrice(Equipment equipment) {
    final basePrice = {
      EquipmentRarity.common: 20,
      EquipmentRarity.rare: 80,
      EquipmentRarity.epic: 250,
      EquipmentRarity.legendary: 800,
    };
    return (basePrice[equipment.rarity]! * equipment.level).round();
  }

  // ==================== 转生系统 ====================

  /// 检查是否可以转生
  bool canPrestige() {
    final cost = PrestigeConfig.getPrestigeCost(state.player.prestige.level);
    return state.player.coins >= cost && state.player.totalFishCaught >= 100;
  }

  /// 获取转生预览信息
  PrestigePreview getPrestigePreview() {
    final newPoints = PrestigeConfig.calculatePrestigePoints(
      state.player.prestige.totalCoinsEarned + state.player.coins,
    );
    return PrestigePreview(
      currentLevel: state.player.prestige.level,
      newLevel: state.player.prestige.level + 1,
      pointsGained: newPoints,
      totalPoints: state.player.prestige.points + newPoints,
      cost: PrestigeConfig.getPrestigeCost(state.player.prestige.level),
    );
  }

  /// 执行转生
  PrestigeResult doPrestige() {
    if (!canPrestige()) {
      return PrestigeResult(success: false, message: '条件不满足');
    }

    final preview = getPrestigePreview();
    final newPrestigeData = PrestigeData(
      level: preview.newLevel,
      points: preview.totalPoints,
      totalCoinsEarned: 0, // 重置累计金币计数
      talentLevels: state.player.prestige.talentLevels,
    );

    // 创建新的玩家（重置大部分进度，保留转生数据）
    final newPlayer = Player(
      coins: 100, // 给一点初始金币
      fishFood: 10,
      ownedFish: [],
      equipment: FishingEquipment(),
      inventory: [], // 转生清空装备背包
      lastSaveTime: DateTime.now(),
      totalFishCaught: 0,
      totalBossDefeated: 0,
      prestige: newPrestigeData,
    );

    // 重置成就进度（但保留已完成的记录）
    final newAchievementProgress = Map<String, AchievementProgress>.from(
      state.achievementProgress.map((k, v) => MapEntry(k, v.copyWith(currentValue: 0))),
    );

    // 生成新的每日任务
    final newDailyQuests = DailyQuestData.generate(DateTime.now());

    state = state.copyWith(
      player: newPlayer,
      achievementProgress: newAchievementProgress,
      dailyQuests: newDailyQuests,
      notification: '🌟 转生成功！获得 ${preview.pointsGained} 天赋点数',
    );

    return PrestigeResult(
      success: true,
      message: '转生成功！等级 ${preview.currentLevel} → ${preview.newLevel}',
      pointsGained: preview.pointsGained,
    );
  }

  /// 升级天赋
  bool upgradeTalent(String talentId) {
    final talent = PrestigeTalent.allTalents.firstWhere(
      (t) => t.id == talentId,
      orElse: () => throw Exception('天赋不存在'),
    );

    final currentLevel = state.player.prestige.getTalentLevel(talentId);
    if (currentLevel >= talent.maxLevel) return false;
    if (state.player.prestige.points < talent.costPerLevel) return false;

    final newTalentLevels = Map<String, int>.from(state.player.prestige.talentLevels);
    newTalentLevels[talentId] = currentLevel + 1;

    final newPrestige = state.player.prestige.copyWith(
      points: state.player.prestige.points - talent.costPerLevel,
      talentLevels: newTalentLevels,
    );

    // 更新玩家状态
    state.player.prestige = newPrestige;
    state = state.copyWith(player: state.player);

    return true;
  }

  /// 获取转生加成的收入倍率
  double getPrestigeIncomeMultiplier() {
    return 1.0 + state.player.prestige.getTotalBonus(PrestigeBonusType.incomeBonus);
  }

  /// 获取转生加成的战斗力倍率
  double getPrestigeBattlePowerMultiplier() {
    return 1.0 + state.player.prestige.getTotalBonus(PrestigeBonusType.battlePower);
  }

  /// 获取转生加成的经验倍率
  double getPrestigeExpMultiplier() {
    return 1.0 + state.player.prestige.getTotalBonus(PrestigeBonusType.expGain);
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

/// 转生预览信息
class PrestigePreview {
  final int currentLevel;
  final int newLevel;
  final int pointsGained;
  final int totalPoints;
  final int cost;

  PrestigePreview({
    required this.currentLevel,
    required this.newLevel,
    required this.pointsGained,
    required this.totalPoints,
    required this.cost,
  });
}

/// 转生结果
class PrestigeResult {
  final bool success;
  final String message;
  final int? pointsGained;

  PrestigeResult({
    required this.success,
    required this.message,
    this.pointsGained,
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
