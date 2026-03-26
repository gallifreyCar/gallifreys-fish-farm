/// 建筑类型
enum BuildingType {
  dock,       // 钓鱼码头
  shop,       // 商店
  farm,       // 农田
  mine,       // 矿场
  training,   // 训练场
  temple,     // 神殿
}

/// 建筑协同类型
enum SynergyType {
  production,   // 产出加成
  efficiency,   // 效率加成
  quality,      // 质量加成
}

/// 建筑协同配置
class BuildingSynergy {
  final BuildingType sourceType;
  final BuildingType targetType;
  final SynergyType synergyType;
  final double bonusPerLevel;  // 每级加成比例
  final String description;

  const BuildingSynergy({
    required this.sourceType,
    required this.targetType,
    required this.synergyType,
    required this.bonusPerLevel,
    required this.description,
  });

  /// 预设协同关系
  static const List<BuildingSynergy> defaultSynergies = [
    // 码头 + 商店 = 更高的鱼售价
    BuildingSynergy(
      sourceType: BuildingType.dock,
      targetType: BuildingType.shop,
      synergyType: SynergyType.quality,
      bonusPerLevel: 0.05,
      description: '渔获在商店卖出更高价格',
    ),
    // 农田 + 码头 = 钓鱼速度提升
    BuildingSynergy(
      sourceType: BuildingType.farm,
      targetType: BuildingType.dock,
      synergyType: SynergyType.efficiency,
      bonusPerLevel: 0.03,
      description: '鱼食充足，钓鱼效率提升',
    ),
    // 矿场 + 训练场 = 训练效果提升
    BuildingSynergy(
      sourceType: BuildingType.mine,
      targetType: BuildingType.training,
      synergyType: SynergyType.efficiency,
      bonusPerLevel: 0.08,
      description: '矿产强化训练设施',
    ),
    // 神殿 + 所有建筑 = 产出加成
    BuildingSynergy(
      sourceType: BuildingType.temple,
      targetType: BuildingType.shop,
      synergyType: SynergyType.production,
      bonusPerLevel: 0.10,
      description: '神殿庇佑，商店收入增加',
    ),
  ];
}

/// 建筑数据模型
class Building {
  final String id;
  final BuildingType type;
  final String name;
  final String emoji;
  int level;
  int posX;
  int posY;
  bool isUnlocked;

  Building({
    required this.id,
    required this.type,
    required this.name,
    required this.emoji,
    this.level = 1,
    this.posX = 0,
    this.posY = 0,
    this.isUnlocked = false,
  });

  /// 获取建筑大小
  (int width, int height) get size {
    switch (type) {
      case BuildingType.dock:
        return (2, 2);
      case BuildingType.shop:
        return (2, 2);
      case BuildingType.farm:
        return (3, 2);
      case BuildingType.mine:
        return (2, 3);
      case BuildingType.training:
        return (3, 3);
      case BuildingType.temple:
        return (4, 4);
    }
  }

  /// 获取升级费用
  int get upgradeCost {
    final baseCosts = {
      BuildingType.dock: 50,
      BuildingType.shop: 100,
      BuildingType.farm: 150,
      BuildingType.mine: 200,
      BuildingType.training: 300,
      BuildingType.temple: 500,
    };
    return baseCosts[type]! * level;
  }

  /// 获取解锁费用
  int get unlockCost {
    return {
      BuildingType.dock: 0,
      BuildingType.shop: 100,
      BuildingType.farm: 200,
      BuildingType.mine: 500,
      BuildingType.training: 1000,
      BuildingType.temple: 2000,
    }[type]!;
  }

  /// 获取产出类型
  String get outputType {
    switch (type) {
      case BuildingType.dock:
        return 'fish';
      case BuildingType.shop:
        return 'coins';
      case BuildingType.farm:
        return 'food';
      case BuildingType.mine:
        return 'materials';
      case BuildingType.training:
        return 'exp';
      case BuildingType.temple:
        return 'rareFish';
    }
  }

  /// 获取产出速度（每秒）- 基础值
  int get baseOutputRate {
    final baseRates = {
      BuildingType.dock: 0,
      BuildingType.shop: 2,
      BuildingType.farm: 1,
      BuildingType.mine: 1,
      BuildingType.training: 0,
      BuildingType.temple: 0,
    };
    return baseRates[type]! * level;
  }

  /// 计算协同加成后的产出
  int getOutputRate(List<Building> allBuildings) {
    var rate = baseOutputRate.toDouble();

    // 应用协同加成
    for (final synergy in BuildingSynergy.defaultSynergies) {
      if (synergy.targetType != type) continue;

      // 查找源建筑
      final sourceBuilding = allBuildings.firstWhere(
        (b) => b.type == synergy.sourceType && b.isUnlocked,
        orElse: () => this,
      );

      if (sourceBuilding.isUnlocked && sourceBuilding.id != id) {
        final bonus = synergy.bonusPerLevel * sourceBuilding.level;
        rate *= (1 + bonus);
      }
    }

    return rate.round();
  }

  /// 获取当前激活的协同描述列表
  List<String> getActiveSynergies(List<Building> allBuildings) {
    final result = <String>[];

    for (final synergy in BuildingSynergy.defaultSynergies) {
      if (synergy.targetType != type) continue;

      final sourceBuilding = allBuildings.firstWhere(
        (b) => b.type == synergy.sourceType && b.isUnlocked,
        orElse: () => this,
      );

      if (sourceBuilding.isUnlocked && sourceBuilding.id != id) {
        final bonus = synergy.bonusPerLevel * sourceBuilding.level;
        result.add('${sourceBuilding.emoji} ${synergy.description} (+${(bonus * 100).toStringAsFixed(0)}%)');
      }
    }

    return result;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'name': name,
    'emoji': emoji,
    'level': level,
    'posX': posX,
    'posY': posY,
    'isUnlocked': isUnlocked,
  };

  factory Building.fromJson(Map<String, dynamic> json) => Building(
    id: json['id'],
    type: BuildingType.values[json['type']],
    name: json['name'],
    emoji: json['emoji'],
    level: json['level'] ?? 1,
    posX: json['posX'] ?? 0,
    posY: json['posY'] ?? 0,
    isUnlocked: json['isUnlocked'] ?? false,
  );

  /// 预设建筑列表
  static List<Building> get defaultBuildings => [
    Building(
      id: 'dock_1',
      type: BuildingType.dock,
      name: '钓鱼码头',
      emoji: '🎣',
      posX: 50,
      posY: 150,
      isUnlocked: true,
    ),
    Building(
      id: 'shop_1',
      type: BuildingType.shop,
      name: '杂货铺',
      emoji: '🏪',
      posX: 200,
      posY: 100,
    ),
    Building(
      id: 'farm_1',
      type: BuildingType.farm,
      name: '鱼食田',
      emoji: '🌾',
      posX: 200,
      posY: 200,
    ),
    Building(
      id: 'mine_1',
      type: BuildingType.mine,
      name: '珍珠矿',
      emoji: '⛏️',
      posX: 350,
      posY: 150,
    ),
    Building(
      id: 'training_1',
      type: BuildingType.training,
      name: '训练场',
      emoji: '⚔️',
      posX: 350,
      posY: 280,
    ),
    Building(
      id: 'temple_1',
      type: BuildingType.temple,
      name: '召唤神殿',
      emoji: '🏛️',
      posX: 480,
      posY: 200,
    ),
  ];
}
