/// 成就类型
enum AchievementType {
  fishing,      // 钓鱼相关
  battle,       // 战斗相关
  economy,      // 经济相关
  collection,   // 收集相关
  social,       // 社交相关
}

/// 成就定义
class Achievement {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final AchievementType type;
  final int targetValue;      // 目标数值
  final int rewardCoins;      // 金币奖励
  final int rewardFishFood;   // 鱼食奖励
  final String? rewardFishRarity; // 奖励鱼的稀有度

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.type,
    required this.targetValue,
    this.rewardCoins = 0,
    this.rewardFishFood = 0,
    this.rewardFishRarity,
  });

  /// 预设成就列表
  static const List<Achievement> allAchievements = [
    // 钓鱼成就
    Achievement(
      id: 'first_catch',
      name: '初出茅庐',
      description: '钓到第一条鱼',
      emoji: '🎣',
      type: AchievementType.fishing,
      targetValue: 1,
      rewardCoins: 50,
    ),
    Achievement(
      id: 'fisherman_100',
      name: '钓鱼达人',
      description: '累计钓到100条鱼',
      emoji: '🐟',
      type: AchievementType.fishing,
      targetValue: 100,
      rewardCoins: 500,
      rewardFishFood: 20,
    ),
    Achievement(
      id: 'fisherman_1000',
      name: '钓鱼大师',
      description: '累计钓到1000条鱼',
      emoji: '🏅',
      type: AchievementType.fishing,
      targetValue: 1000,
      rewardCoins: 5000,
      rewardFishRarity: 'rare',
    ),

    // 战斗成就
    Achievement(
      id: 'first_boss',
      name: '初战告捷',
      description: '击败第一个Boss',
      emoji: '⚔️',
      type: AchievementType.battle,
      targetValue: 1,
      rewardCoins: 100,
    ),
    Achievement(
      id: 'boss_slayer',
      name: 'Boss克星',
      description: '击败所有Boss',
      emoji: '👑',
      type: AchievementType.battle,
      targetValue: 4,
      rewardCoins: 10000,
      rewardFishRarity: 'legendary',
    ),

    // 经济成就
    Achievement(
      id: 'rich_1000',
      name: '小富翁',
      description: '累计获得1000金币',
      emoji: '💰',
      type: AchievementType.economy,
      targetValue: 1000,
      rewardCoins: 100,
    ),
    Achievement(
      id: 'rich_100000',
      name: '大富翁',
      description: '累计获得100000金币',
      emoji: '💎',
      type: AchievementType.economy,
      targetValue: 100000,
      rewardCoins: 10000,
      rewardFishFood: 100,
    ),

    // 收集成就
    Achievement(
      id: 'collector_10',
      name: '小小收藏家',
      description: '拥有10条鱼宠',
      emoji: '📚',
      type: AchievementType.collection,
      targetValue: 10,
      rewardCoins: 200,
    ),
    Achievement(
      id: 'rare_collector',
      name: '稀有收藏家',
      description: '拥有5条稀有或以上品质的鱼',
      emoji: '⭐',
      type: AchievementType.collection,
      targetValue: 5,
      rewardCoins: 1000,
    ),
    Achievement(
      id: 'legendary_collector',
      name: '传说收藏家',
      description: '拥有1条传说品质的鱼',
      emoji: '🌟',
      type: AchievementType.collection,
      targetValue: 1,
      rewardCoins: 5000,
      rewardFishFood: 50,
    ),
  ];
}

/// 成就进度
class AchievementProgress {
  final String achievementId;
  final int currentValue;
  final bool isCompleted;
  final bool isClaimed;  // 是否已领取奖励

  const AchievementProgress({
    required this.achievementId,
    this.currentValue = 0,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  AchievementProgress copyWith({
    int? currentValue,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return AchievementProgress(
      achievementId: achievementId,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() => {
    'achievementId': achievementId,
    'currentValue': currentValue,
    'isCompleted': isCompleted,
    'isClaimed': isClaimed,
  };

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      achievementId: json['achievementId'],
      currentValue: json['currentValue'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      isClaimed: json['isClaimed'] ?? false,
    );
  }
}
