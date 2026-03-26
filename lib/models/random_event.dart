import 'dart:math';
import 'fish.dart';

/// 随机事件类型
enum RandomEventType {
  merchant,      // 神秘商人
  treasure,      // 宝箱
  whirlpool,     // 漩涡
  fishSwarm,     // 鱼群
  bossInvasion,  // Boss入侵
  goldenHour,    // 黄金时刻
}

/// 随机事件
class RandomEvent {
  final String id;
  final RandomEventType type;
  final String title;
  final String description;
  final String emoji;
  final Duration duration;
  final EventChoice? choice;
  final DateTime startTime;

  DateTime get expireTime => startTime.add(duration);
  bool get isExpired => DateTime.now().isAfter(expireTime);
  bool get hasChoice => choice != null;

  const RandomEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    this.duration = const Duration(minutes: 5),
    this.choice,
    required this.startTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'title': title,
    'description': description,
    'emoji': emoji,
    'duration': duration.inSeconds,
    'startTime': startTime.toIso8601String(),
  };

  factory RandomEvent.fromJson(Map<String, dynamic> json) {
    return RandomEvent(
      id: json['id'],
      type: RandomEventType.values[json['type']],
      title: json['title'],
      description: json['description'],
      emoji: json['emoji'],
      duration: Duration(seconds: json['duration']),
      startTime: DateTime.parse(json['startTime']),
    );
  }
}

/// 事件选择
class EventChoice {
  final String option1Text;
  final String option2Text;
  final EventResult option1Result;
  final EventResult option2Result;

  const EventChoice({
    required this.option1Text,
    required this.option2Text,
    required this.option1Result,
    required this.option2Result,
  });
}

/// 事件结果
class EventResult {
  final String description;
  final int? coinChange;
  final int? fishFoodChange;
  final Rarity? fishReward;
  final bool isPositive;

  const EventResult({
    required this.description,
    this.coinChange,
    this.fishFoodChange,
    this.fishReward,
    this.isPositive = true,
  });
}

/// 随机事件管理器
class RandomEventManager {
  static final Random _random = Random();

  /// 所有事件模板
  static final List<RandomEvent> eventTemplates = [
    // 神秘商人
    RandomEvent(
      id: 'merchant_rare',
      type: RandomEventType.merchant,
      title: '神秘商人',
      description: '一位神秘的商人出现在你的渔场，他带来了一些稀有商品...',
      emoji: '🧙',
      duration: const Duration(minutes: 3),
      choice: EventChoice(
        option1Text: '购买稀有鱼苗 (100金币)',
        option2Text: '离开',
        option1Result: EventResult(
          description: '商人神秘地笑了，递给你一条稀有鱼苗...',
          coinChange: -100,
          fishReward: Rarity.rare,
        ),
        option2Result: EventResult(
          description: '商人摇摇头，消失在迷雾中...',
        ),
      ),
      startTime: DateTime.now(),
    ),
    RandomEvent(
      id: 'merchant_epic',
      type: RandomEventType.merchant,
      title: '稀有商人',
      description: '一位穿着华丽长袍的商人出现了，他的商品看起来非常珍贵...',
      emoji: '🧙‍♂️',
      duration: const Duration(minutes: 2),
      choice: EventChoice(
        option1Text: '购买史诗鱼苗 (500金币)',
        option2Text: '离开',
        option1Result: EventResult(
          description: '商人满意地点点头，递给你一条闪闪发光的鱼苗...',
          coinChange: -500,
          fishReward: Rarity.epic,
        ),
        option2Result: EventResult(
          description: '商人耸耸肩，转身离去...',
        ),
      ),
      startTime: DateTime.now(),
    ),

    // 宝箱
    RandomEvent(
      id: 'treasure_common',
      type: RandomEventType.treasure,
      title: '发现宝箱',
      description: '你在海边发现了一个古老的宝箱！',
      emoji: '📦',
      duration: const Duration(minutes: 2),
      choice: EventChoice(
        option1Text: '打开宝箱',
        option2Text: '忽略',
        option1Result: EventResult(
          description: '宝箱打开了！里面闪烁着金光...',
          coinChange: 200 + _random.nextInt(300),
          isPositive: true,
        ),
        option2Result: EventResult(
          description: '你决定不冒险，继续钓鱼...',
        ),
      ),
      startTime: DateTime.now(),
    ),
    RandomEvent(
      id: 'treasure_trap',
      type: RandomEventType.treasure,
      title: '可疑的宝箱',
      description: '你发现了一个看起来有点不对劲的宝箱...',
      emoji: '🎁',
      duration: const Duration(minutes: 1),
      choice: EventChoice(
        option1Text: '冒险打开',
        option2Text: '谨慎离开',
        option1Result: EventResult(
          description: _random.nextBool()
              ? '运气不错！宝箱里有宝藏！'
              : '糟糕！这是个陷阱！',
          coinChange: _random.nextBool() ? 500 : -100,
          isPositive: _random.nextBool(),
        ),
        option2Result: EventResult(
          description: '你明智地选择离开，安全第一！',
        ),
      ),
      startTime: DateTime.now(),
    ),

    // 漩涡
    RandomEvent(
      id: 'whirlpool',
      type: RandomEventType.whirlpool,
      title: '神秘漩涡',
      description: '海面上出现了一个神秘的漩涡，里面似乎有什么东西在发光...',
      emoji: '🌀',
      duration: const Duration(minutes: 3),
      choice: EventChoice(
        option1Text: '跳入漩涡',
        option2Text: '远离漩涡',
        option1Result: EventResult(
          description: _random.nextBool()
              ? '你被传送到了一个神秘的地方，获得了宝藏！'
              : '漩涡把你卷入深海，你失去了一些金币...',
          coinChange: _random.nextBool() ? 1000 : -200,
          fishReward: _random.nextBool() ? Rarity.rare : null,
          isPositive: _random.nextBool(),
        ),
        option2Result: EventResult(
          description: '你明智地远离了漩涡，安全第一！',
        ),
      ),
      startTime: DateTime.now(),
    ),

    // 鱼群
    RandomEvent(
      id: 'fish_swarm',
      type: RandomEventType.fishSwarm,
      title: '鱼群迁徙',
      description: '一大群鱼正经过你的渔场！这是一个绝佳的钓鱼机会！',
      emoji: '🐟',
      duration: const Duration(minutes: 5),
      startTime: DateTime.now(),
    ),

    // Boss入侵
    RandomEvent(
      id: 'boss_invasion',
      type: RandomEventType.bossInvasion,
      title: 'Boss入侵！',
      description: '一个强大的Boss正在接近你的渔场！准备好战斗！',
      emoji: '⚠️',
      duration: const Duration(minutes: 10),
      startTime: DateTime.now(),
    ),

    // 黄金时刻
    RandomEvent(
      id: 'golden_hour',
      type: RandomEventType.goldenHour,
      title: '黄金时刻',
      description: '海面泛起金光，传说鱼的出现概率大幅提升！',
      emoji: '✨',
      duration: const Duration(minutes: 3),
      startTime: DateTime.now(),
    ),
  ];

