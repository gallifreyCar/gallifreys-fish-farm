import '../models/fish.dart';

/// 所有可钓到的鱼的配置
class FishData {
  static final List<FishTemplate> allFish = [
    // 普通鱼 (70%概率)
    FishTemplate(
      name: '小金鱼',
      emoji: '🐠',
      rarity: Rarity.common,
      baseIncome: 1,
      baseValue: 10,
    ),
    FishTemplate(
      name: '蓝鱼',
      emoji: '🐟',
      rarity: Rarity.common,
      baseIncome: 1,
      baseValue: 8,
    ),
    FishTemplate(
      name: '河豚',
      emoji: '🐡',
      rarity: Rarity.common,
      baseIncome: 2,
      baseValue: 15,
    ),
    FishTemplate(
      name: '热带鱼',
      emoji: '🐠',
      rarity: Rarity.common,
      baseIncome: 1,
      baseValue: 12,
    ),

    // 稀有鱼 (20%概率)
    FishTemplate(
      name: '海豚',
      emoji: '🐬',
      rarity: Rarity.rare,
      baseIncome: 5,
      baseValue: 50,
    ),
    FishTemplate(
      name: '鲸鱼',
      emoji: '🐋',
      rarity: Rarity.rare,
      baseIncome: 8,
      baseValue: 80,
    ),
    FishTemplate(
      name: '鲨鱼',
      emoji: '🦈',
      rarity: Rarity.rare,
      baseIncome: 6,
      baseValue: 60,
    ),

    // 史诗鱼 (8%概率)
    FishTemplate(
      name: '章鱼',
      emoji: '🐙',
      rarity: Rarity.epic,
      baseIncome: 15,
      baseValue: 200,
    ),
    FishTemplate(
      name: '螃蟹',
      emoji: '🦀',
      rarity: Rarity.epic,
      baseIncome: 12,
      baseValue: 150,
    ),
    FishTemplate(
      name: '龙虾',
      emoji: '🦞',
      rarity: Rarity.epic,
      baseIncome: 18,
      baseValue: 250,
    ),

    // 传说鱼 (2%概率)
    FishTemplate(
      name: '美人鱼',
      emoji: '🧜‍♀️',
      rarity: Rarity.legendary,
      baseIncome: 50,
      baseValue: 1000,
    ),
    FishTemplate(
      name: '龙王',
      emoji: '🐉',
      rarity: Rarity.legendary,
      baseIncome: 100,
      baseValue: 2000,
    ),
    FishTemplate(
      name: '黄金鱼',
      emoji: '✨',
      rarity: Rarity.legendary,
      baseIncome: 80,
      baseValue: 1500,
    ),
  ];

  /// 根据稀有度概率随机获取一条鱼
  static FishTemplate getRandomFish(double rareBonus) {
    final random = DateTime.now().microsecondsSinceEpoch % 100;
    Rarity rarity;

    // 基础概率 + 加成
    final legendaryChance = (2 + rareBonus * 100).clamp(0, 10).toInt();
    final epicChance = (8 + rareBonus * 50).clamp(0, 20).toInt();
    final rareChance = (20 + rareBonus * 30).clamp(0, 40).toInt();

    if (random < legendaryChance) {
      rarity = Rarity.legendary;
    } else if (random < legendaryChance + epicChance) {
      rarity = Rarity.epic;
    } else if (random < legendaryChance + epicChance + rareChance) {
      rarity = Rarity.rare;
    } else {
      rarity = Rarity.common;
    }

    // 获取该稀有度的所有鱼
    final fishOfRarity = allFish.where((f) => f.rarity == rarity).toList();
    final index = DateTime.now().microsecondsSinceEpoch % fishOfRarity.length;
    return fishOfRarity[index];
  }
}

/// 鱼模板（用于生成鱼实例）
class FishTemplate {
  final String name;
  final String emoji;
  final Rarity rarity;
  final int baseIncome;
  final int baseValue;

  const FishTemplate({
    required this.name,
    required this.emoji,
    required this.rarity,
    required this.baseIncome,
    required this.baseValue,
  });

  /// 创建鱼实例
  Fish createFish() {
    return Fish(
      id: '${name}_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      emoji: emoji,
      rarity: rarity,
      baseIncome: baseIncome,
      baseValue: baseValue,
    );
  }
}
