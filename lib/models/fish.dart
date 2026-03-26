/// 鱼的稀有度枚举
enum Rarity {
  common,   // 普通
  rare,     // 稀有
  epic,     // 史诗
  legendary, // 传说
}

/// 鱼的工作类型
enum JobType {
  idle,      // 闲置
  fishing,   // 钓鱼助手
  farming,   // 种田
  mining,    // 挖矿
  shop,      // 看店
}

/// 鱼的状态
enum FishState {
  idle,      // 闲置
  walking,   // 移动中
  working,   // 工作中
  fighting,  // 战斗中
}

/// 鱼的数据模型 - 包含战斗属性和场景位置
class Fish {
  final String id;
  final String name;
  final Rarity rarity;
  final String emoji;       // 显示图标
  final int baseIncome;     // 基础收入/秒
  final int baseValue;      // 基础出售价格

  // 等级系统
  int level;
  int exp;

  // 工作系统
  JobType currentJob;
  double workMultiplier;

  // === 新增：战斗属性 ===
  int hp;              // 当前生命值
  int maxHp;           // 最大生命值
  int attack;          // 攻击力
  int defense;         // 防御力
  int speed;           // 移动速度

  // === 新增：场景位置 ===
  double posX;         // X坐标
  double posY;         // Y坐标
  double targetX;      // 目标X坐标
  double targetY;      // 目标Y坐标
  FishState state;     // 当前状态

  Fish({
    required this.id,
    required this.name,
    required this.rarity,
    required this.emoji,
    required this.baseIncome,
    required this.baseValue,
    this.level = 1,
    this.exp = 0,
    this.currentJob = JobType.idle,
    this.workMultiplier = 1.0,
    // 战斗属性默认值
    int? hp,
    int? maxHp,
    int? attack,
    int? defense,
    int? speed,
    // 场景位置默认值
    this.posX = 0,
    this.posY = 0,
    this.targetX = 0,
    this.targetY = 0,
    this.state = FishState.idle,
  })  : hp = hp ?? _calculateBaseHp(rarity, level),
        maxHp = maxHp ?? _calculateBaseHp(rarity, level),
        attack = attack ?? _calculateBaseAttack(rarity, level),
        defense = defense ?? _calculateBaseDefense(rarity, level),
        speed = speed ?? _calculateBaseSpeed(rarity);

  /// 计算基础生命值
  static int _calculateBaseHp(Rarity rarity, int level) {
    final baseValues = {
      Rarity.common: 50,
      Rarity.rare: 80,
      Rarity.epic: 120,
      Rarity.legendary: 200,
    };
    return (baseValues[rarity]! * (1 + (level - 1) * 0.1)).round();
  }

  /// 计算基础攻击力
  static int _calculateBaseAttack(Rarity rarity, int level) {
    final baseValues = {
      Rarity.common: 5,
      Rarity.rare: 10,
      Rarity.epic: 18,
      Rarity.legendary: 30,
    };
    return (baseValues[rarity]! * (1 + (level - 1) * 0.1)).round();
  }

  /// 计算基础防御力
  static int _calculateBaseDefense(Rarity rarity, int level) {
    final baseValues = {
      Rarity.common: 2,
      Rarity.rare: 5,
      Rarity.epic: 10,
      Rarity.legendary: 18,
    };
    return (baseValues[rarity]! * (1 + (level - 1) * 0.1)).round();
  }

  /// 计算基础速度
  static int _calculateBaseSpeed(Rarity rarity) {
    return {
      Rarity.common: 30,
      Rarity.rare: 40,
      Rarity.epic: 50,
      Rarity.legendary: 60,
    }[rarity]!;
  }

  /// 获取战斗力（用于评估）
  int get power => hp + attack * 3 + defense * 2 + speed;

  /// 获取当前收入（考虑等级和工作加成）
  int get income => (baseIncome * level * workMultiplier * _jobBonus).round();

  /// 工作加成
  double get _jobBonus {
    switch (currentJob) {
      case JobType.idle:
        return 0;
      case JobType.fishing:
        return 1.0;
      case JobType.farming:
        return 1.2;
      case JobType.mining:
        return 1.5;
      case JobType.shop:
        return 2.0;
    }
  }

  /// 升级所需经验
  int get expToNextLevel => level * 100;

  /// 添加经验并升级
  void addExp(int amount) {
    exp += amount;
    while (exp >= expToNextLevel) {
      exp -= expToNextLevel;
      level++;
      // 升级时提升战斗属性
      _recalculateCombatStats();
    }
  }

  /// 重新计算战斗属性
  void _recalculateCombatStats() {
    maxHp = _calculateBaseHp(rarity, level);
    hp = maxHp;
    attack = _calculateBaseAttack(rarity, level);
    defense = _calculateBaseDefense(rarity, level);
  }

  /// 受到伤害
  int takeDamage(int damage) {
    final actualDamage = (damage - defense).clamp(1, damage);
    hp = (hp - actualDamage).clamp(0, hp);
    return actualDamage;
  }

  /// 恢复生命
  void heal(int amount) {
    hp = (hp + amount).clamp(0, maxHp);
  }

  /// 完全恢复
  void fullHeal() {
    hp = maxHp;
  }

  /// 设置目标位置
  void setTarget(double x, double y) {
    targetX = x;
    targetY = y;
    if (posX != x || posY != y) {
      state = FishState.walking;
    }
  }

  /// 更新位置（移动逻辑）
  void updatePosition(double dt) {
    if (state != FishState.walking) return;

    final dx = targetX - posX;
    final dy = targetY - posY;
    final distance = (dx * dx + dy * dy);

    if (distance < 4) {
      // 到达目标
      posX = targetX;
      posY = targetY;
      state = currentJob != JobType.idle ? FishState.working : FishState.idle;
    } else {
      // 继续移动
      final moveDistance = speed * dt;
      final dir = distance == 0 ? 0 : moveDistance / distance;
      posX += dx * dir;
      posY += dy * dir;
    }
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rarity': rarity.index,
    'emoji': emoji,
    'baseIncome': baseIncome,
    'baseValue': baseValue,
    'level': level,
    'exp': exp,
    'currentJob': currentJob.index,
    'workMultiplier': workMultiplier,
    'hp': hp,
    'maxHp': maxHp,
    'attack': attack,
    'defense': defense,
    'speed': speed,
    'posX': posX,
    'posY': posY,
    'state': state.index,
  };

  /// 从JSON创建
  factory Fish.fromJson(Map<String, dynamic> json) => Fish(
    id: json['id'],
    name: json['name'],
    rarity: Rarity.values[json['rarity']],
    emoji: json['emoji'],
    baseIncome: json['baseIncome'],
    baseValue: json['baseValue'],
    level: json['level'] ?? 1,
    exp: json['exp'] ?? 0,
    currentJob: JobType.values[json['currentJob'] ?? 0],
    workMultiplier: (json['workMultiplier'] ?? 1.0).toDouble(),
    hp: json['hp'],
    maxHp: json['maxHp'],
    attack: json['attack'],
    defense: json['defense'],
    speed: json['speed'],
    posX: (json['posX'] ?? 0).toDouble(),
    posY: (json['posY'] ?? 0).toDouble(),
    state: FishState.values[json['state'] ?? 0],
  );
}
