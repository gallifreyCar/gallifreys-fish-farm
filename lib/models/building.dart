/// 建筑类型
enum BuildingType {
  dock,       // 钓鱼码头
  shop,       // 商店
  farm,       // 农田
  mine,       // 矿场
  training,   // 训练场
  temple,     // 神殿
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

  /// 获取产出速度（每秒）
  int get outputRate {
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
