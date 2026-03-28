import 'equipment.dart';

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

/// 鱼的技能类型
enum SkillType {
  criticalStrike,   // 暴击：攻击有几率造成双倍伤害
  lifesteal,        // 吸血：攻击时恢复生命
  shield,           // 护盾：受到伤害减少
  counterAttack,    // 反击：被攻击时有几率反击
  multiAttack,      // 连击：攻击有几率额外攻击
  heal,             // 治疗：每回合恢复少量生命
  rage,             // 狂暴：生命值低时攻击提升
  dodge,            // 闪避：有几率闪避攻击
}

/// 鱼词条类型
enum FishTraitType {
  diligent,   // 勤奋
  lucky,      // 幸运
  fierce,     // 凶猛
  sturdy,     // 坚韧
  swift,      // 迅捷
  gluttonous, // 贪吃
}

/// 鱼词条
class FishTrait {
  final FishTraitType type;
  final String name;
  final String emoji;
  final String description;
  final double incomeMultiplier;
  final double attackMultiplier;
  final double defenseMultiplier;
  final double speedMultiplier;
  final double expMultiplier;

  const FishTrait({
    required this.type,
    required this.name,
    required this.emoji,
    required this.description,
    this.incomeMultiplier = 1.0,
    this.attackMultiplier = 1.0,
    this.defenseMultiplier = 1.0,
    this.speedMultiplier = 1.0,
    this.expMultiplier = 1.0,
  });

  static const Map<FishTraitType, FishTrait> presets = {
    FishTraitType.diligent: FishTrait(
      type: FishTraitType.diligent,
      name: '勤奋',
      emoji: '💼',
      description: '工作收益更高',
      incomeMultiplier: 1.2,
    ),
    FishTraitType.lucky: FishTrait(
      type: FishTraitType.lucky,
      name: '幸运',
      emoji: '🍀',
      description: '更容易在活动中钓到好货',
      incomeMultiplier: 1.1,
      expMultiplier: 1.1,
    ),
    FishTraitType.fierce: FishTrait(
      type: FishTraitType.fierce,
      name: '凶猛',
      emoji: '🦷',
      description: '攻击力更高',
      attackMultiplier: 1.18,
    ),
    FishTraitType.sturdy: FishTrait(
      type: FishTraitType.sturdy,
      name: '坚韧',
      emoji: '🛡️',
      description: '防御力更高',
      defenseMultiplier: 1.18,
    ),
    FishTraitType.swift: FishTrait(
      type: FishTraitType.swift,
      name: '迅捷',
      emoji: '💨',
      description: '速度更快',
      speedMultiplier: 1.2,
    ),
    FishTraitType.gluttonous: FishTrait(
      type: FishTraitType.gluttonous,
      name: '贪吃',
      emoji: '🍖',
      description: '吃得多，成长也更快',
      incomeMultiplier: 1.08,
      expMultiplier: 1.2,
    ),
  };

  factory FishTrait.fromType(FishTraitType type) => presets[type]!;

  Map<String, dynamic> toJson() => {
    'type': type.index,
  };

  factory FishTrait.fromJson(Map<String, dynamic> json) {
    return FishTrait.fromType(FishTraitType.values[json['type']]);
  }
}

/// 鱼的技能
class FishSkill {
  final SkillType type;
  final String name;
  final String description;
  final double chance;  // 触发概率
  final double value;   // 效果数值

  const FishSkill({
    required this.type,
    required this.name,
    required this.description,
    required this.chance,
    required this.value,
  });

  /// 根据稀有度获取默认技能
  static FishSkill? getDefaultSkill(Rarity rarity) {
    switch (rarity) {
      case Rarity.common:
        return null; // 普通鱼无技能
      case Rarity.rare:
        return const FishSkill(
          type: SkillType.criticalStrike,
          name: '暴击',
          description: '攻击有15%几率造成双倍伤害',
          chance: 0.15,
          value: 2.0,
        );
      case Rarity.epic:
        return const FishSkill(
          type: SkillType.lifesteal,
          name: '吸血',
          description: '攻击时恢复造成伤害的30%',
          chance: 1.0,
          value: 0.3,
        );
      case Rarity.legendary:
        return const FishSkill(
          type: SkillType.rage,
          name: '狂暴',
          description: '生命值低于50%时攻击提升50%',
          chance: 1.0,
          value: 0.5,
        );
    }
  }
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

  // === 战斗属性（基础值） ===
  int _baseHp;          // 基础最大生命值
  int _baseAttack;      // 基础攻击力
  int _baseDefense;     // 基础防御力
  int _baseSpeed;       // 基础速度

  // 当前生命值
  int hp;

  // === 技能系统 ===
  final FishSkill? skill;
  final FishTrait? trait;

  // === 装备系统 ===
  Equipment? weapon;      // 武器
  Equipment? armor;       // 护甲
  Equipment? accessory;   // 饰品

