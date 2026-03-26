import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fish.dart';
import '../models/player.dart';
import '../utils/fish_data.dart';
import '../utils/constants.dart';

/// 游戏状态
class GameState {
  final Player player;
  final bool isFishing;
  final Fish? lastCaughtFish;
  final String? notification;

  GameState({
    required this.player,
    this.isFishing = true,
    this.lastCaughtFish,
    this.notification,
  });

  GameState copyWith({
    Player? player,
    bool? isFishing,
    Fish? lastCaughtFish,
    String? notification,
    bool clearNotification = false,
    bool clearLastCaughtFish = false,
  }) {
    return GameState(
      player: player ?? this.player,
      isFishing: isFishing ?? this.isFishing,
      lastCaughtFish: clearLastCaughtFish ? null : (lastCaughtFish ?? this.lastCaughtFish),
      notification: clearNotification ? null : (notification ?? this.notification),
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

    state = state.copyWith(
      player: newPlayer,
      lastCaughtFish: fish,
      notification: '钓到了 ${fish.emoji} ${fish.name}！',
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

/// 游戏Provider
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});
