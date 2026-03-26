import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 排行榜类型
enum LeaderboardType {
  totalCoins,       // 总金币
  fishCaught,       // 钓鱼数量
  bossDefeated,     // Boss击败数
  achievementScore, // 成就积分
  collectionScore,  // 收集积分
  highestPower,     // 最高战力
}

/// 排行榜条目
class LeaderboardEntry {
  final String playerName;
  final int score;
  final int rank;
  final DateTime updatedAt;

  const LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.rank,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'score': score,
    'rank': rank,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      playerName: json['playerName'] ?? '匿名玩家',
      score: json['score'] ?? 0,
      rank: json['rank'] ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}

/// 排行榜数据
class LeaderboardData {
  final LeaderboardType type;
  final List<LeaderboardEntry> entries;
  final DateTime lastUpdated;

  const LeaderboardData({
    required this.type,
    required this.entries,
    required this.lastUpdated,
  });

  LeaderboardEntry? getMyEntry(String playerName) {
    return entries.where((e) => e.playerName == playerName).firstOrNull;
  }

  int getMyRank(String playerName) {
    final index = entries.indexWhere((e) => e.playerName == playerName);
    return index >= 0 ? index + 1 : 0;
  }
}

/// 本地排行榜管理器（可扩展为在线排行榜）
class LeaderboardNotifier extends StateNotifier<Map<LeaderboardType, LeaderboardData>> {
  static const String _defaultPlayer = '你';
  static final Random _random = Random();

  LeaderboardNotifier() : super(_initializeLeaderboards());

  /// 初始化排行榜
  static Map<LeaderboardType, LeaderboardData> _initializeLeaderboards() {
    return {
      for (final type in LeaderboardType.values)
        type: LeaderboardData(
          type: type,
          entries: _generateFakeLeaderboard(type),
          lastUpdated: DateTime.now(),
        ),
    };
  }

  /// 生成假数据（用于本地展示）
  static List<LeaderboardEntry> _generateFakeLeaderboard(LeaderboardType type) {
    final names = [
      '钓鱼大师', '海王', '鱼神', '渔夫老张', '深海猎人',
      '龙宫使者', '水手小王', '渔村村长', '海洋霸主', '金鱼王子',
      '渔民阿强', '海上漂', '蓝鲸守护者', '珊瑚公主', '浪潮之子',
    ];

    final baseScores = {
      LeaderboardType.totalCoins: [500000, 350000, 200000, 150000, 100000, 80000, 60000, 45000, 30000, 20000],
      LeaderboardType.fishCaught: [5000, 3500, 2000, 1500, 1000, 800, 600, 450, 300, 200],
      LeaderboardType.bossDefeated: [50, 35, 20, 15, 10, 8, 6, 4, 3, 2],
      LeaderboardType.achievementScore: [5000, 3500, 2000, 1500, 1000, 800, 600, 450, 300, 200],
      LeaderboardType.collectionScore: [100, 80, 60, 50, 40, 30, 25, 20, 15, 10],
      LeaderboardType.highestPower: [100000, 80000, 60000, 45000, 30000, 20000, 15000, 10000, 7500, 5000],
    };

    final scores = baseScores[type] ?? List.generate(10, (i) => 1000 - i * 100);

    return List.generate(10, (index) {
      return LeaderboardEntry(
        playerName: names[_random.nextInt(names.length)],
        score: scores[index] + _random.nextInt(scores[index] ~/ 10),
        rank: index + 1,
        updatedAt: DateTime.now().subtract(Duration(hours: _random.nextInt(24))),
      );
    });
  }

  /// 更新玩家分数
  void updateScore(LeaderboardType type, int score) {
    final current = state[type];
    if (current == null) return;

    final entries = List<LeaderboardEntry>.from(current.entries);

    // 移除旧的玩家条目
    entries.removeWhere((e) => e.playerName == _defaultPlayer);

    // 添加新分数
    entries.add(LeaderboardEntry(
      playerName: _defaultPlayer,
      score: score,
      rank: 0,
      updatedAt: DateTime.now(),
    ));

    // 按分数排序
    entries.sort((a, b) => b.score.compareTo(a.score));

    // 更新排名
    final rankedEntries = entries.asMap().entries.map((e) {
      return LeaderboardEntry(
        playerName: e.value.playerName,
        score: e.value.score,
        rank: e.key + 1,
        updatedAt: e.value.updatedAt,
      );
    }).toList();

    // 只保留前 10 名
    state = {
      ...state,
      type: LeaderboardData(
        type: type,
        entries: rankedEntries.take(10).toList(),
        lastUpdated: DateTime.now(),
      ),
    };
  }

  /// 批量更新多个分数
  void updateScores(Map<LeaderboardType, int> scores) {
    scores.forEach((type, score) {
      updateScore(type, score);
    });
  }

  /// 获取排行榜
  LeaderboardData? getLeaderboard(LeaderboardType type) {
    return state[type];
  }

  /// 获取玩家在指定排行榜的排名
  int getMyRank(LeaderboardType type) {
    final data = state[type];
    if (data == null) return 0;
    return data.getMyRank(_defaultPlayer);
  }

  /// 获取玩家排名摘要
  Map<LeaderboardType, int> getMyRanks() {
    return {
      for (final type in LeaderboardType.values)
        type: getMyRank(type),
    };
  }
}

/// Provider
final leaderboardProvider = StateNotifierProvider<LeaderboardNotifier, Map<LeaderboardType, LeaderboardData>>((ref) {
  return LeaderboardNotifier();
});

/// 获取指定类型的排行榜
final leaderboardByTypeProvider = Provider.family<LeaderboardData?, LeaderboardType>((ref, type) {
  return ref.watch(leaderboardProvider)[type];
});

/// 获取玩家排名摘要
final myRanksProvider = Provider<Map<LeaderboardType, int>>((ref) {
  return ref.watch(leaderboardProvider.notifier).getMyRanks();
});

/// 排行榜类型显示名称
String getLeaderboardTypeName(LeaderboardType type) {
  switch (type) {
    case LeaderboardType.totalCoins:
      return '金币榜';
    case LeaderboardType.fishCaught:
      return '钓鱼榜';
    case LeaderboardType.bossDefeated:
      return '战斗榜';
    case LeaderboardType.achievementScore:
      return '成就榜';
    case LeaderboardType.collectionScore:
      return '收集榜';
    case LeaderboardType.highestPower:
      return '战力榜';
  }
}

String getLeaderboardTypeIcon(LeaderboardType type) {
  switch (type) {
    case LeaderboardType.totalCoins:
      return '💰';
    case LeaderboardType.fishCaught:
      return '🐟';
    case LeaderboardType.bossDefeated:
      return '⚔️';
    case LeaderboardType.achievementScore:
      return '🏆';
    case LeaderboardType.collectionScore:
      return '📚';
    case LeaderboardType.highestPower:
      return '💪';
  }
}
