/// 装备槽位
enum EquipmentSlot {
  weapon,     // 武器（增加攻击）
  armor,      // 护甲（增加防御/生命）
  accessory,  // 饰品（增加速度/特殊效果）
}

/// 装备稀有度
enum EquipmentRarity {
  common,     // 普通 - 白色
  rare,       // 稀有 - 蓝色
  epic,       // 史诗 - 紫色
  legendary,  // 传说 - 橙色
}

/// 装备模型
class Equipment {
  final String id;
  final String name;
  final String emoji;
  final EquipmentSlot slot;
  final EquipmentRarity rarity;
  final int level;

  // 基础属性加成
  final int hpBonus;
  final int attackBonus;
  final int defenseBonus;
  final int speedBonus;

  // 特殊效果
  final EquipmentEffect? effect;

  Equipment({
    required this.id,
    required this.name,
    required this.emoji,
    required this.slot,
    required this.rarity,
    this.level = 1,
    this.hpBonus = 0,
    this.attackBonus = 0,
    this.defenseBonus = 0,
    this.speedBonus = 0,
    this.effect,
  });

  /// 获取实际加成（考虑等级）
  int get actualHpBonus => hpBonus * level;
  int get actualAttackBonus => attackBonus * level;
  int get actualDefenseBonus => defenseBonus * level;
  int get actualSpeedBonus => speedBonus * level;

  /// 升级费用
  int get upgradeCost {
    final baseCost = {
      EquipmentRarity.common: 50,
      EquipmentRarity.rare: 150,
      EquipmentRarity.epic: 400,
      EquipmentRarity.legendary: 1000,
    };
    return baseCost[rarity]! * level;
  }

  /// 升级
  Equipment upgrade() {
    return Equipment(
      id: id,
      name: name,
      emoji: emoji,
      slot: slot,
      rarity: rarity,
      level: level + 1,
      hpBonus: hpBonus,
      attackBonus: attackBonus,
      defenseBonus: defenseBonus,
      speedBonus: speedBonus,
      effect: effect,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'slot': slot.index,
    'rarity': rarity.index,
    'level': level,
    'hpBonus': hpBonus,
    'attackBonus': attackBonus,
    'defenseBonus': defenseBonus,
    'speedBonus': speedBonus,
    'effectType': effect?.type.index,
  };

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      slot: EquipmentSlot.values[json['slot']],
      rarity: EquipmentRarity.values[json['rarity']],
      level: json['level'] ?? 1,
      hpBonus: json['hpBonus'] ?? 0,
      attackBonus: json['attackBonus'] ?? 0,
      defenseBonus: json['defenseBonus'] ?? 0,
      speedBonus: json['speedBonus'] ?? 0,
      effect: json['effectType'] != null
          ? EquipmentEffect(type: EquipmentEffectType.values[json['effectType']])
          : null,
    );
  }
}

/// 装备特效类型
enum EquipmentEffectType {
  criticalStrike,   // 暴击率提升
  lifesteal,        // 吸血
  counterAttack,    // 反击
  doubleAttack,     // 双击概率
  damageReduction,  // 伤害减免
}

/// 装备特效
class EquipmentEffect {
  final EquipmentEffectType type;
  final double value;

  const EquipmentEffect({
    required this.type,
    this.value = 0.1,
  });
}

/// 装备模板（用于生成装备）
class EquipmentTemplate {
  final String name;
  final String emoji;
  final EquipmentSlot slot;
  final EquipmentRarity rarity;
  final int baseHp;
  final int baseAttack;
  final int baseDefense;
  final int baseSpeed;
  final EquipmentEffect? effect;

  const EquipmentTemplate({
    required this.name,
    required this.emoji,
    required this.slot,
    required this.rarity,
    this.baseHp = 0,
    this.baseAttack = 0,
    this.baseDefense = 0,
    this.baseSpeed = 0,
    this.effect,
  });

  /// 创建装备实例
  Equipment create() {
    return Equipment(
      id: '${name}_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      emoji: emoji,
      slot: slot,
      rarity: rarity,
      hpBonus: baseHp,
      attackBonus: baseAttack,
      defenseBonus: baseDefense,
      speedBonus: baseSpeed,
      effect: effect,
    );
  }

