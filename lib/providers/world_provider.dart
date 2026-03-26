import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fish.dart';
import '../models/building.dart';
import '../models/player.dart';

/// 场景中的鱼实体
class WorldFish {
  final Fish fish;
  double x;
  double y;
  double targetX;
  double targetY;
  FishState state;
  double animFrame;
  double idleTime;

  // 每条鱼有自己的随机数生成器，避免全局状态
  static final Random _random = Random();

  WorldFish({
    required this.fish,
    this.x = 100,
    this.y = 200,
    this.targetX = 100,
    this.targetY = 200,
    this.state = FishState.idle,
    this.animFrame = 0,
    this.idleTime = 0,
  });

  /// 更新位置和状态
  void update(double dt, List<Building> buildings) {
    animFrame += dt * 10;

    switch (state) {
      case FishState.idle:
        idleTime += dt;
        // 随机开始走动
        if (idleTime > 2 + _random.nextDouble() * 3) {
          _pickRandomTarget(buildings);
          state = FishState.walking;
          idleTime = 0;
        }
        break;

      case FishState.walking:
        final dx = targetX - x;
        final dy = targetY - y;
        final dist = sqrt(dx * dx + dy * dy);

        if (dist < 5) {
          x = targetX;
          y = targetY;
          state = fish.currentJob != JobType.idle
              ? FishState.working
              : FishState.idle;
        } else {
          final speed = fish.speed * dt;
          x += (dx / dist) * speed;
          y += (dy / dist) * speed;
        }
        break;

      case FishState.working:
        idleTime += dt;
        // 工作一段时间后可能移动
        if (idleTime > 5 + _random.nextDouble() * 5) {
          _pickRandomTarget(buildings);
          state = FishState.walking;
          idleTime = 0;
        }
        break;

      case FishState.fighting:
        // 战斗状态由战斗系统控制
        break;
    }
  }

  /// 选择随机目标
  void _pickRandomTarget(List<Building> buildings) {
    // 根据工作类型选择目标区域
    Building? targetBuilding;

    switch (fish.currentJob) {
      case JobType.fishing:
        targetBuilding = buildings.firstWhere(
          (b) => b.type == BuildingType.dock && b.isUnlocked,
          orElse: () => buildings.first,
        );
        break;
      case JobType.farming:
        targetBuilding = buildings.firstWhere(
          (b) => b.type == BuildingType.farm && b.isUnlocked,
          orElse: () => buildings.first,
        );
        break;
      case JobType.mining:
        targetBuilding = buildings.firstWhere(
          (b) => b.type == BuildingType.mine && b.isUnlocked,
          orElse: () => buildings.first,
        );
        break;
      case JobType.shop:
        targetBuilding = buildings.firstWhere(
          (b) => b.type == BuildingType.shop && b.isUnlocked,
          orElse: () => buildings.first,
        );
        break;
      case JobType.idle:
        // 随机位置
        targetX = 50 + _random.nextDouble() * 300;
        targetY = 100 + _random.nextDouble() * 200;
        return;
    }

    if (targetBuilding != null) {
      targetX = targetBuilding.posX + _random.nextDouble() * 50;
      targetY = targetBuilding.posY + _random.nextDouble() * 50;
    }
  }
}

/// 世界场景状态
class WorldState {
  final Player player;
  final List<Building> buildings;
  final List<WorldFish> worldFish;
  final double time;

  WorldState({
    required this.player,
    required this.buildings,
    required this.worldFish,
    this.time = 0,
  });

  WorldState copyWith({
    Player? player,
    List<Building>? buildings,
    List<WorldFish>? worldFish,
    double? time,
  }) {
    return WorldState(
      player: player ?? this.player,
      buildings: buildings ?? this.buildings,
      worldFish: worldFish ?? this.worldFish,
      time: time ?? this.time,
    );
  }
}

/// 世界场景控制器
class WorldNotifier extends StateNotifier<WorldState> {
  static final Random _random = Random();

  WorldNotifier(Player player)
      : super(WorldState(
          player: player,
          buildings: Building.defaultBuildings,
          worldFish: player.ownedFish
              .map((f) => WorldFish(
                    fish: f,
                    x: 100 + _random.nextDouble() * 200,
                    y: 150 + _random.nextDouble() * 100,
                  ))
              .toList(),
        ));

  /// 更新场景
  void update(double dt) {
    for (final wf in state.worldFish) {
      wf.update(dt, state.buildings);
    }
    state = state.copyWith(time: state.time + dt);
  }

  /// 添加鱼
  void addFish(Fish fish) {
    state.worldFish.add(WorldFish(
      fish: fish,
      x: 100 + _random.nextDouble() * 200,
      y: 150 + _random.nextDouble() * 100,
    ));
    state = state.copyWith();
  }

  /// 解锁建筑
  bool unlockBuilding(String buildingId) {
    final building = state.buildings.firstWhere((b) => b.id == buildingId);
    if (building.isUnlocked) return false;
    if (state.player.coins < building.unlockCost) return false;

    state.player.coins -= building.unlockCost;
    building.isUnlocked = true;
    state = state.copyWith();
    return true;
  }

  /// 升级建筑
  bool upgradeBuilding(String buildingId) {
    final building = state.buildings.firstWhere((b) => b.id == buildingId);
    if (!building.isUnlocked) return false;
    if (state.player.coins < building.upgradeCost) return false;

    state.player.coins -= building.upgradeCost;
    building.level++;
    state = state.copyWith();
    return true;
  }

  /// 指派鱼的工作
  void assignJob(String fishId, JobType job) {
    final fish = state.player.ownedFish.firstWhere((f) => f.id == fishId);
    if (fish == null) return;

    fish.currentJob = job;
    final worldFish = state.worldFish.firstWhere((wf) => wf.fish.id == fishId);
    if (worldFish != null) {
      worldFish.state = FishState.walking;
    }
    state = state.copyWith();
  }
}

/// 世界场景Provider
final worldProvider = StateNotifierProvider<WorldNotifier, WorldState>((ref) {
  return WorldNotifier(Player());
});
