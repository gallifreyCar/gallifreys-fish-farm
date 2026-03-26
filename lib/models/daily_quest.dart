/// 每日任务类型
enum DailyQuestType {
  fishing,      // 钓鱼数量
  battle,       // 战斗次数
  income,       // 收入金币
  feeding,      // 喂食次数
  selling,      // 出售次数
}

/// 每日任务定义
class DailyQuest {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final DailyQuestType type;
  final int targetValue;
  final int rewardCoins;
  final int rewardFishFood;

  const DailyQuest({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.type,
    required this.targetValue,
    required this.rewardCoins,
    this.rewardFishFood = 0,
  });

  /// 随机生成每日任务池
  static const List<DailyQuest> questPool = [
    DailyQuest(
      id: 'daily_fish_10',
      name: '勤劳渔夫',
      description: '钓到10条鱼',
      emoji: '🎣',
      type: DailyQuestType.fishing,
      targetValue: 10,
      rewardCoins: 100,
      rewardFishFood: 5,
    ),
    DailyQuest(
      id: 'daily_fish_30',
      name: '捕鱼达人',
      description: '钓到30条鱼',
      emoji: '🐟',
      type: DailyQuestType.fishing,
      targetValue: 30,
      rewardCoins: 300,
      rewardFishFood: 10,
    ),
    DailyQuest(
      id: 'daily_battle_3',
      name: '战士之心',
      description: '进行3次战斗',
      emoji: '⚔️',
      type: DailyQuestType.battle,
      targetValue: 3,
      rewardCoins: 150,
    ),
    DailyQuest(
      id: 'daily_battle_5',
      name: '无畏勇士',
      description: '进行5次战斗',
      emoji: '🗡️',
      type: DailyQuestType.battle,
      targetValue: 5,
      rewardCoins: 250,
      rewardFishFood: 5,
    ),
    DailyQuest(
      id: 'daily_income_500',
      name: '小有积蓄',
      description: '累计获得500金币',
      emoji: '💰',
      type: DailyQuestType.income,
      targetValue: 500,
      rewardCoins: 50,
    ),
    DailyQuest(
      id: 'daily_income_2000',
      name: '财源广进',
      description: '累计获得2000金币',
      emoji: '💎',
      type: DailyQuestType.income,
      targetValue: 2000,
      rewardCoins: 200,
      rewardFishFood: 10,
    ),
    DailyQuest(
      id: 'daily_feed_5',
      name: '爱心喂养',
      description: '喂食鱼宠5次',
      emoji: '🍖',
      type: DailyQuestType.feeding,
      targetValue: 5,
      rewardCoins: 80,
    ),
    DailyQuest(
      id: 'daily_sell_3',
      name: '小本生意',
      description: '出售3条鱼',
      emoji: '🛒',
      type: DailyQuestType.selling,
      targetValue: 3,
      rewardCoins: 60,
    ),
  ];

  /// 生成每日任务（每天3个）
  static List<DailyQuest> generateDailyQuests(int daySeed) {
    final pool = List<DailyQuest>.from(questPool);
    pool.shuffle();
    return pool.take(3).toList();
  }
}

/// 每日任务进度
class DailyQuestProgress {
  final String questId;
  final int currentValue;
  final bool isCompleted;
  final bool isClaimed;

  const DailyQuestProgress({
    required this.questId,
    this.currentValue = 0,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  DailyQuestProgress copyWith({
    int? currentValue,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return DailyQuestProgress(
      questId: questId,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() => {
    'questId': questId,
    'currentValue': currentValue,
    'isCompleted': isCompleted,
    'isClaimed': isClaimed,
  };

  factory DailyQuestProgress.fromJson(Map<String, dynamic> json) {
    return DailyQuestProgress(
      questId: json['questId'],
      currentValue: json['currentValue'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      isClaimed: json['isClaimed'] ?? false,
    );
  }
}

/// 每日任务数据
class DailyQuestData {
  final DateTime date;
  final List<DailyQuest> quests;
  final Map<String, DailyQuestProgress> progress;

  const DailyQuestData({
    required this.date,
    required this.quests,
    required this.progress,
  });

  /// 是否是今天
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  /// 获取可领取的任务数量
  int get claimableCount {
    return progress.values.where((p) => p.isCompleted && !p.isClaimed).length;
  }

  DailyQuestData copyWith({
    DateTime? date,
    List<DailyQuest>? quests,
    Map<String, DailyQuestProgress>? progress,
  }) {
    return DailyQuestData(
      date: date ?? this.date,
      quests: quests ?? this.quests,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'questIds': quests.map((q) => q.id).toList(),
    'progress': progress.values.map((p) => p.toJson()).toList(),
  };

  factory DailyQuestData.fromJson(Map<String, dynamic> json) {
    final date = json['date'] != null
        ? DateTime.parse(json['date'])
        : DateTime.now();

    final questIds = (json['questIds'] as List?)?.cast<String>() ?? [];
    final quests = questIds.map((id) =>
      DailyQuest.questPool.firstWhere((q) => q.id == id,
        orElse: () => DailyQuest.questPool.first)
    ).toList();

    if (quests.isEmpty) {
      // 如果没有保存的任务，生成新的
      return DailyQuestData.generate(date);
    }

    final progressList = (json['progress'] as List?) ?? [];
    final progress = <String, DailyQuestProgress>{};
    for (final p in progressList) {
      final prog = DailyQuestProgress.fromJson(p);
      progress[prog.questId] = prog;
    }

    // 确保所有任务都有进度
    for (final quest in quests) {
      progress.putIfAbsent(quest.id, () => DailyQuestProgress(questId: quest.id));
    }

    return DailyQuestData(
      date: date,
      quests: quests,
      progress: progress,
    );
  }

  /// 生成新的每日任务
  factory DailyQuestData.generate(DateTime date) {
    final daySeed = date.year * 10000 + date.month * 100 + date.day;
    final quests = DailyQuest.generateDailyQuests(daySeed);
    final progress = {
      for (final q in quests)
        q.id: DailyQuestProgress(questId: q.id)
    };
    return DailyQuestData(
      date: date,
      quests: quests,
      progress: progress,
    );
  }

  /// 获取或创建今天的数据
  static DailyQuestData getToday(DailyQuestData? saved) {
    if (saved != null && saved.isToday) {
      return saved;
    }
    return DailyQuestData.generate(DateTime.now());
  }
}
