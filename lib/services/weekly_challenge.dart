import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 挑战难度
enum ChallengeDifficulty {
  easy,    // 简单
  normal,  // 普通
  hard,    // 困难
  extreme, // 极限
}

/// 挑战任务
class ChallengeTask {
  final String id;
  final String description;
  final int targetValue;
  int currentValue;
  bool isCompleted;

  ChallengeTask({
    required this.id,
    required this.description,
    required this.targetValue,
    this.currentValue = 0,
    this.isCompleted = false,
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);
  String get progressText => '$currentValue / $targetValue';

  ChallengeTask copyWith({
    int? currentValue,
    bool? isCompleted,
  }) {
    return ChallengeTask(
      id: id,
      description: description,
      targetValue: targetValue,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// 每周挑战
class WeeklyChallenge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final ChallengeDifficulty difficulty;
  final DateTime startTime;
  final DateTime endTime;
  final List<ChallengeTask> tasks;
  final int rewardCoins;
  final int rewardFishFood;
  final bool isClaimed;

  WeeklyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.difficulty,
    required this.startTime,
    required this.endTime,
    required this.tasks,
    required this.rewardCoins,
    this.rewardFishFood = 0,
    this.isClaimed = false,
  });

  double get progress {
    if (tasks.isEmpty) return 0;
    return tasks.fold<double>(0, (sum, t) => sum + t.progress) / tasks.length;
  }

  bool get isCompleted => tasks.every((t) => t.isCompleted);
  bool get isExpired => DateTime.now().isAfter(endTime);
  bool get isActive => !isExpired && !isClaimed;

  WeeklyChallenge copyWith({
    List<ChallengeTask>? tasks,
    bool? isClaimed,
  }) {
    return WeeklyChallenge(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      difficulty: difficulty,
      startTime: startTime,
      endTime: endTime,
      tasks: tasks ?? this.tasks,
      rewardCoins: rewardCoins,
      rewardFishFood: rewardFishFood,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tasks': tasks.map((t) => {
      'id': t.id,
      'currentValue': t.currentValue,
      'isCompleted': t.isCompleted,
    }).toList(),
    'isClaimed': isClaimed,
  };

  factory WeeklyChallenge.fromJson(Map<String, dynamic> json, WeeklyChallenge template) {
    final taskData = (json['tasks'] as List?) ?? [];
    final updatedTasks = template.tasks.map((t) {
      final data = taskData.firstWhere(
        (d) => d['id'] == t.id,
        orElse: () => {},
      );
      return t.copyWith(
        currentValue: data['currentValue'] ?? 0,
        isCompleted: data['isCompleted'] ?? false,
      );
    }).toList();

    return template.copyWith(
      tasks: updatedTasks,
      isClaimed: json['isClaimed'] ?? false,
    );
  }
}

/// 每周挑战管理器
class WeeklyChallengeNotifier extends StateNotifier<List<WeeklyChallenge>> {
  WeeklyChallengeNotifier() : super(_generateWeeklyChallenges());