  /// 随机生成一个事件
  static RandomEvent generateRandomEvent() {
    final template = eventTemplates[_random.nextInt(eventTemplates.length)];
    return RandomEvent(
      id: '${template.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: template.type,
      title: template.title,
      description: template.description,
      emoji: template.emoji,
      duration: template.duration,
      choice: template.choice,
      startTime: DateTime.now(),
    );
  }

  /// 根据类型生成事件
  static RandomEvent generateEventByType(RandomEventType type) {
    final templates = eventTemplates.where((e) => e.type == type).toList();
    if (templates.isEmpty) {
      return generateRandomEvent();
    }
    final template = templates[_random.nextInt(templates.length)];
    return RandomEvent(
      id: '${template.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: template.type,
      title: template.title,
      description: template.description,
      emoji: template.emoji,
      duration: template.duration,
      choice: template.choice,
      startTime: DateTime.now(),
    );
  }

  /// 检查是否应该触发事件（基于概率）
  static bool shouldTriggerEvent() {
    // 5% 的概率触发事件
    return _random.nextDouble() < 0.05;
  }

  /// 获取事件类型的效果描述
  static String getTypeEffect(RandomEventType type) {
    switch (type) {
      case RandomEventType.merchant:
        return '可以购买稀有物品';
      case RandomEventType.treasure:
        return '可能获得丰厚奖励';
      case RandomEventType.whirlpool:
        return '高风险高回报';
      case RandomEventType.fishSwarm:
        return '钓鱼速度提升50%';
      case RandomEventType.bossInvasion:
        return '击败Boss获得额外奖励';
      case RandomEventType.goldenHour:
        return '传说鱼概率提升5倍';
    }
  }
}

/// 事件状态
class EventState {
  final RandomEvent? activeEvent;
  final List<RandomEvent> eventHistory;

  const EventState({
    this.activeEvent,
    this.eventHistory = const [],
  });

  bool get hasActiveEvent => activeEvent != null && !activeEvent!.isExpired;

  EventState copyWith({
    RandomEvent? activeEvent,
    List<RandomEvent>? eventHistory,
    bool clearActiveEvent = false,
  }) {
    return EventState(
      activeEvent: clearActiveEvent ? null : (activeEvent ?? this.activeEvent),
      eventHistory: eventHistory ?? this.eventHistory,
    );
  }

  Map<String, dynamic> toJson() => {
    'activeEvent': activeEvent?.toJson(),
    'eventHistory': eventHistory.map((e) => e.toJson()).toList(),
  };

  factory EventState.fromJson(Map<String, dynamic> json) {
    return EventState(
      activeEvent: json['activeEvent'] != null
          ? RandomEvent.fromJson(json['activeEvent'])
          : null,
      eventHistory: (json['eventHistory'] as List?)
          ?.map((e) => RandomEvent.fromJson(e))
          .toList() ?? [],
    );
  }
}
