import 'dart:math';
import '../models/fish.dart';

/// 所有可钓到的鱼的配置
class FishData {
  // 使用单例 Random 避免重复创建
  static final Random _random = Random();

  static final List<FishTemplate> allFish = [
    // ========== 普通鱼 (Common) - 45% 概率 ==========
    // 淡水鱼
    FishTemplate(name: '鲤鱼', emoji: '🐟', rarity: Rarity.common, baseIncome: 1, baseValue: 8),
    FishTemplate(name: '草鱼', emoji: '🐟', rarity: Rarity.common, baseIncome: 1, baseValue: 10),
    FishTemplate(name: '鲶鱼', emoji: '🐟', rarity: Rarity.common, baseIncome: 2, baseValue: 12),
    FishTemplate(name: '泥鳅', emoji: '🐟', rarity: Rarity.common, baseIncome: 1, baseValue: 6),
    FishTemplate(name: '青鱼', emoji: '🐟', rarity: Rarity.common, baseIncome: 1, baseValue: 9),
    // 海水鱼
    FishTemplate(name: '小金鱼', emoji: '🐠', rarity: Rarity.common, baseIncome: 1, baseValue: 10),
    FishTemplate(name: '蓝鱼', emoji: '🐟', rarity: Rarity.common, baseIncome: 1, baseValue: 8),
    FishTemplate(name: '河豚', emoji: '🐡', rarity: Rarity.common, baseIncome: 2, baseValue: 15),
    FishTemplate(name: '热带鱼', emoji: '🐠', rarity: Rarity.common, baseIncome: 1, baseValue: 12),

    // ========== 稀有鱼 (Rare) - 30% 概率 ==========
    // 海洋生物
    FishTemplate(name: '海豚', emoji: '🐬', rarity: Rarity.rare, baseIncome: 5, baseValue: 50),
    FishTemplate(name: '鲸鱼', emoji: '🐋', rarity: Rarity.rare, baseIncome: 8, baseValue: 80),
    FishTemplate(name: '鲨鱼', emoji: '🦈', rarity: Rarity.rare, baseIncome: 6, baseValue: 60),
    FishTemplate(name: '剑鱼', emoji: '🐠', rarity: Rarity.rare, baseIncome: 7, baseValue: 70),
    FishTemplate(name: '海龟', emoji: '🐢', rarity: Rarity.rare, baseIncome: 4, baseValue: 55),
    FishTemplate(name: '海豹', emoji: '🦭', rarity: Rarity.rare, baseIncome: 5, baseValue: 65),
    FishTemplate(name: '企鹅', emoji: '🐧', rarity: Rarity.rare, baseIncome: 6, baseValue: 75),
    FishTemplate(name: '海马', emoji: '🦑', rarity: Rarity.rare, baseIncome: 4, baseValue: 45),
    FishTemplate(name: '飞鱼', emoji: '🐟', rarity: Rarity.rare, baseIncome: 5, baseValue: 58),

    // ========== 史诗鱼 (Epic) - 20% 概率 ==========
    // 深海生物
    FishTemplate(name: '章鱼', emoji: '🐙', rarity: Rarity.epic, baseIncome: 15, baseValue: 200),
    FishTemplate(name: '螃蟹', emoji: '🦀', rarity: Rarity.epic, baseIncome: 12, baseValue: 150),
    FishTemplate(name: '龙虾', emoji: '🦞', rarity: Rarity.epic, baseIncome: 18, baseValue: 250),
    FishTemplate(name: '水母', emoji: '🪼', rarity: Rarity.epic, baseIncome: 14, baseValue: 180),
    FishTemplate(name: '乌贼', emoji: '🦑', rarity: Rarity.epic, baseIncome: 16, baseValue: 220),
    FishTemplate(name: '蝠鲼', emoji: '🐠', rarity: Rarity.epic, baseIncome: 13, baseValue: 170),
    FishTemplate(name: '电鳗', emoji: '🐍', rarity: Rarity.epic, baseIncome: 17, baseValue: 240),
    FishTemplate(name: '海星', emoji: '⭐', rarity: Rarity.epic, baseIncome: 11, baseValue: 140),
    FishTemplate(name: '珊瑚鱼', emoji: '🐠', rarity: Rarity.epic, baseIncome: 15, baseValue: 210),

    // ========== 传说鱼 (Legendary) - 5% 概率 ==========
    // 神话生物
    FishTemplate(name: '美人鱼', emoji: '🧜‍♀️', rarity: Rarity.legendary, baseIncome: 50, baseValue: 1000),
    FishTemplate(name: '龙王', emoji: '🐉', rarity: Rarity.legendary, baseIncome: 100, baseValue: 2000),
    FishTemplate(name: '黄金鱼', emoji: '✨', rarity: Rarity.legendary, baseIncome: 80, baseValue: 1500),
    FishTemplate(name: '凤凰鱼', emoji: '🔥', rarity: Rarity.legendary, baseIncome: 70, baseValue: 1200),
    FishTemplate(name: '冰霜鱼', emoji: '❄️', rarity: Rarity.legendary, baseIncome: 75, baseValue: 1300),
    FishTemplate(name: '雷電鱼', emoji: '⚡', rarity: Rarity.legendary, baseIncome: 85, baseValue: 1600),
    FishTemplate(name: '暗影鱼', emoji: '🌑', rarity: Rarity.legendary, baseIncome: 90, baseValue: 1800),
    FishTemplate(name: '神圣鱼', emoji: '👼', rarity: Rarity.legendary, baseIncome: 65, baseValue: 1100),
    FishTemplate(name: '星尘鱼', emoji: '🌟', rarity: Rarity.legendary, baseIncome: 95, baseValue: 1900),
  ];

  /// 根据稀有度概率随机获取一条鱼
  static FishTemplate getRandomFish(double rareBonus) {
    final random = _random.nextInt(100);
    Rarity rarity;

    // 基础概率 + 加成
    final legendaryChance = (5 + rareBonus * 100).clamp(0, 15).toInt();
    final epicChance = (20 + rareBonus * 50).clamp(0, 35).toInt();
    final rareChance = (30 + rareBonus * 30).clamp(0, 50).toInt();

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
    final index = _random.nextInt(fishOfRarity.length);
    return fishOfRarity[index];
  }

  /// 获取指定稀有度的所有鱼
  static List<FishTemplate> getFishByRarity(Rarity rarity) {
    return allFish.where((f) => f.rarity == rarity).toList();
  }

  /// 获取鱼类总数
  static int get totalFishCount => allFish.length;

  /// 获取各稀有度数量
  static Map<Rarity, int> get fishCountByRarity => {
    Rarity.common: allFish.where((f) => f.rarity == Rarity.common).length,
    Rarity.rare: allFish.where((f) => f.rarity == Rarity.rare).length,
    Rarity.epic: allFish.where((f) => f.rarity == Rarity.epic).length,
    Rarity.legendary: allFish.where((f) => f.rarity == Rarity.legendary).length,
  };
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
