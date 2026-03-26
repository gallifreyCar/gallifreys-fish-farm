/// 目标系统
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 目标类型
enum GoalType {
  tutorial,    // 新手引导目标
  daily,       // 每日目标
  weekly,      // 每周目标
  milestone,   // 里程碑
}

/// 奖励类型
enum RewardType {
  coins,
  fishFood,
  rareFish,
  epicFish,
  legendaryFish,
  material,
}

/// 奖励
class Reward {
  final RewardType type;
  final int amount;

  const Reward({
    required this.type,
    required this.amount,
  });

  String get description {
    switch (type) {
      case RewardType.coins:
        return '$amount 金币';
      case RewardType.fishFood:
        return '$amount 鱼食';
      case RewardType.rareFish:
        return '稀有鱼苗 x$amount';
      case RewardType.epicFish:
        return '史诗鱼苗 x$amount';
      case RewardType.legendaryFish:
        return '传说鱼苗 x$amount';
      case RewardType.material:
        return '材料 x$amount';
    }
  }
}

/// 目标定义
class Goal {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final GoalType type;
  final int targetValue;
  final int currentValue;
  final List<Reward> rewards;
  final bool isCompleted;
  final bool isClaimed;

  const Goal({
    required this.id,
    required this.title,
    required this.description,
    this.emoji = '🎯',
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    this.rewards = const [],
    this.isCompleted = false,
    this.isClaimed = false,
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);
  String get progressText => '$currentValue / $targetValue';
  bool get isProgressComplete => currentValue >= targetValue;

  Goal copyWith({
    int? currentValue,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return Goal(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      type: type,
      targetValue: targetValue,
      currentValue: currentValue ?? this.currentValue,
      rewards: rewards,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'currentValue': currentValue,
    'isCompleted': isCompleted,
    'isClaimed': isClaimed,
  };

  factory Goal.fromJson(Map<String, dynamic> json, Goal template) {
    return template.copyWith(
      currentValue: json['currentValue'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      isClaimed: json['isClaimed'] ?? false,
    );
  }
}

/// 目标管理器
class GoalNotifier extends StateNotifier<Map<String, Goal>> {
  GoalNotifier() : super({});

  /// 初始化目标
  void initializeGoals() {
    state = {
      for (final goal in _allGoals) goal.id: goal,
    };
  }

  /// 更新目标进度
  void updateProgress(String goalId, int value) {
    final goal = state[goalId];
    if (goal == null || goal.isClaimed) return;

    final newGoal = goal.copyWith(
      currentValue: value,
      isCompleted: value >= goal.targetValue,
    );
    state = {...state, goalId: newGoal};
  }

  /// 增加目标进度
  void addProgress(String goalId, int amount) {
    final goal = state[goalId];
    if (goal == null || goal.isClaimed) return;

    updateProgress(goalId, goal.currentValue + amount);
  }

  /// 领取目标奖励
  List<Reward> claimReward(String goalId) {
    final goal = state[goalId];
    if (goal == null || !goal.isCompleted || goal.isClaimed) return [];

    state = {...state, goalId: goal.copyWith(isClaimed: true)};
    return goal.rewards;
  }

  /// 获取指定类型的目标
  List<Goal> getGoalsByType(GoalType type) {
    return state.values.where((g) => g.type == type).toList();
  }

  /// 获取可领取的目标数量
  int getClaimableCount() {
    return state.values.where((g) => g.isCompleted && !g.isClaimed).length;
  }

  /// 获取进行中的目标
  List<Goal> getActiveGoals() {
    return state.values.where((g) => !g.isCompleted).toList()
      ..sort((a, b) => b.progress.compareTo(a.progress));
  }

  /// 获取当前推荐目标
  Goal? getRecommendedGoal() {
    // 优先返回进行中且进度最高的
    final active = getActiveGoals();
    if (active.isNotEmpty) return active.first;
    return null;
  }

  /// 从存档加载
  void loadFromSave(Map<String, dynamic> data) {
    final savedGoals = data['goals'] as Map<String, dynamic>?;
    if (savedGoals == null) {
      initializeGoals();
      return;
    }

    state = {
      for (final entry in savedGoals.entries)
        if (_goalTemplates.containsKey(entry.key))
          entry.key: Goal.fromJson(entry.value, _goalTemplates[entry.key]!),
    };

    // 确保所有目标都存在
    for (final goal in _allGoals) {
      if (!state.containsKey(goal.id)) {
        state = {...state, goal.id: goal};
      }
    }
  }

  /// 导出存档
  Map<String, dynamic> toJson() => {
    'goals': {for (final entry in state.entries) entry.key: entry.value.toJson()},
  };

  /// 目标模板（用于从JSON恢复）
  static final Map<String, Goal> _goalTemplates = {
    for (final goal in _allGoals) goal.id: goal,
  };
}

/// 所有可能的目标
final _allGoals = <Goal>[
  // ========== 新手引导目标 ==========
  Goal(
    id: 'catch_1',
    title: '初出茅庐',
    description: '钓到第一条鱼',
    emoji: '🎣',
    type: GoalType.tutorial,
    targetValue: 1,
    rewards: const [Reward(type: RewardType.coins, amount: 50)],
  ),
  Goal(
    id: 'catch_10',
    title: '小试牛刀',
    description: '钓到 10 条鱼',
    emoji: '🐟',
    type: GoalType.tutorial,
    targetValue: 10,
    rewards: const [Reward(type: RewardType.coins, amount: 100)],
  ),
  Goal(
    id: 'defeat_boss_1',
    title: '首战告捷',
    description: '击败第一个 Boss',
    emoji: '⚔️',
    type: GoalType.tutorial,
    targetValue: 1,
    rewards: const [Reward(type: RewardType.coins, amount: 200), Reward(type: RewardType.fishFood, amount: 10)],
  ),
  Goal(
    id: 'own_rare_fish',
    title: '稀有收藏',
    description: '拥有一条稀有品质的鱼',
    emoji: '⭐',
    type: GoalType.tutorial,
    targetValue: 1,
    rewards: const [Reward(type: RewardType.coins, amount: 300)],
  ),
  Goal(
    id: 'upgrade_building_1',
    title: '建筑师',
    description: '升级一个建筑',
    emoji: '🏗️',
    type: GoalType.tutorial,
    targetValue: 1,
    rewards: const [Reward(type: RewardType.coins, amount: 150)],
  ),

  // ========== 里程碑目标 - 钓鱼 ==========
  Goal(
    id: 'catch_50',
    title: '渐入佳境',
    description: '钓到 50 条鱼',
    emoji: '🐟',
    type: GoalType.milestone,
    targetValue: 50,
    rewards: const [Reward(type: RewardType.coins, amount: 300)],
  ),
  Goal(
    id: 'catch_100',
    title: '钓鱼达人',
    description: '钓到 100 条鱼',
    emoji: '🎣',
    type: GoalType.milestone,
    targetValue: 100,
    rewards: const [Reward(type: RewardType.coins, amount: 500), Reward(type: RewardType.fishFood, amount: 20)],
  ),
  Goal(
    id: 'catch_500',
    title: '钓鱼高手',
    description: '钓到 500 条鱼',
    emoji: '🏅',
    type: GoalType.milestone,
    targetValue: 500,
    rewards: const [Reward(type: RewardType.coins, amount: 2000), Reward(type: RewardType.rareFish, amount: 1)],
  ),
  Goal(
    id: 'catch_1000',
    title: '钓鱼大师',
    description: '钓到 1000 条鱼',
    emoji: '🏆',
    type: GoalType.milestone,
    targetValue: 1000,
    rewards: const [Reward(type: RewardType.coins, amount: 5000), Reward(type: RewardType.epicFish, amount: 1)],
  ),
  Goal(
    id: 'catch_5000',
    title: '钓鱼宗师',
    description: '钓到 5000 条鱼',
    emoji: '👑',
    type: GoalType.milestone,
    targetValue: 5000,
    rewards: const [Reward(type: RewardType.coins, amount: 20000), Reward(type: RewardType.legendaryFish, amount: 1)],
  ),

  // ========== 里程碑目标 - 战斗 ==========
  Goal(
    id: 'defeat_boss_5',
    title: 'Boss 猎人',
    description: '击败 5 个 Boss',
    emoji: '⚔️',
    type: GoalType.milestone,
    targetValue: 5,
    rewards: const [Reward(type: RewardType.coins, amount: 500)],
  ),
  Goal(
    id: 'defeat_boss_10',
    title: 'Boss 克星',
    description: '击败 10 个 Boss',
    emoji: '🗡️',
    type: GoalType.milestone,
    targetValue: 10,
    rewards: const [Reward(type: RewardType.coins, amount: 2000), Reward(type: RewardType.epicFish, amount: 1)],
  ),
  Goal(
    id: 'defeat_boss_all',
    title: '海王',
    description: '击败所有 Boss',
    emoji: '👑',
    type: GoalType.milestone,
    targetValue: 12,
    rewards: const [Reward(type: RewardType.coins, amount: 10000), Reward(type: RewardType.legendaryFish, amount: 1)],
  ),
  Goal(
    id: 'combo_50',
    title: '连击大师',
    description: '单场战斗达成 50 连击',
    emoji: '⚡',
    type: GoalType.milestone,
    targetValue: 50,
    rewards: const [Reward(type: RewardType.coins, amount: 500)],
  ),

  // ========== 里程碑目标 - 经济 ==========
  Goal(
    id: 'coins_1000',
    title: '小富翁',
    description: '累计获得 1000 金币',
    emoji: '💰',
    type: GoalType.milestone,
    targetValue: 1000,
    rewards: const [Reward(type: RewardType.coins, amount: 100)],
  ),
  Goal(
    id: 'coins_10000',
    title: '小财主',
    description: '累计获得 10000 金币',
    emoji: '💎',
    type: GoalType.milestone,
    targetValue: 10000,
    rewards: const [Reward(type: RewardType.coins, amount: 500)],
  ),
  Goal(
    id: 'coins_100000',
    title: '大富翁',
    description: '累计获得 100000 金币',
    emoji: '💰',
    type: GoalType.milestone,
    targetValue: 100000,
    rewards: const [Reward(type: RewardType.coins, amount: 2000), Reward(type: RewardType.epicFish, amount: 1)],
  ),
  Goal(
    id: 'coins_1000000',
    title: '百万富翁',
    description: '累计获得 1000000 金币',
    emoji: '💎',
    type: GoalType.milestone,
    targetValue: 1000000,
    rewards: const [Reward(type: RewardType.coins, amount: 10000), Reward(type: RewardType.legendaryFish, amount: 1)],
  ),

  // ========== 里程碑目标 - 收集 ==========
  Goal(
    id: 'fish_10',
    title: '小小收藏家',
    description: '拥有 10 条鱼宠',
    emoji: '📚',
    type: GoalType.milestone,
    targetValue: 10,
    rewards: const [Reward(type: RewardType.coins, amount: 200)],
  ),
  Goal(
    id: 'fish_50',
    title: '收藏家',
    description: '拥有 50 条鱼宠',
    emoji: '📚',
    type: GoalType.milestone,
    targetValue: 50,
    rewards: const [Reward(type: RewardType.coins, amount: 1000)],
  ),
  Goal(
    id: 'fish_100',
    title: '大收藏家',
    description: '拥有 100 条鱼宠',
    emoji: '📚',
    type: GoalType.milestone,
    targetValue: 100,
    rewards: const [Reward(type: RewardType.coins, amount: 5000), Reward(type: RewardType.epicFish, amount: 1)],
  ),
  Goal(
    id: 'rare_5',
    title: '稀有收藏家',
    description: '拥有 5 条稀有鱼',
    emoji: '⭐',
    type: GoalType.milestone,
    targetValue: 5,
    rewards: const [Reward(type: RewardType.coins, amount: 500)],
  ),
  Goal(
    id: 'epic_5',
    title: '史诗收藏家',
    description: '拥有 5 条史诗鱼',
    emoji: '💜',
    type: GoalType.milestone,
    targetValue: 5,
    rewards: const [Reward(type: RewardType.coins, amount: 2000)],
  ),
  Goal(
    id: 'legendary_1',
    title: '传说收藏家',
    description: '拥有 1 条传说鱼',
    emoji: '🌟',
    type: GoalType.milestone,
    targetValue: 1,
    rewards: const [Reward(type: RewardType.coins, amount: 5000), Reward(type: RewardType.fishFood, amount: 50)],
  ),
  Goal(
    id: 'legendary_5',
    title: '传说猎人',
    description: '拥有 5 条传说鱼',
    emoji: '🌟',
    type: GoalType.milestone,
    targetValue: 5,
    rewards: const [Reward(type: RewardType.coins, amount: 20000)],
  ),

  // ========== 里程碑目标 - 转生 ==========
  Goal(
    id: 'prestige_1',
    title: '重生者',
    description: '完成第一次转生',
    emoji: '🔄',
    type: GoalType.milestone,
    targetValue: 1,
    rewards: const [Reward(type: RewardType.coins, amount: 1000)],
  ),
  Goal(
    id: 'prestige_5',
    title: '轮回者',
    description: '完成 5 次转生',
    emoji: '🔄',
    type: GoalType.milestone,
    targetValue: 5,
    rewards: const [Reward(type: RewardType.coins, amount: 5000), Reward(type: RewardType.legendaryFish, amount: 1)],
  ),
];

/// Provider
final goalProvider = StateNotifierProvider<GoalNotifier, Map<String, Goal>>((ref) {
  return GoalNotifier()..initializeGoals();
});

/// 当前推荐目标
final recommendedGoalProvider = Provider<Goal?>((ref) {
  return ref.watch(goalProvider.notifier).getRecommendedGoal();
});

/// 可领取目标数量
final claimableGoalsCountProvider = Provider<int>((ref) {
  return ref.watch(goalProvider.notifier).getClaimableCount();
});

/// 按类型获取目标
final goalsByTypeProvider = Provider.family<List<Goal>, GoalType>((ref, type) {
  return ref.watch(goalProvider.notifier).getGoalsByType(type);
});