  /// 生成每周挑战
  static List<WeeklyChallenge> _generateWeeklyChallenges() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return [
      // 简单挑战
      WeeklyChallenge(
        id: 'weekly_easy_fishing',
        title: '钓鱼新手周',
        description: '本周完成钓鱼目标',
        emoji: '🎣',
        difficulty: ChallengeDifficulty.easy,
        startTime: weekStart,
        endTime: weekEnd,
        tasks: [
          ChallengeTask(id: 'catch_50', description: '钓到 50 条鱼', targetValue: 50),
          ChallengeTask(id: 'sell_20', description: '出售 20 条鱼', targetValue: 20),
        ],
        rewardCoins: 500,
        rewardFishFood: 20,
      ),

      // 普通挑战
      WeeklyChallenge(
        id: 'weekly_normal_battle',
        title: '战斗周',
        description: '击败多个Boss',
        emoji: '⚔️',
        difficulty: ChallengeDifficulty.normal,
        startTime: weekStart,
        endTime: weekEnd,
        tasks: [
          ChallengeTask(id: 'defeat_3', description: '击败 3 个 Boss', targetValue: 3),
          ChallengeTask(id: 'combo_30', description: '达成 30 连击', targetValue: 30),
        ],
        rewardCoins: 1500,
        rewardFishFood: 50,
      ),

      // 困难挑战
      WeeklyChallenge(
        id: 'weekly_hard_economy',
        title: '富翁周',
        description: '积累大量金币',
        emoji: '💰',
        difficulty: ChallengeDifficulty.hard,
        startTime: weekStart,
        endTime: weekEnd,
        tasks: [
          ChallengeTask(id: 'earn_50000', description: '累计获得 50000 金币', targetValue: 50000),
          ChallengeTask(id: 'upgrade_5', description: '升级 5 次建筑', targetValue: 5),
        ],
        rewardCoins: 5000,
        rewardFishFood: 100,
      ),

      // 极限挑战
      WeeklyChallenge(
        id: 'weekly_extreme_collection',
        title: '收藏家周',
        description: '收集稀有鱼类',
        emoji: '🏆',
        difficulty: ChallengeDifficulty.extreme,
        startTime: weekStart,
        endTime: weekEnd,
        tasks: [
          ChallengeTask(id: 'rare_10', description: '拥有 10 条稀有鱼', targetValue: 10),
          ChallengeTask(id: 'epic_3', description: '拥有 3 条史诗鱼', targetValue: 3),
          ChallengeTask(id: 'legendary_1', description: '拥有 1 条传说鱼', targetValue: 1),
        ],
        rewardCoins: 20000,
        rewardFishFood: 200,
      ),
    ];
  }

  /// 更新任务进度
  void updateTaskProgress(String challengeId, String taskId, int value) {
    state = state.map((challenge) {
      if (challenge.id != challengeId) return challenge;

      final updatedTasks = challenge.tasks.map((task) {
        if (task.id != taskId) return task;
        return task.copyWith(
          currentValue: value,
          isCompleted: value >= task.targetValue,
        );
      }).toList();

      return challenge.copyWith(tasks: updatedTasks);
    }).toList();
  }

  /// 增加任务进度
  void addTaskProgress(String challengeId, String taskId, int amount) {
    final challenge = state.firstWhere(
      (c) => c.id == challengeId,
      orElse: () => state.first,
    );
    final task = challenge.tasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => challenge.tasks.first,
    );
    updateTaskProgress(challengeId, taskId, task.currentValue + amount);
  }

  /// 领取挑战奖励
  bool claimReward(String challengeId) {
    final index = state.indexWhere((c) => c.id == challengeId);
    if (index == -1) return false;

    final challenge = state[index];
    if (!challenge.isCompleted || challenge.isClaimed) return false;

    state = [...state.sublist(0, index), challenge.copyWith(isClaimed: true), ...state.sublist(index + 1)];
    return true;
  }

  /// 获取活跃挑战
  List<WeeklyChallenge> getActiveChallenges() {
    return state.where((c) => c.isActive).toList();
  }

  /// 获取可领取的挑战数量
  int getClaimableCount() {
    return state.where((c) => c.isCompleted && !c.isClaimed).length;
  }

  /// 刷新每周挑战（每周一自动调用）
  void refreshWeekly() {
    state = _generateWeeklyChallenges();
  }
}

/// Provider
final weeklyChallengeProvider = StateNotifierProvider<WeeklyChallengeNotifier, List<WeeklyChallenge>>((ref) {
  return WeeklyChallengeNotifier();
});

/// 活跃挑战
final activeChallengesProvider = Provider<List<WeeklyChallenge>>((ref) {
  return ref.watch(weeklyChallengeProvider.notifier).getActiveChallenges();
});

/// 可领取挑战数量
final claimableChallengesCountProvider = Provider<int>((ref) {
  return ref.watch(weeklyChallengeProvider.notifier).getClaimableCount();
});