  /// 所有装备模板
  static const List<EquipmentTemplate> allTemplates = [
    // === 武器 ===
    EquipmentTemplate(
      name: '木剑',
      emoji: '🗡️',
      slot: EquipmentSlot.weapon,
      rarity: EquipmentRarity.common,
      baseAttack: 3,
    ),
    EquipmentTemplate(
      name: '铁剑',
      emoji: '⚔️',
      slot: EquipmentSlot.weapon,
      rarity: EquipmentRarity.rare,
      baseAttack: 8,
    ),
    EquipmentTemplate(
      name: '水晶剑',
      emoji: '💎',
      slot: EquipmentSlot.weapon,
      rarity: EquipmentRarity.epic,
      baseAttack: 18,
      effect: EquipmentEffect(type: EquipmentEffectType.criticalStrike, value: 0.15),
    ),
    EquipmentTemplate(
      name: '龙牙剑',
      emoji: '🐉',
      slot: EquipmentSlot.weapon,
      rarity: EquipmentRarity.legendary,
      baseAttack: 40,
      effect: EquipmentEffect(type: EquipmentEffectType.doubleAttack, value: 0.2),
    ),
    // === 护甲 ===
    EquipmentTemplate(
      name: '布甲',
      emoji: '🧥',
      slot: EquipmentSlot.armor,
      rarity: EquipmentRarity.common,
      baseHp: 15,
      baseDefense: 2,
    ),
    EquipmentTemplate(
      name: '铁甲',
      emoji: '🛡️',
      slot: EquipmentSlot.armor,
      rarity: EquipmentRarity.rare,
      baseHp: 40,
      baseDefense: 6,
    ),
    EquipmentTemplate(
      name: '海神甲',
      emoji: '🌊',
      slot: EquipmentSlot.armor,
      rarity: EquipmentRarity.epic,
      baseHp: 100,
      baseDefense: 15,
      effect: EquipmentEffect(type: EquipmentEffectType.damageReduction, value: 0.1),
    ),
    EquipmentTemplate(
      name: '龙鳞甲',
      emoji: '🐲',
      slot: EquipmentSlot.armor,
      rarity: EquipmentRarity.legendary,
      baseHp: 250,
      baseDefense: 35,
      effect: EquipmentEffect(type: EquipmentEffectType.counterAttack, value: 0.25),
    ),
    // === 饰品 ===
    EquipmentTemplate(
      name: '贝壳项链',
      emoji: '🐚',
      slot: EquipmentSlot.accessory,
      rarity: EquipmentRarity.common,
      baseSpeed: 5,
    ),
    EquipmentTemplate(
      name: '珍珠戒指',
      emoji: '💍',
      slot: EquipmentSlot.accessory,
      rarity: EquipmentRarity.rare,
      baseSpeed: 12,
      baseAttack: 3,
    ),
    EquipmentTemplate(
      name: '海洋之心',
      emoji: '💙',
      slot: EquipmentSlot.accessory,
      rarity: EquipmentRarity.epic,
      baseSpeed: 20,
      baseHp: 30,
      effect: EquipmentEffect(type: EquipmentEffectType.lifesteal, value: 0.1),
    ),
    EquipmentTemplate(
      name: '龙王之眼',
      emoji: '👁️',
      slot: EquipmentSlot.accessory,
      rarity: EquipmentRarity.legendary,
      baseSpeed: 35,
      baseAttack: 15,
      baseDefense: 10,
      effect: EquipmentEffect(type: EquipmentEffectType.criticalStrike, value: 0.25),
    ),
  ];

  /// 根据稀有度随机获取模板
  static EquipmentTemplate getRandomTemplate(EquipmentRarity rarity) {
    final templates = allTemplates.where((t) => t.rarity == rarity).toList();
    if (templates.isEmpty) return allTemplates.first;
    return templates[DateTime.now().millisecondsSinceEpoch % templates.length];
  }
}