  // === 场景位置 ===
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
    int? baseHp,
    int? baseAttack,
    int? baseDefense,
    int? baseSpeed,
    int? currentHp,
    // 装备
    this.weapon,
    this.armor,
    this.accessory,
    // 技能
    FishSkill? skill,
    this.trait,
    // 场景位置默认值
    this.posX = 0,
    this.posY = 0,
    this.targetX = 0,
    this.targetY = 0,
    this.state = FishState.idle,
  })  : _baseHp = baseHp ?? _calculateBaseHp(rarity, level),
        _baseAttack = baseAttack ?? _calculateBaseAttack(rarity, level),
        _baseDefense = baseDefense ?? _calculateBaseDefense(rarity, level),
        _baseSpeed = baseSpeed ?? _calculateBaseSpeed(rarity),
        hp = currentHp ?? baseHp ?? _calculateBaseHp(rarity, level),
        skill = skill ?? FishSkill.getDefaultSkill(rarity);

  // === 计算属性（基础 + 装备加成） ===

  /// 最大生命值（基础 + 装备）
  int get maxHp {
    int bonus = 0;
    bonus += weapon?.actualHpBonus ?? 0;
    bonus += armor?.actualHpBonus ?? 0;
    bonus += accessory?.actualHpBonus ?? 0;
    return _baseHp + bonus;
  }

  /// 攻击力（基础 + 装备）
  int get attack {
    int bonus = 0;
    bonus += weapon?.actualAttackBonus ?? 0;
    bonus += armor?.actualAttackBonus ?? 0;
    bonus += accessory?.actualAttackBonus ?? 0;
    return ((_baseAttack + bonus) * (trait?.attackMultiplier ?? 1.0)).round();
  }

  /// 防御力（基础 + 装备）
  int get defense {
    int bonus = 0;
    bonus += weapon?.actualDefenseBonus ?? 0;
    bonus += armor?.actualDefenseBonus ?? 0;
    bonus += accessory?.actualDefenseBonus ?? 0;
    return ((_baseDefense + bonus) * (trait?.defenseMultiplier ?? 1.0)).round();
  }

  /// 速度（基础 + 装备）
  int get speed {
    int bonus = 0;
    bonus += weapon?.actualSpeedBonus ?? 0;
    bonus += armor?.actualSpeedBonus ?? 0;
    bonus += accessory?.actualSpeedBonus ?? 0;
    return ((_baseSpeed + bonus) * (trait?.speedMultiplier ?? 1.0)).round();
  }

  /// 装备武器
  void equipWeapon(Equipment? newWeapon) {
    weapon = newWeapon;
  }

  /// 装备护甲
  void equipArmor(Equipment? newArmor) {
    armor = newArmor;
  }

  /// 装备饰品
  void equipAccessory(Equipment? newAccessory) {
    accessory = newAccessory;
  }

  /// 获取所有已装备的装备
  List<Equipment> get equippedItems {
    return [weapon, armor, accessory].whereType<Equipment>().toList();
  }

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
  int get income => (baseIncome * level * workMultiplier * _jobBonus * (trait?.incomeMultiplier ?? 1.0)).round();

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
    exp += (amount * (trait?.expMultiplier ?? 1.0)).round();
    while (exp >= expToNextLevel) {
      exp -= expToNextLevel;
      level++;
      // 升级时提升战斗属性
      _recalculateCombatStats();
    }
  }

  /// 重新计算战斗属性（升级时调用）
  void _recalculateCombatStats() {
    _baseHp = _calculateBaseHp(rarity, level);
    _baseAttack = _calculateBaseAttack(rarity, level);
    _baseDefense = _calculateBaseDefense(rarity, level);
    hp = maxHp; // 恢复满血
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
    'baseHp': _baseHp,
    'baseAttack': _baseAttack,
    'baseDefense': _baseDefense,
    'baseSpeed': _baseSpeed,
    'hp': hp,
    'posX': posX,
    'posY': posY,
    'state': state.index,
    'skillType': skill?.type.index,
    'trait': trait?.toJson(),
    'weapon': weapon?.toJson(),
    'armor': armor?.toJson(),
    'accessory': accessory?.toJson(),
  };

  /// 从JSON创建
  factory Fish.fromJson(Map<String, dynamic> json) {
    FishSkill? skill;
    if (json['skillType'] != null) {
      final rarity = Rarity.values[json['rarity']];
      skill = FishSkill.getDefaultSkill(rarity);
    }

    return Fish(
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
      baseHp: json['baseHp'],
      baseAttack: json['baseAttack'],
      baseDefense: json['baseDefense'],
      baseSpeed: json['baseSpeed'],
      currentHp: json['hp'],
      skill: skill,
      trait: json['trait'] != null ? FishTrait.fromJson(json['trait']) : null,
      posX: (json['posX'] ?? 0).toDouble(),
      posY: (json['posY'] ?? 0).toDouble(),
      state: FishState.values[json['state'] ?? 0],
    )..weapon = json['weapon'] != null ? Equipment.fromJson(json['weapon']) : null
     ..armor = json['armor'] != null ? Equipment.fromJson(json['armor']) : null
     ..accessory = json['accessory'] != null ? Equipment.fromJson(json['accessory']) : null;
  }
}
