import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fish.dart';
import '../models/boss.dart';
import '../models/battle.dart';

/// 战斗场景状态
class BattleStateData {
  final BattleSession? session;
  final List<BattleFish> battleFish;
  final Boss? currentBoss;
  final BattlePhase phase;
  final String? message;

  BattleStateData({
    this.session,
    this.battleFish = const [],
    this.currentBoss,
    this.phase = BattlePhase.selecting,
    this.message,
  });

  BattleStateData copyWith({
    BattleSession? session,
    List<BattleFish>? battleFish,
    Boss? currentBoss,
    BattlePhase? phase,
    String? message,
  }) {
    return BattleStateData(
      session: session ?? this.session,
      battleFish: battleFish ?? this.battleFish,
      currentBoss: currentBoss ?? this.currentBoss,
      phase: phase ?? this.phase,
      message: message ?? this.message,
    );
  }
}

enum BattlePhase {
  selecting,   // 选择鱼宠
  fighting,    // 战斗中
  victory,     // 胜利
  defeat,      // 失败
}

/// 战斗控制器
class BattleNotifier extends StateNotifier<BattleStateData> {
  Timer? _battleTimer;
  List<Fish> availableFish;
  List<Boss> bosses;

  BattleNotifier({
    required this.availableFish,
    required this.bosses,
  }) : super(BattleStateData());

  /// 开始战斗
  void startBattle(Boss boss, List<Fish> selectedFish) {
    // 创建战斗实体
    final battleFish = selectedFish.asMap().entries.map((entry) {
      final idx = entry.key;
      final fish = entry.value;
      fish.fullHeal();
      return BattleFish(
        fish: fish,
        posX: 30,
        posY: 100.0 + idx * 60,
      );
    }).toList();

    boss.reset();

    state = state.copyWith(
      battleFish: battleFish,
      currentBoss: boss,
      phase: BattlePhase.fighting,
      session: BattleSession(
        boss: boss,
        battleFish: battleFish,
        state: BattleState.fighting,
      ),
    );

    _startBattleLoop();
  }

  /// 战斗循环
  void _startBattleLoop() {
    _battleTimer?.cancel();
    _battleTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _updateBattle();
    });
  }

  /// 更新战斗
  void _updateBattle() {
    final boss = state.currentBoss;
    final battleFish = state.battleFish;
    if (boss == null) return;

    final dt = 0.05;
    bool anyAction = false;

    for (final bf in battleFish) {
      if (!bf.isAlive) continue;

      // 移动向Boss
      bf.moveTowards(280, dt);

      // 攻击冷却
      if (bf.attackCooldown > 0) {
        bf.attackCooldown -= dt;
        continue;
      }

      // 检查是否可以攻击Boss
      if (bf.posX >= 260) {
        // 攻击Boss
        bf.isAttacking = true;
        final damage = max(1, bf.fish.attack - boss.defense);
        boss.takeDamage(damage);

        // Boss反击
        final bossDamage = max(1, boss.attack - bf.fish.defense);
        bf.takeDamage(bossDamage);

        bf.attackCooldown = 1.0; // 1秒冷却
        anyAction = true;

        // 延迟重置攻击状态
        Future.delayed(const Duration(milliseconds: 200), () {
          bf.isAttacking = false;
        });
      }
    }

    // 检查战斗结果
    if (boss.currentHp <= 0) {
      _endBattle(true);
    } else if (battleFish.every((bf) => !bf.isAlive)) {
      _endBattle(false);
    }

    state = state.copyWith(battleFish: List.from(battleFish));
  }

  /// 结束战斗
  void _endBattle(bool victory) {
    _battleTimer?.cancel();

    final session = state.session;
    if (session == null) return;

    if (victory) {
      state.currentBoss!.isDefeated = true;
      state = state.copyWith(
        phase: BattlePhase.victory,
        message: '胜利！获得了奖励！',
      );
    } else {
      state = state.copyWith(
        phase: BattlePhase.defeat,
        message: '战斗失败，鱼宠需要休息...',
      );
    }
  }

  /// 重置战斗
  void reset() {
    _battleTimer?.cancel();
    for (final bf in state.battleFish) {
      bf.reset();
    }
    state = BattleStateData();
  }

  /// 获取奖励
  List<BossReward> claimRewards() {
    final boss = state.currentBoss;
    if (boss == null || !boss.isDefeated) return [];
    return boss.rewards;
  }

  @override
  void dispose() {
    _battleTimer?.cancel();
    super.dispose();
  }
}

/// 战斗Provider
final battleProvider =
    StateNotifierProvider<BattleNotifier, BattleStateData>((ref) {
  return BattleNotifier(
    availableFish: [],
    bosses: Boss.defaultBosses,
  );
});
