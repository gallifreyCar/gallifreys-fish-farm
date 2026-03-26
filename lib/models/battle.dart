import 'fish.dart';
import 'boss.dart';

/// 战斗状态
enum BattleState {
  preparing,   // 准备中（选择鱼宠）
  fighting,    // 战斗中
  victory,     // 胜利
  defeat,      // 失败
}

/// 战斗中的鱼宠实体
class BattleFish {
  final Fish fish;
  double posX;
  double posY;
  int currentHp;
  bool isAttacking;
  bool isHurt;
  double attackCooldown;

  BattleFish({
    required this.fish,
    this.posX = 50,
    this.posY = 0,
    int? currentHp,
    this.isAttacking = false,
    this.isHurt = false,
    this.attackCooldown = 0,
  }) : currentHp = currentHp ?? fish.hp;

  /// 是否存活
  bool get isAlive => currentHp > 0;

  /// 生命值百分比
  double get hpPercent => currentHp / fish.maxHp;

  /// 更新位置（向Boss移动）
  void moveTowards(double targetX, double dt) {
    if (!isAlive || isAttacking) return;

    final dx = targetX - posX;
    if (dx.abs() > 10) {
      posX += fish.speed * dt * (dx > 0 ? 1 : -1);
    }
  }

  /// 受到伤害
  int takeDamage(int damage) {
    final actualDamage = fish.takeDamage(damage);
    currentHp = fish.hp;
    isHurt = true;
    return actualDamage;
  }

  /// 重置状态
  void reset() {
    fish.fullHeal();
    currentHp = fish.maxHp;
    posX = 50;
    isAttacking = false;
    isHurt = false;
    attackCooldown = 0;
  }
}

/// 战斗会话
class BattleSession {
  final Boss boss;
  final List<BattleFish> battleFish;
  BattleState state;
  int totalDamageDealt;
  int totalDamageTaken;
  DateTime startTime;

  BattleSession({
    required this.boss,
    required this.battleFish,
    this.state = BattleState.preparing,
    this.totalDamageDealt = 0,
    this.totalDamageTaken = 0,
    DateTime? startTime,
  }) : startTime = startTime ?? DateTime.now();

  /// 总战力
  int get totalPower =>
      battleFish.fold(0, (sum, bf) => sum + bf.fish.power);

  /// 存活的鱼数量
  int get aliveFishCount =>
      battleFish.where((bf) => bf.isAlive).length;

  /// 是否全部阵亡
  bool get isAllDefeated =>
      battleFish.every((bf) => !bf.isAlive);

  /// 计算战斗力对比
  String get powerComparison {
    final myPower = totalPower;
    final bossPower = boss.requiredPower;
    if (myPower >= bossPower * 1.5) return '优势';
    if (myPower >= bossPower) return '均势';
    if (myPower >= bossPower * 0.7) return '劣势';
    return '劣势极大';
  }
}
