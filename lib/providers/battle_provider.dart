import 'dart:async';
import 'dart:math';
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
  final int combo;           // 连击数
  final String? skillMessage; // 技能触发消息
  final bool autoMode;       // 自动战斗模式
  final double battleSpeed;  // 战斗速度倍率

  BattleStateData({
    this.session,
    this.battleFish = const [],
    this.currentBoss,
    this.phase = BattlePhase.selecting,
    this.message,
    this.combo = 0,
    this.skillMessage,
    this.autoMode = false,
    this.battleSpeed = 1.0,
  });

  BattleStateData copyWith({
    BattleSession? session,
    List<BattleFish>? battleFish,
    Boss? currentBoss,
    BattlePhase? phase,
    String? message,
    int? combo,
    String? skillMessage,
    bool? autoMode,
    double? battleSpeed,
    bool clearSkillMessage = false,
  }) {
    return BattleStateData(
      session: session ?? this.session,
      battleFish: battleFish ?? this.battleFish,
      currentBoss: currentBoss ?? this.currentBoss,
      phase: phase ?? this.phase,
      message: message ?? this.message,
      combo: combo ?? this.combo,
      skillMessage: clearSkillMessage ? null : (skillMessage ?? this.skillMessage),
      autoMode: autoMode ?? this.autoMode,
      battleSpeed: battleSpeed ?? this.battleSpeed,
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
  static final Random _random = Random();
  int _combo = 0;
  DateTime? _lastAttackTime;

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
    // 根据战斗速度调整间隔
    final intervalMs = (50 / state.battleSpeed).round();
    _battleTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      _updateBattle();
    });
  }

  /// 更新战斗
  void _updateBattle() {
    final boss = state.currentBoss;
    final battleFish = state.battleFish;
    if (boss == null) return;

    final dt = 0.05;
    String? skillMessage;

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
        bf.isAttacking = true;

        // 计算基础伤害
        var damage = max(1, bf.fish.attack - boss.defense);

        // 应用技能效果
        final skill = bf.fish.skill;
        if (skill != null) {
          final skillResult = _applySkill(bf, damage, boss);
          damage = skillResult.damage;
          if (skillResult.message != null) {
            skillMessage = skillResult.message;
          }
        }

        // 应用连击加成
        final now = DateTime.now();
        if (_lastAttackTime != null &&
            now.difference(_lastAttackTime!).inMilliseconds < 1000) {
          _combo++;
        } else {
          _combo = 1;
        }
        _lastAttackTime = now;

        // 连击加成：每10连击增加10%伤害
        final comboBonus = 1.0 + (_combo ~/ 10) * 0.1;
        damage = (damage * comboBonus).round();

        boss.takeDamage(damage);

        // Boss反击
        var bossDamage = max(1, boss.attack - bf.fish.defense);

        // 检查闪避技能
        if (bf.fish.skill?.type == SkillType.dodge &&
            _random.nextDouble() < bf.fish.skill!.chance) {
          bossDamage = 0;
          skillMessage = '${bf.fish.emoji} 闪避了攻击！';
        }

        bf.takeDamage(bossDamage);

        bf.attackCooldown = 1.0; // 1秒冷却

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

    state = state.copyWith(
      battleFish: List.from(battleFish),
      combo: _combo,
      skillMessage: skillMessage,
    );
  }

  /// 应用技能效果
  ({int damage, String? message}) _applySkill(BattleFish bf, int damage, Boss boss) {
    final skill = bf.fish.skill!;
    var resultDamage = damage;
    String? message;

    switch (skill.type) {
      case SkillType.criticalStrike:
        if (_random.nextDouble() < skill.chance) {
          resultDamage = (damage * skill.value).round();
          message = '💥 ${bf.fish.emoji} 暴击！';
        }
        break;

      case SkillType.lifesteal:
        final healAmount = (damage * skill.value).round();
        bf.fish.heal(healAmount);
        bf.currentHp = bf.fish.hp;
        message = '🩸 ${bf.fish.emoji} 吸血 +$healAmount';
        break;

      case SkillType.rage:
        if (bf.hpPercent < 0.5) {
          resultDamage = (damage * (1 + skill.value)).round();
          message = '🔥 ${bf.fish.emoji} 狂暴！';
        }
        break;

      case SkillType.multiAttack:
        if (_random.nextDouble() < skill.chance) {
          // 额外攻击
          boss.takeDamage(damage);
          message = '⚔️ ${bf.fish.emoji} 连击！';
        }
        break;

      case SkillType.counterAttack:
        // 反击在受伤时处理
        break;

      case SkillType.heal:
        // 每回合恢复
        bf.fish.heal((bf.fish.maxHp * 0.05).round());
        bf.currentHp = bf.fish.hp;
        break;

      case SkillType.shield:
        // 护盾在受伤时处理
        break;

      case SkillType.dodge:
        // 闪避在反击时处理
        break;
    }

    return (damage: resultDamage, message: message);
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
    _combo = 0;
    _lastAttackTime = null;
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

  /// 切换自动战斗模式
  void toggleAutoMode() {
    state = state.copyWith(autoMode: !state.autoMode);
  }

  /// 设置战斗速度
  void setBattleSpeed(double speed) {
    // 支持 1x, 2x, 4x 速度
    final validSpeeds = [1.0, 2.0, 4.0];
    final newSpeed = validSpeeds.contains(speed) ? speed : 1.0;
    state = state.copyWith(battleSpeed: newSpeed);

    // 重新启动战斗循环以应用新速度
    if (state.phase == BattlePhase.fighting) {
      _battleTimer?.cancel();
      _startBattleLoop();
    }
  }

  /// 快速战斗（跳过战斗动画，直接计算结果）
  QuickBattleResult? quickBattle(Boss boss, List<Fish> selectedFish) {
    if (selectedFish.isEmpty) return null;

    // 计算总战力
    final myPower = selectedFish.fold(0, (sum, f) => sum + f.power);
    final bossPower = boss.requiredPower;

    // 基于战力差计算胜率
    double winChance;
    if (myPower >= bossPower * 1.5) {
      winChance = 0.95;
    } else if (myPower >= bossPower) {
      winChance = 0.7;
    } else if (myPower >= bossPower * 0.7) {
      winChance = 0.4;
    } else {
      winChance = 0.1;
    }

    // 随机判定胜负
    final roll = _random.nextDouble();
    final victory = roll < winChance;

    // 计算战斗回合数（用于估算经验）
    final rounds = victory
        ? (5 + _random.nextInt(10))
        : (3 + _random.nextInt(5));

    return QuickBattleResult(
      victory: victory,
      rounds: rounds,
      winChance: winChance,
      rewards: victory ? boss.rewards : [],
    );
  }

  @override
  void dispose() {
    _battleTimer?.cancel();
    super.dispose();
  }
}

/// 快速战斗结果
class QuickBattleResult {
  final bool victory;
  final int rounds;
  final double winChance;
  final List<BossReward> rewards;

  QuickBattleResult({
    required this.victory,
    required this.rounds,
    required this.winChance,
    required this.rewards,
  });
}

/// 战斗Provider
final battleProvider =
    StateNotifierProvider<BattleNotifier, BattleStateData>((ref) {
  return BattleNotifier(
    availableFish: [],
    bosses: Boss.defaultBosses,
  );
});
