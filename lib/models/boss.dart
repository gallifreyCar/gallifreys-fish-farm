import 'fish.dart';

/// Boss 难度层级
enum BossTier {
  easy,    // 初级
  medium,  // 中级
  hard,    // 高级
}

/// Boss数据模型
class Boss {
  final String id;
  final String name;
  final String emoji;
  final BossTier tier;
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
    this.tier = BossTier.easy,
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
    'tier': tier.index,
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
    tier: BossTier.values[json['tier'] ?? 0],
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

  /// 预设Boss列表 - 12个Boss
  static List<Boss> get defaultBosses => [
    // ========== Tier 1: 初级 Boss (推荐战力 100-500) ==========
    Boss(
      id: 'crab_general',
      name: '螃蟹将军',
      emoji: '🦀',
      tier: BossTier.easy,
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
      id: 'shrimp_commander',
      name: '虾兵统领',
      emoji: '🦐',
      tier: BossTier.easy,
      maxHp: 800,
      attack: 25,
      defense: 8,
      requiredPower: 200,
      rewards: [
        BossReward(type: RewardType.coins, amount: 200),
        BossReward(type: RewardType.materials, amount: 10),
      ],
    ),
    Boss(
      id: 'shell_guardian',
      name: '贝壳守卫',
      emoji: '🐚',
      tier: BossTier.easy,
      maxHp: 1200,
      attack: 30,
      defense: 15,
      requiredPower: 350,
      rewards: [
        BossReward(type: RewardType.coins, amount: 300),
        BossReward(type: RewardType.fishRarity, rarity: Rarity.rare, amount: 2),
      ],
    ),
    Boss(
      id: 'pufferfish_captain',
      name: '河豚队长',
      emoji: '🐡',
      tier: BossTier.easy,
      maxHp: 1800,
      attack: 40,
      defense: 10,
      requiredPower: 500,
      rewards: [
        BossReward(type: RewardType.coins, amount: 400),
        BossReward(type: RewardType.materials, amount: 20),
      ],
    ),

    // ========== Tier 2: 中级 Boss (推荐战力 500-2000) ==========
    Boss(
      id: 'shark_pirate',
      name: '鲨鱼海盗',
      emoji: '🦈',
      tier: BossTier.medium,
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
      tier: BossTier.medium,
      maxHp: 5000,
      attack: 70,
      defense: 25,
      requiredPower: 1000,
      rewards: [
        BossReward(type: RewardType.coins, amount: 1500),
        BossReward(type: RewardType.materials, amount: 30),
        BossReward(type: RewardType.fishRarity, rarity: Rarity.epic, amount: 1),
      ],
    ),
    Boss(
      id: 'whale_lord',
      name: '鲸鱼领主',
      emoji: '🐋',
      tier: BossTier.medium,
      maxHp: 8000,
      attack: 100,
      defense: 30,
      requiredPower: 1500,
      rewards: [
        BossReward(type: RewardType.coins, amount: 2000),
        BossReward(type: RewardType.materials, amount: 50),
        BossReward(type: RewardType.fishRarity, rarity: Rarity.epic, amount: 1),
      ],
    ),
    Boss(
      id: 'ancient_turtle',
      name: '千年龟仙',
      emoji: '🐢',
      tier: BossTier.medium,
      maxHp: 10000,
      attack: 60,
      defense: 50,
      requiredPower: 2000,
      rewards: [
        BossReward(type: RewardType.coins, amount: 2500),
        BossReward(type: RewardType.fishRarity, rarity: Rarity.epic, amount: 2),
      ],
    ),

    // ========== Tier 3: 高级 Boss (推荐战力 2000+) ==========
    Boss(
      id: 'deep_sea_overlord',
      name: '深海霸主',
      emoji: '🦑',
      tier: BossTier.hard,
      maxHp: 20000,
      attack: 150,
      defense: 40,
      requiredPower: 3000,
      rewards: [
        BossReward(type: RewardType.coins, amount: 5000),
        BossReward(type: RewardType.fishRarity, rarity: Rarity.legendary, amount: 1),
      ],
    ),
    Boss(
      id: 'inferno_squid',
      name: '炼狱乌贼',
      emoji: '🔥',
      tier: BossTier.hard,
      maxHp: 30000,
      attack: 180,
      defense: 35,
      requiredPower: 4000,
      rewards: [
        BossReward(type: RewardType.coins, amount: 8000),
        BossReward(type: RewardType.artifact, amount: 1),
        BossReward(type: RewardType.fishRarity, rarity: Rarity.legendary, amount: 1),
      ],
    ),
    Boss(
      id: 'siren_queen',
      name: '海妖女王',
      emoji: '🧜‍♀️',
      tier: BossTier.hard,
      maxHp: 40000,
      attack: 200,
      defense: 50,
      requiredPower: 5000,
      rewards: [
        BossReward(type: RewardType.coins, amount: 10000),
        BossReward(type: RewardType.fishRarity, rarity: Rarity.legendary, amount: 1),
      ],
    ),
    Boss(
      id: 'dragon_king',
      name: '海龙王',
      emoji: '🐉',
      tier: BossTier.hard,
      maxHp: 50000,
      attack: 250,
      defense: 60,
      requiredPower: 8000,
      rewards: [
        BossReward(type: RewardType.coins, amount: 20000),
        BossReward(type: RewardType.fishRarity, rarity: Rarity.legendary, amount: 1),
        BossReward(type: RewardType.artifact, amount: 1),
      ],
    ),
  ];

  /// 获取指定难度的Boss
  static List<Boss> getBossesByTier(BossTier tier) {
    return defaultBosses.where((b) => b.tier == tier).toList();
  }

  /// Boss总数
  static int get totalBossCount => defaultBosses.length;
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
