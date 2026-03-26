import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../providers/game_provider.dart';

/// 成就页面
class AchievementScreen extends ConsumerWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = Achievement.allAchievements;
    final progress = ref.watch(achievementsProvider);
    final claimableCount = ref.watch(claimableAchievementsProvider);

    // 按类型分组
    final groupedAchievements = <AchievementType, List<Achievement>>{};
    for (final a in achievements) {
      groupedAchievements.putIfAbsent(a.type, () => []).add(a);
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆 成就', style: TextStyle(color: Colors.white)),
            if (claimableCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$claimableCount 可领取',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: AchievementType.values.map((type) {
          final typeAchievements = groupedAchievements[type] ?? [];
          if (typeAchievements.isEmpty) return const SizedBox.shrink();

          return _AchievementTypeSection(
            type: type,
            achievements: typeAchievements,
            progress: progress,
          );
        }).toList(),
      ),
    );
  }
}

class _AchievementTypeSection extends StatelessWidget {
  final AchievementType type;
  final List<Achievement> achievements;
  final Map<String, AchievementProgress> progress;

  const _AchievementTypeSection({
    required this.type,
    required this.achievements,
    required this.progress,
  });

  String get _typeName {
    switch (type) {
      case AchievementType.fishing:
        return '🎣 钓鱼';
      case AchievementType.battle:
        return '⚔️ 战斗';
      case AchievementType.economy:
        return '💰 经济';
      case AchievementType.collection:
        return '📚 收集';
      case AchievementType.prestige:
        return '🔄 转生';
      case AchievementType.special:
        return '✨ 特殊';
    }
  }

  Color get _typeColor {
    switch (type) {
      case AchievementType.fishing:
        return Colors.blue;
      case AchievementType.battle:
        return Colors.red;
      case AchievementType.economy:
        return Colors.amber;
      case AchievementType.collection:
        return Colors.purple;
      case AchievementType.prestige:
        return Colors.cyan;
      case AchievementType.special:
        return Colors.pink;
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = achievements.where((a) {
      final p = progress[a.id];
      return p != null && p.isCompleted;
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(
                _typeName,
                style: TextStyle(
                  color: _typeColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '($completed/${achievements.length})',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        ...achievements.map((a) => _AchievementCard(
          achievement: a,
          progress: progress[a.id] ?? AchievementProgress(achievementId: a.id),
          typeColor: _typeColor,
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _AchievementCard extends ConsumerWidget {
  final Achievement achievement;
  final AchievementProgress progress;
  final Color typeColor;

  const _AchievementCard({
    required this.achievement,
    required this.progress,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = progress.isCompleted;
    final isClaimed = progress.isClaimed;
    final currentProgress = progress.currentValue;
    final target = achievement.targetValue;
    final progressPercent = (currentProgress / target).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isClaimed
            ? Colors.grey[800]!.withAlpha(128)
            : Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: isCompleted && !isClaimed
            ? Border.all(color: Colors.orange, width: 2)
            : isClaimed
                ? Border.all(color: Colors.green.withAlpha(100), width: 1)
                : null,
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: typeColor.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                isClaimed ? '✅' : achievement.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.name,
                        style: TextStyle(
                          color: isClaimed ? Colors.grey[500] : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: isClaimed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),

                // 进度条
                if (!isCompleted) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      backgroundColor: Colors.grey[700],
                      valueColor: AlwaysStoppedAnimation(typeColor),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$currentProgress / $target',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 奖励/领取按钮
          if (isCompleted && !isClaimed)
            ElevatedButton(
              onPressed: () {
                ref.read(gameProvider.notifier).claimAchievement(achievement.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('领取', style: TextStyle(fontSize: 12)),
            )
          else if (isClaimed)
            Text(
              '已领取',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (achievement.rewardCoins > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💰', style: TextStyle(fontSize: 10)),
                      Text(
                        ' ${achievement.rewardCoins}',
                        style: TextStyle(
                          color: Colors.amber[300],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                if (achievement.rewardFishFood > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🍖', style: TextStyle(fontSize: 10)),
                      Text(
                        ' ${achievement.rewardFishFood}',
                        style: TextStyle(
                          color: Colors.brown[300],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                if (achievement.rewardFishRarity != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🐟', style: TextStyle(fontSize: 10)),
                      Text(
                        ' ${achievement.rewardFishRarity!}',
                        style: TextStyle(
                          color: _getRarityColor(achievement.rewardFishRarity!),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'rare':
        return Colors.blue[300]!;
      case 'epic':
        return Colors.purple[300]!;
      case 'legendary':
        return Colors.orange[300]!;
      default:
        return Colors.grey[300]!;
    }
  }
}
