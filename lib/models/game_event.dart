/// 事件类型
enum EventType {
  doubleIncome,      // 双倍收入
  doubleExp,         // 双倍经验
  rareFishBoost,     // 稀有鱼概率翻倍
  bossRush,          // Boss战奖励翻倍
  equipmentDrop,     // 装备掉落率翻倍
  weekend,           // 周末狂欢（综合加成）
}

/// 活动定义
class GameEvent {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final EventType type;
  final double multiplier;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;

  const GameEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.type,
    required this.multiplier,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  /// 检查活动是否正在进行
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// 获取剩余时间（秒）
  int get remainingSeconds {
    if (!isCurrentlyActive) return 0;
    return endTime.difference(DateTime.now()).inSeconds;
  }

  /// 获取剩余时间描述
  String get remainingTimeDescription {
    final seconds = remainingSeconds;
    if (seconds <= 0) return '已结束';

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 24) {
      final days = hours ~/ 24;
      return '剩余 $days 天';
    } else if (hours > 0) {
      return '剩余 $hours 小时 $minutes 分钟';
    } else {
      return '剩余 $minutes 分钟';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'emoji': emoji,
    'type': type.index,
    'multiplier': multiplier,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'isActive': isActive,
  };

  factory GameEvent.fromJson(Map<String, dynamic> json) {
    return GameEvent(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      emoji: json['emoji'],
      type: EventType.values[json['type']],
      multiplier: json['multiplier'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isActive: json['isActive'] ?? true,
    );
  }
}

/// 活动管理器
class EventManager {
  /// 生成周末活动
  static GameEvent generateWeekendEvent() {
    final now = DateTime.now();
    // 找到最近的周六0点
    var saturday = now;
    while (saturday.weekday != DateTime.saturday) {
      saturday = saturday.subtract(const Duration(days: 1));
    }
    final startTime = DateTime(saturday.year, saturday.month, saturday.day, 0, 0);
    final endTime = startTime.add(const Duration(days: 2)); // 周六+周日

    return GameEvent(
      id: 'weekend_${startTime.millisecondsSinceEpoch}',
      name: '周末狂欢',
      description: '收入、经验、稀有鱼概率全部提升50%！',
      emoji: '🎉',
      type: EventType.weekend,
      multiplier: 1.5,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// 生成每日限时活动
  static List<GameEvent> generateDailyEvents() {
    final now = DateTime.now();
    final events = <GameEvent>[];

    // 上午黄金时段 (8:00-12:00)
    final morningStart = DateTime(now.year, now.month, now.day, 8, 0);
    final morningEnd = DateTime(now.year, now.month, now.day, 12, 0);
    if (now.isBefore(morningEnd)) {
      events.add(GameEvent(
        id: 'morning_income_${now.millisecondsSinceEpoch}',
        name: '晨间丰收',
        description: '收入翻倍！',
        emoji: '🌅',
        type: EventType.doubleIncome,
        multiplier: 2.0,
        startTime: morningStart,
        endTime: morningEnd,
      ));
    }

    // 下午活动时段 (14:00-18:00)
    final afternoonStart = DateTime(now.year, now.month, now.day, 14, 0);
    final afternoonEnd = DateTime(now.year, now.month, now.day, 18, 0);
    if (now.isBefore(afternoonEnd)) {
      events.add(GameEvent(
        id: 'afternoon_exp_${now.millisecondsSinceEpoch}',
        name: '午后训练',
        description: '经验获取翻倍！',
        emoji: '☀️',
        type: EventType.doubleExp,
        multiplier: 2.0,
        startTime: afternoonStart,
        endTime: afternoonEnd,
      ));
    }

    // 晚间Boss战 (20:00-23:00)
    final eveningStart = DateTime(now.year, now.month, now.day, 20, 0);
    final eveningEnd = DateTime(now.year, now.month, now.day, 23, 0);
    if (now.isBefore(eveningEnd)) {
      events.add(GameEvent(
        id: 'evening_boss_${now.millisecondsSinceEpoch}',
        name: 'Boss突袭',
        description: 'Boss战奖励翻倍！',
        emoji: '👹',
        type: EventType.bossRush,
        multiplier: 2.0,
        startTime: eveningStart,
        endTime: eveningEnd,
      ));
    }

    return events;
  }

  /// 获取当前所有活动（预设活动 + 自动生成活动）
  static List<GameEvent> getActiveEvents(List<GameEvent> customEvents) {
    final now = DateTime.now();
    final events = <GameEvent>[];

    // 添加自定义活动
    events.addAll(customEvents.where((e) => e.isCurrentlyActive));

    // 生成并添加自动活动
    events.addAll(generateDailyEvents().where((e) => e.isCurrentlyActive));

    // 检查是否是周末
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      final weekend = generateWeekendEvent();
      if (weekend.isCurrentlyActive) {
        events.add(weekend);
      }
    }

    return events;
  }

  /// 计算特定类型的加成倍率
  static double getEventMultiplier(List<GameEvent> events, EventType type) {
    double multiplier = 1.0;
    for (final event in events) {
      if (event.type == type || event.type == EventType.weekend) {
        multiplier *= event.multiplier;
      }
    }
    return multiplier;
  }

  /// 计算收入加成
  static double getIncomeMultiplier(List<GameEvent> events) {
    return getEventMultiplier(events, EventType.doubleIncome);
  }

  /// 计算经验加成
  static double getExpMultiplier(List<GameEvent> events) {
    return getEventMultiplier(events, EventType.doubleExp);
  }

  /// 计算Boss奖励加成
  static double getBossRewardMultiplier(List<GameEvent> events) {
    return getEventMultiplier(events, EventType.bossRush);
  }

  /// 计算稀有鱼概率加成
  static double getRareFishMultiplier(List<GameEvent> events) {
    return getEventMultiplier(events, EventType.rareFishBoost);
  }

  /// 计算装备掉落加成
  static double getEquipmentDropMultiplier(List<GameEvent> events) {
    return getEventMultiplier(events, EventType.equipmentDrop);
  }
}

/// 活动数据（用于保存）
class EventData {
  final List<GameEvent> customEvents;
  final DateTime lastGenerated;

  EventData({
    this.customEvents = const [],
    DateTime? lastGenerated,
  }) : lastGenerated = lastGenerated ?? DateTime(1970, 1, 1);

  EventData copyWith({
    List<GameEvent>? customEvents,
    DateTime? lastGenerated,
  }) {
    return EventData(
      customEvents: customEvents ?? this.customEvents,
      lastGenerated: lastGenerated ?? this.lastGenerated,
    );
  }

  Map<String, dynamic> toJson() => {
    'customEvents': customEvents.map((e) => e.toJson()).toList(),
    'lastGenerated': lastGenerated.toIso8601String(),
  };

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      customEvents: (json['customEvents'] as List?)
          ?.map((e) => GameEvent.fromJson(e))
          .toList() ?? [],
      lastGenerated: json['lastGenerated'] != null
          ? DateTime.parse(json['lastGenerated'])
          : DateTime(1970, 1, 1),
    );
  }
}
