/// 转生加成类型
enum PrestigeBonusType {
  incomeBonus,       // 收入加成
  fishingSpeed,      // 钓鱼速度
  rareFishChance,    // 稀有鱼概率
  battlePower,       // 战斗力加成
  expGain,           // 经验获取
  equipmentDrop,     // 装备掉落率
}

/// 转生配置
class PrestigeConfig {
  /// 每次转生获得的基础点数
  static const int basePrestigePoints = 1;

  /// 转生所需最低金币（每次转生翻倍）
  static const int baseCost = 10000;

  /// 转生加成效果
  static const Map<PrestigeBonusType, double> bonusPerPoint = {
    PrestigeBonusType.incomeBonus: 0.05,      // 每点 +5% 收入
    PrestigeBonusType.fishingSpeed: 0.03,     // 每点 +3% 钓鱼速度
    PrestigeBonusType.rareFishChance: 0.02,   // 每点 +2% 稀有鱼概率
    PrestigeBonusType.battlePower: 0.05,      // 每点 +5% 战斗力
    PrestigeBonusType.expGain: 0.05,          // 每点 +5% 经验获取
    PrestigeBonusType.equipmentDrop: 0.03,    // 每点 +3% 装备掉落率
  };

  /// 计算转生需要的金币
  static int getPrestigeCost(int currentPrestigeLevel) {
    return baseCost * (1 << currentPrestigeLevel); // 2的n次方
  }

  /// 计算转生获得的点数（根据累计金币）
  static int calculatePrestigePoints(int totalCoinsEarned) {
    // 每10万金币获得1点
    return (totalCoinsEarned ~/ 100000).clamp(1, 10);
  }
}

/// 转生天赋节点
class PrestigeTalent {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final PrestigeBonusType type;
  final int maxLevel;
  final int costPerLevel;

  const PrestigeTalent({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.type,
    this.maxLevel = 10,
    this.costPerLevel = 1,
  });

  /// 获取当前等级的效果值
  double getEffect(int level) {
    return PrestigeConfig.bonusPerPoint[type]! * level;
  }

  /// 获取效果描述
  String getEffectDescription(int level) {
    final effect = getEffect(level) * 100;
    switch (type) {
      case PrestigeBonusType.incomeBonus:
        return '+${effect.toStringAsFixed(0)}% 收入';
      case PrestigeBonusType.fishingSpeed:
        return '+${effect.toStringAsFixed(0)}% 钓鱼速度';
      case PrestigeBonusType.rareFishChance:
        return '+${effect.toStringAsFixed(0)}% 稀有鱼概率';
      case PrestigeBonusType.battlePower:
        return '+${effect.toStringAsFixed(0)}% 战斗力';
      case PrestigeBonusType.expGain:
        return '+${effect.toStringAsFixed(0)}% 经验获取';
      case PrestigeBonusType.equipmentDrop:
        return '+${effect.toStringAsFixed(0)}% 装备掉落';
    }
  }

  /// 所有天赋节点
  static const List<PrestigeTalent> allTalents = [
    PrestigeTalent(
      id: 'income_master',
      name: '财富大师',
      description: '提升所有收入',
      emoji: '💰',
      type: PrestigeBonusType.incomeBonus,
      maxLevel: 20,
      costPerLevel: 1,
    ),
    PrestigeTalent(
      id: 'fishing_expert',
      name: '钓鱼专家',
      description: '提升钓鱼速度',
      emoji: '🎣',
      type: PrestigeBonusType.fishingSpeed,
      maxLevel: 15,
      costPerLevel: 1,
    ),
    PrestigeTalent(
      id: 'lucky_angler',
      name: '幸运钓手',
      description: '提升稀有鱼概率',
      emoji: '🍀',
      type: PrestigeBonusType.rareFishChance,
      maxLevel: 15,
      costPerLevel: 2,
    ),
    PrestigeTalent(
      id: 'battle_master',
      name: '战斗大师',
      description: '提升所有鱼宠战斗力',
      emoji: '⚔️',
      type: PrestigeBonusType.battlePower,
      maxLevel: 20,
      costPerLevel: 1,
    ),
    PrestigeTalent(
      id: 'quick_learner',
      name: '快速学习',
      description: '提升经验获取',
      emoji: '📚',
      type: PrestigeBonusType.expGain,
      maxLevel: 10,
      costPerLevel: 2,
    ),
    PrestigeTalent(
      id: 'treasure_hunter',
      name: '宝藏猎人',
      description: '提升装备掉落率',
      emoji: '🎁',
      type: PrestigeBonusType.equipmentDrop,
      maxLevel: 10,
      costPerLevel: 3,
    ),
  ];
}

/// 转生数据（保存玩家天赋加点）
class PrestigeData {
  final int level;
  final int points;
  final int totalCoinsEarned;  // 累计获得的金币（用于计算转生点数）
  final Map<String, int> talentLevels;  // talentId -> level

  const PrestigeData({
    this.level = 0,
    this.points = 0,
    this.totalCoinsEarned = 0,
    this.talentLevels = const {},
  });

  PrestigeData copyWith({
    int? level,
    int? points,
    int? totalCoinsEarned,
    Map<String, int>? talentLevels,
  }) {
    return PrestigeData(
      level: level ?? this.level,
      points: points ?? this.points,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      talentLevels: talentLevels ?? this.talentLevels,
    );
  }

  /// 获取特定天赋的等级
  int getTalentLevel(String talentId) {
    return talentLevels[talentId] ?? 0;
  }

  /// 计算特定加成的总值
  double getTotalBonus(PrestigeBonusType type) {
    double total = 0;
    for (final talent in PrestigeTalent.allTalents) {
      if (talent.type == type) {
        total += talent.getEffect(getTalentLevel(talent.id));
      }
    }
    return total;
  }

  Map<String, dynamic> toJson() => {
    'level': level,
    'points': points,
    'totalCoinsEarned': totalCoinsEarned,
    'talentLevels': talentLevels,
  };

  factory PrestigeData.fromJson(Map<String, dynamic> json) {
    return PrestigeData(
      level: json['level'] ?? 0,
      points: json['points'] ?? 0,
      totalCoinsEarned: json['totalCoinsEarned'] ?? 0,
      talentLevels: Map<String, int>.from(json['talentLevels'] ?? {}),
    );
  }
}
