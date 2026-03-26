import 'fish.dart';

/// Boss数据模型
class Boss {
  final String id;
  final String name;
  final String emoji;
  final int maxHp;
  final int attack;
  final int defense;
  final int requiredPower;   // 推荐战力
  final List<BossReward> rewards;
  final bool isUnlocked;

  // 战斗中状态
  int currentHp;
  bool isDefeated;

  Boss({
    required this.id,
    required this.name,
    required this.emoji,
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.requiredPower,
    required this.rewards,
    this.isUnlocked = false,
    int? currentHp,
    this.isDefeated = false,
  }) : currentHp = currentHp ?? maxHp;

  /// 受到伤害
  int takeDamage(int damage) {
    final actualDamage = (damage - defense).clamp(1, damage);
    currentHp = (currentHp - actualDamage).clamp(0, maxHp);
    return actualDamage;
  }

  /// 是否存活
  bool get isAlive => currentHp > 0;

  /// 生命值百分比
  double get hpPercent => currentHp / maxHp;

  /// 重置Boss状态
  void reset() {
    currentHp = maxHp;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'maxHp': maxHp,
    'attack': attack,
    'defense': defense,
    'requiredPower': requiredPower,
    'rewards': rewards.map((r) => r.toJson()).toList(),
    'isUnlocked': isUnlocked,
    'currentHp': currentHp,
    'isDefeated': isDefeated,
  };

  factory Boss.fromJson(Map<String, dynamic> json) => Boss(
    id: json['id'],
    name: json['name'],
    emoji: json['emoji'],
    maxHp: json['maxHp'],
    attack: json['attack'],
    defense: json['defense'],
    requiredPower: json['requiredPower'],
    rewards: (json['rewards'] as List)
        .map((r) => BossReward.fromJson(r))
        .toList(),
    isUnlocked: json['isUnlocked'] ?? false,
    currentHp: json['currentHp'],
    isDefeated: json['isDefeated'] ?? false,
  );

  /// 预设Boss列表
  static List<Boss> get defaultBosses => [
    Boss(
      id: 'crab_general',
      name: '螃蟹将军',
      emoji: '🦀',
      maxHp: 500,
      attack: 20,
      defense: 5,
      requiredPower: 100,
      isUnlocked: true,
      rewards: [
        BossReward(type: RewardType.coins, amount: 100),
        BossReward(type: RewardType.fishRarity, rarity: Rarity.rare, amount: 1),
      ],
    ),
    Boss(
      id: 'shark_pirate',
      name: '鲨鱼海盗',
      emoji: '🦈',
      maxHp: 2000,
      attack: 50,
      defense: 15,
      requiredPower: 500,
      rewards: [
        BossReward(type: RewardType.coins, amount: 500),
        BossReward(type: RewardType.materials, amount: 10),
        BossReward(type: RewardType.fishRarity, rarity: Rarity.rare, amount: 2),
      ],
    ),
    Boss(
      id: 'octopus_demon',
      name: '章鱼魔王',
      emoji: '🐙',
      maxHp: 8000,
      attack: 100,
      defense: 30,
      requiredPower: 1500,
      rewards: [
        BossReward(type: RewardType.coins, amount: 2000),
        BossReward(type: RewardType.materials, amount: 30),
        BossReward(type: RewardType.fishRarity, rarity: Rarity.epic, amount: 1),
      ],
    ),
    Boss(
      id: 'dragon_king',
      name: '海龙王',
      emoji: '🐉',
      maxHp: 30000,
      attack: 200,
      defense: 50,
      requiredPower: 5000,
      rewards: [
        BossReward(type: RewardType.coins, amount: 10000),
        BossReward(type: RewardType.materials, amount: 100),
        BossReward(type: RewardType.fishRarity, rarity: Rarity.legendary, amount: 1),
        BossReward(type: RewardType.artifact, amount: 1),
      ],
    ),
  ];
}

/// 奖励类型
enum RewardType {
  coins,        // 金币
  materials,    // 材料
  fishRarity,   // 特定稀有度的鱼
  artifact,     // 神器碎片
}

/// Boss奖励
class BossReward {
  final RewardType type;
  final int amount;
  final Rarity? rarity;

  BossReward({
    required this.type,
    required this.amount,
    this.rarity,
  });

  String get description {
    switch (type) {
      case RewardType.coins:
        return '$amount 金币';
      case RewardType.materials:
        return '$amount 材料';
      case RewardType.fishRarity:
        return '${_rarityName(rarity!)}鱼苗 x$amount';
      case RewardType.artifact:
        return '神器碎片 x$amount';
    }
  }

  String _rarityName(Rarity r) {
    return {
      Rarity.common: '普通',
      Rarity.rare: '稀有',
      Rarity.epic: '史诗',
      Rarity.legendary: '传说',
    }[r]!;
  }

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'amount': amount,
    'rarity': rarity?.index,
  };

  factory BossReward.fromJson(Map<String, dynamic> json) => BossReward(
    type: RewardType.values[json['type']],
    amount: json['amount'],
    rarity: json['rarity'] != null ? Rarity.values[json['rarity']] : null,
  );
}
