import 'fish.dart';
import 'equipment.dart' as fish_equipment;
import 'prestige.dart';

/// 钓鱼装备模型（鱼竿、鱼饵、鱼池）
class FishingEquipment {
  int rodLevel;      // 鱼竿等级
  int baitLevel;     // 鱼饵等级
  int pondLevel;     // 鱼池等级

  FishingEquipment({
    this.rodLevel = 1,
    this.baitLevel = 1,
    this.pondLevel = 1,
  });

  /// 鱼竿升级费用
  int get rodUpgradeCost => rodLevel * 100;

  /// 鱼饵升级费用
  int get baitUpgradeCost => baitLevel * 80;

  /// 鱼池升级费用
  int get pondUpgradeCost => pondLevel * 200;

  /// 鱼池容量
  int get pondCapacity => 10 + (pondLevel - 1) * 5;

  /// 钓鱼速度加成
  double get fishingSpeedBonus => 1.0 + (rodLevel - 1) * 0.1;

  /// 稀有鱼概率加成
  double get rareFishBonus => (baitLevel - 1) * 0.05;

  Map<String, dynamic> toJson() => {
    'rodLevel': rodLevel,
    'baitLevel': baitLevel,
    'pondLevel': pondLevel,
  };

  factory FishingEquipment.fromJson(Map<String, dynamic> json) => FishingEquipment(
    rodLevel: json['rodLevel'] ?? 1,
    baitLevel: json['baitLevel'] ?? 1,
    pondLevel: json['pondLevel'] ?? 1,
  );
}

/// 玩家数据模型
class Player {
  int coins;                  // 金币
  int fishFood;               // 鱼食
  List<Fish> ownedFish;       // 拥有的鱼
  FishingEquipment equipment; // 钓鱼装备
  List<fish_equipment.Equipment> inventory;  // 装备背包
  DateTime lastSaveTime;      // 上次保存时间
  int totalFishCaught;        // 总共钓到的鱼数量
  int totalBossDefeated;      // 击败Boss总数
  PrestigeData prestige;      // 转生数据

  Player({
    this.coins = 0,
    this.fishFood = 10,
    List<Fish>? ownedFish,
    FishingEquipment? equipment,
    List<fish_equipment.Equipment>? inventory,
    DateTime? lastSaveTime,
    this.totalFishCaught = 0,
    this.totalBossDefeated = 0,
    PrestigeData? prestige,
  })  : ownedFish = ownedFish ?? [],
        equipment = equipment ?? FishingEquipment(),
        inventory = inventory ?? [],
        lastSaveTime = lastSaveTime ?? DateTime.now(),
        prestige = prestige ?? const PrestigeData();

  /// 每秒收入（所有工作中的鱼）
  int get incomePerSecond {
    return ownedFish
        .where((fish) => fish.currentJob != JobType.idle)
        .fold(0, (sum, fish) => sum + fish.income);
  }

  /// 鱼池是否已满
  bool get isPondFull => ownedFish.length >= equipment.pondCapacity;

  /// 添加鱼
  bool addFish(Fish fish) {
    if (isPondFull) return false;
    ownedFish.add(fish);
    return true;
  }

  /// 移除鱼（出售）
  int sellFish(String fishId) {
    final index = ownedFish.indexWhere((f) => f.id == fishId);
    if (index == -1) return 0;
    final fish = ownedFish[index];
    ownedFish.removeAt(index);
    coins += fish.baseValue * fish.level;
    return fish.baseValue * fish.level;
  }

  Map<String, dynamic> toJson() => {
    'coins': coins,
    'fishFood': fishFood,
    'ownedFish': ownedFish.map((f) => f.toJson()).toList(),
    'equipment': equipment.toJson(),
    'inventory': inventory.map((e) => e.toJson()).toList(),
    'lastSaveTime': lastSaveTime.toIso8601String(),
    'totalFishCaught': totalFishCaught,
    'totalBossDefeated': totalBossDefeated,
    'prestige': prestige.toJson(),
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    coins: json['coins'] ?? 0,
    fishFood: json['fishFood'] ?? 10,
    ownedFish: (json['ownedFish'] as List?)
        ?.map((f) => Fish.fromJson(f))
        .toList() ?? [],
    equipment: json['equipment'] != null
        ? FishingEquipment.fromJson(json['equipment'])
        : FishingEquipment(),
    inventory: (json['inventory'] as List?)
        ?.map((e) => fish_equipment.Equipment.fromJson(e))
        .toList() ?? [],
    lastSaveTime: json['lastSaveTime'] != null
        ? DateTime.parse(json['lastSaveTime'])
        : DateTime.now(),
    totalFishCaught: json['totalFishCaught'] ?? 0,
    totalBossDefeated: json['totalBossDefeated'] ?? 0,
    prestige: json['prestige'] != null
        ? PrestigeData.fromJson(json['prestige'])
        : const PrestigeData(),
  );
}
