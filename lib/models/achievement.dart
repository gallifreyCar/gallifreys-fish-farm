/// 成就类型
enum AchievementType {
  fishing,      // 钓鱼相关
  battle,       // 战斗相关
  economy,      // 经济相关
  collection,   // 收集相关
  prestige,     // 转生相关
  special,      // 特殊成就
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

  /// 所有成就 - 40个
  static const List<Achievement> allAchievements = [
    // ========== 钓鱼成就线 (10个) ==========
    Achievement(
      id: 'catch_1',
      name: '初出茅庐',
      description: '钓到第一条鱼',
      emoji: '🎣',
      type: AchievementType.fishing,
      targetValue: 1,
      rewardCoins: 50,
    ),
    Achievement(
      id: 'catch_10',
      name: '小试牛刀',
      description: '累计钓到10条鱼',
      emoji: '🐟',
      type: AchievementType.fishing,
      targetValue: 10,
      rewardCoins: 100,
    ),
    Achievement(
      id: 'catch_50',
      name: '渐入佳境',
      description: '累计钓到50条鱼',
      emoji: '🐟',
      type: AchievementType.fishing,
      targetValue: 50,
      rewardCoins: 300,
      rewardFishFood: 10,
    ),
    Achievement(
      id: 'catch_100',
      name: '钓鱼达人',
      description: '累计钓到100条鱼',
      emoji: '🎣',
      type: AchievementType.fishing,
      targetValue: 100,
      rewardCoins: 500,
      rewardFishFood: 20,
    ),
    Achievement(
      id: 'catch_500',
      name: '钓鱼高手',
      description: '累计钓到500条鱼',
      emoji: '🏅',
      type: AchievementType.fishing,
      targetValue: 500,
      rewardCoins: 2000,
      rewardFishRarity: 'rare',
    ),
    Achievement(
      id: 'catch_1000',
      name: '钓鱼大师',
      description: '累计钓到1000条鱼',
      emoji: '🏆',
      type: AchievementType.fishing,
      targetValue: 1000,
      rewardCoins: 5000,
      rewardFishRarity: 'epic',
    ),
    Achievement(
      id: 'catch_5000',
      name: '钓鱼宗师',
      description: '累计钓到5000条鱼',
      emoji: '👑',
      type: AchievementType.fishing,
      targetValue: 5000,
      rewardCoins: 20000,
      rewardFishRarity: 'legendary',
    ),
    Achievement(
      id: 'catch_legendary_1',
      name: '传说猎人',
      description: '钓到1条传说鱼',
      emoji: '🌟',
      type: AchievementType.fishing,
      targetValue: 1,
      rewardCoins: 1000,
    ),
    Achievement(
      id: 'catch_legendary_10',
      name: '传说收藏家',
      description: '钓到10条传说鱼',
      emoji: '✨',
      type: AchievementType.fishing,
      targetValue: 10,
      rewardCoins: 10000,
    ),
    Achievement(
      id: 'catch_all_types',
      name: '图鉴大师',
      description: '收集所有种类的鱼',
      emoji: '📖',
      type: AchievementType.fishing,
      targetValue: 36,
      rewardCoins: 50000,
    ),

    // ========== 战斗成就线 (10个) ==========
    Achievement(
      id: 'defeat_boss_1',
      name: '初战告捷',
      description: '击败第一个Boss',
      emoji: '⚔️',
      type: AchievementType.battle,
      targetValue: 1,
      rewardCoins: 100,
    ),
    Achievement(
      id: 'defeat_boss_5',
      name: 'Boss猎人',
      description: '击败5个Boss',
      emoji: '🗡️',
      type: AchievementType.battle,
      targetValue: 5,
      rewardCoins: 500,
    ),
    Achievement(
      id: 'defeat_boss_10',
      name: 'Boss克星',
      description: '击败10个Boss',
      emoji: '⚔️',
      type: AchievementType.battle,
      targetValue: 10,
      rewardCoins: 2000,
      rewardFishRarity: 'epic',
    ),
    Achievement(
      id: 'defeat_boss_all',
      name: '海王',
      description: '击败所有Boss',
      emoji: '👑',
      type: AchievementType.battle,
      targetValue: 12,
      rewardCoins: 10000,
      rewardFishRarity: 'legendary',
    ),
    Achievement(
      id: 'defeat_tier3_all',
      name: '深渊征服者',
      description: '击败所有高级Boss',
      emoji: '🌊',
      type: AchievementType.battle,
      targetValue: 4,
      rewardCoins: 5000,
    ),
    Achievement(
      id: 'combo_50',
      name: '连击大师',
      description: '单场战斗达成50连击',
      emoji: '⚡',
      type: AchievementType.battle,
      targetValue: 50,
      rewardCoins: 500,
    ),
    Achievement(
      id: 'combo_100',
      name: '连击宗师',
      description: '单场战斗达成100连击',
      emoji: '⚡',
      type: AchievementType.battle,
      targetValue: 100,
      rewardCoins: 2000,
    ),
    Achievement(
      id: 'boss_solo',
      name: '独孤求败',
      description: '用1条鱼击败Boss',
      emoji: '💪',
      type: AchievementType.battle,
      targetValue: 1,
      rewardCoins: 3000,
    ),
    Achievement(
      id: 'boss_low_power',
      name: '以弱胜强',
      description: '以低于推荐战力击败Boss',
      emoji: '🎯',
      type: AchievementType.battle,
      targetValue: 1,
      rewardCoins: 2000,
    ),
    Achievement(
      id: 'boss_speed_10s',
      name: '速通大师',
      description: '10秒内击败任意Boss',
      emoji: '⏱️',
      type: AchievementType.battle,
      targetValue: 1,
      rewardCoins: 2000,
    ),

    // ========== 经济成就线 (10个) ==========
    Achievement(
      id: 'coins_1000',
      name: '小富翁',
      description: '累计获得1000金币',
      emoji: '💰',
      type: AchievementType.economy,
      targetValue: 1000,
      rewardCoins: 100,
    ),
    Achievement(
      id: 'coins_10000',
      name: '小财主',
      description: '累计获得10000金币',
      emoji: '💎',
      type: AchievementType.economy,
      targetValue: 10000,
      rewardCoins: 500,
    ),
    Achievement(
      id: 'coins_100000',
      name: '大富翁',
      description: '累计获得100000金币',
      emoji: '💰',
      type: AchievementType.economy,
      targetValue: 100000,
      rewardCoins: 2000,
      rewardFishFood: 100,
    ),
    Achievement(
      id: 'coins_1000000',
      name: '百万富翁',
      description: '累计获得1000000金币',
      emoji: '💎',
      type: AchievementType.economy,
      targetValue: 1000000,
      rewardCoins: 10000,
      rewardFishFood: 200,
    ),
    Achievement(
      id: 'income_10',
      name: '小本生意',
      description: '达到10金币/秒收入',
      emoji: '📈',
      type: AchievementType.economy,
      targetValue: 10,
      rewardCoins: 200,
    ),
    Achievement(
      id: 'income_100',
      name: '生意兴隆',
      description: '达到100金币/秒收入',
      emoji: '📈',
      type: AchievementType.economy,
      targetValue: 100,
      rewardCoins: 1000,
    ),
    Achievement(
      id: 'income_1000',
      name: '财源滚滚',
      description: '达到1000金币/秒收入',
      emoji: '💰',
      type: AchievementType.economy,
      targetValue: 1000,
      rewardCoins: 5000,
    ),
    Achievement(
      id: 'sell_100',
      name: '鱼贩子',
      description: '出售100条鱼',
      emoji: '🐟',
      type: AchievementType.economy,
      targetValue: 100,
      rewardCoins: 300,
    ),
    Achievement(
      id: 'sell_legendary',
      name: '挥金如土',
      description: '出售一条传说鱼',
      emoji: '💸',
      type: AchievementType.economy,
      targetValue: 1,
      rewardCoins: 500,
    ),
    Achievement(
      id: 'upgrade_all_buildings',
      name: '基建狂魔',
      description: '所有建筑升到10级',
      emoji: '🏗️',
      type: AchievementType.economy,
      targetValue: 10,
      rewardCoins: 5000,
    ),

    // ========== 收集成就线 (10个) ==========
    Achievement(
      id: 'fish_10',
      name: '小小收藏家',
      description: '拥有10条鱼宠',
      emoji: '📚',
      type: AchievementType.collection,
      targetValue: 10,
      rewardCoins: 200,
    ),
    Achievement(
      id: 'fish_50',
      name: '收藏家',
      description: '拥有50条鱼宠',
      emoji: '📚',
      type: AchievementType.collection,
      targetValue: 50,
      rewardCoins: 1000,
    ),
    Achievement(
      id: 'fish_100',
      name: '大收藏家',
      description: '拥有100条鱼宠',
      emoji: '📚',
      type: AchievementType.collection,
      targetValue: 100,
      rewardCoins: 5000,
      rewardFishRarity: 'epic',
    ),
    Achievement(
      id: 'rare_5',
      name: '稀有收藏家',
      description: '拥有5条稀有鱼',
      emoji: '⭐',
      type: AchievementType.collection,
      targetValue: 5,
      rewardCoins: 500,
    ),
    Achievement(
      id: 'rare_20',
      name: '稀有猎人',
      description: '拥有20条稀有鱼',
      emoji: '⭐',
      type: AchievementType.collection,
      targetValue: 20,
      rewardCoins: 2000,
    ),
    Achievement(
      id: 'epic_5',
      name: '史诗收藏家',
      description: '拥有5条史诗鱼',
      emoji: '💜',
      type: AchievementType.collection,
      targetValue: 5,
      rewardCoins: 2000,
    ),
    Achievement(
      id: 'epic_10',
      name: '史诗猎人',
      description: '拥有10条史诗鱼',
      emoji: '💜',
      type: AchievementType.collection,
      targetValue: 10,
      rewardCoins: 5000,
    ),
    Achievement(
      id: 'legendary_1',
      name: '传说收藏家',
      description: '拥有1条传说鱼',
      emoji: '🌟',
      type: AchievementType.collection,
      targetValue: 1,
      rewardCoins: 5000,
      rewardFishFood: 50,
    ),
    Achievement(
      id: 'legendary_5',
      name: '传说猎人',
      description: '拥有5条传说鱼',
      emoji: '🌟',
      type: AchievementType.collection,
      targetValue: 5,
      rewardCoins: 20000,
    ),
    Achievement(
      id: 'legendary_all',
      name: '神话收藏家',
      description: '收集所有传说鱼',
      emoji: '✨',
      type: AchievementType.collection,
      targetValue: 9,
      rewardCoins: 100000,
    ),

    // ========== 转生成就线 (5个) ==========
    Achievement(
      id: 'prestige_1',
      name: '重生者',
      description: '完成第一次转生',
      emoji: '🔄',
      type: AchievementType.prestige,
      targetValue: 1,
      rewardCoins: 1000,
    ),
    Achievement(
      id: 'prestige_5',
      name: '轮回者',
      description: '完成5次转生',
      emoji: '🔄',
      type: AchievementType.prestige,
      targetValue: 5,
      rewardCoins: 5000,
      rewardFishRarity: 'legendary',
    ),
    Achievement(
      id: 'prestige_10',
      name: '永恒者',
      description: '完成10次转生',
      emoji: '♾️',
      type: AchievementType.prestige,
      targetValue: 10,
      rewardCoins: 20000,
    ),
    Achievement(
      id: 'talent_max',
      name: '天赋觉醒',
      description: '将一个天赋升到满级',
      emoji: '🎯',
      type: AchievementType.prestige,
      targetValue: 1,
      rewardCoins: 3000,
    ),
    Achievement(
      id: 'talent_all',
      name: '全能大师',
      description: '将所有天赋升到满级',
      emoji: '🏆',
      type: AchievementType.prestige,
      targetValue: 1,
      rewardCoins: 50000,
    ),

    // ========== 特殊成就线 (5个) ==========
    Achievement(
      id: 'playtime_1h',
      name: '初入江湖',
      description: '累计游戏时长1小时',
      emoji: '⏰',
      type: AchievementType.special,
      targetValue: 3600,
      rewardCoins: 100,
    ),
    Achievement(
      id: 'playtime_24h',
      name: '沉迷钓鱼',
      description: '累计游戏时长24小时',
      emoji: '⏰',
      type: AchievementType.special,
      targetValue: 86400,
      rewardCoins: 1000,
    ),
    Achievement(
      id: 'offline_8h',
      name: '挂机达人',
      description: '获得8小时离线收益',
      emoji: '😴',
      type: AchievementType.special,
      targetValue: 1,
      rewardCoins: 500,
    ),
    Achievement(
      id: 'event_10',
      name: '活动达人',
      description: '参与10次限时活动',
      emoji: '🎉',
      type: AchievementType.special,
      targetValue: 10,
      rewardCoins: 2000,
    ),
    Achievement(
      id: 'quest_daily_30',
      name: '每日必做',
      description: '完成30个每日任务',
      emoji: '📋',
      type: AchievementType.special,
      targetValue: 30,
      rewardCoins: 3000,
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
