import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/goal_service.dart';

/// 目标面板组件
class GoalPanel extends ConsumerWidget {
  const GoalPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalProvider);
    final claimableCount = ref.watch(claimableGoalsCountProvider);
    final recommendedGoal = ref.watch(recommendedGoalProvider);

    final activeGoals = goals.values
        .where((g) => !g.isCompleted || !g.isClaimed)
        .toList()
      ..sort((a, b) {
        // 未完成的排前面，然后按进度排序
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return b.progress.compareTo(a.progress);
      });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🎯 目标',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (claimableCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$claimableCount 可领取',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 推荐目标
          if (recommendedGoal != null) ...[
            _buildRecommendedGoal(context, ref, recommendedGoal),
            const SizedBox(height: 12),
            const Divider(color: Colors.grey),
            const SizedBox(height: 12),
          ],

          // 目标列表
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: activeGoals.take(5).length,
              itemBuilder: (context, index) {
                return _buildGoalItem(context, ref, activeGoals[index]);
              },
            ),
          ),

          // 查看全部按钮
          if (goals.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: TextButton(
                  onPressed: () => _showAllGoals(context, ref),
                  child: Text(
                    '查看全部 ${goals.length} 个目标',
                    style: TextStyle(color: Colors.blue[300]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendedGoal(BuildContext context, WidgetRef ref, Goal goal) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Text(goal.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '推荐: ${goal.title}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  goal.description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    backgroundColor: Colors.grey[700],
                    valueColor: const AlwaysStoppedAnimation(Colors.blue),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            goal.progressText,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(BuildContext context, WidgetRef ref, Goal goal) {
    final canClaim = goal.isCompleted && !goal.isClaimed;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: canClaim
            ? Colors.orange.withValues(alpha: 0.2)
            : Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: canClaim
            ? Border.all(color: Colors.orange)
            : null,
      ),
      child: Row(
        children: [
          // Emoji
          Text(
            goal.emoji,
            style: TextStyle(
              fontSize: 20,
              color: goal.isCompleted ? Colors.white : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),

          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: TextStyle(
                    color: goal.isCompleted ? Colors.white : Colors.grey[400],
                    fontWeight: goal.isCompleted ? FontWeight.bold : FontWeight.normal,
                    decoration: goal.isClaimed ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (!goal.isCompleted)
                  Text(
                    goal.progressText,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),

          // 进度条或领取按钮
          if (canClaim)
            ElevatedButton(
              onPressed: () => _claimReward(context, ref, goal),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(60, 28),
              ),
              child: const Text('领取'),
            )
          else if (!goal.isCompleted)
            SizedBox(
              width: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  backgroundColor: Colors.grey[700],
                  valueColor: AlwaysStoppedAnimation(
                    _getProgressColor(goal.type),
                  ),
                  minHeight: 4,
                ),
              ),
            )
          else
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
        ],
      ),
    );
  }

  Color _getProgressColor(GoalType type) {
    switch (type) {
      case GoalType.tutorial:
        return Colors.blue;
      case GoalType.daily:
        return Colors.green;
      case GoalType.weekly:
        return Colors.purple;
      case GoalType.milestone:
        return Colors.orange;
    }
  }

  void _claimReward(BuildContext context, WidgetRef ref, Goal goal) {
    final rewards = ref.read(goalProvider.notifier).claimReward(goal.id);

    // 显示奖励
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          '🎉 ${goal.title}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: rewards.map((r) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                r.description,
                style: const TextStyle(color: Colors.amber, fontSize: 16),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAllGoals(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => _AllGoalsPanel(
          scrollController: scrollController,
        ),
      ),
    );
  }
}

/// 全部目标面板
class _AllGoalsPanel extends ConsumerWidget {
  final ScrollController scrollController;

  const _AllGoalsPanel({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 全部目标',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: GoalType.values.map((type) {
                final goals = ref.watch(goalsByTypeProvider(type));
                if (goals.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeHeader(type),
                    const SizedBox(height: 8),
                    ...goals.map((g) => _buildGoalItem(context, ref, g)),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeHeader(GoalType type) {
    String title;
    String emoji;
    switch (type) {
      case GoalType.tutorial:
        title = '新手目标';
        emoji = '🎓';
        break;
      case GoalType.daily:
        title = '每日目标';
        emoji = '📅';
        break;
      case GoalType.weekly:
        title = '每周目标';
        emoji = '📆';
        break;
      case GoalType.milestone:
        title = '里程碑';
        emoji = '🏆';
        break;
    }

    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalItem(BuildContext context, WidgetRef ref, Goal goal) {
    final canClaim = goal.isCompleted && !goal.isClaimed;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(goal.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: TextStyle(
                    color: goal.isCompleted ? Colors.white : Colors.grey[400],
                    decoration: goal.isClaimed ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  goal.description,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (canClaim)
            TextButton(
              onPressed: () {
                ref.read(goalProvider.notifier).claimReward(goal.id);
              },
              child: const Text('领取'),
            )
          else if (!goal.isCompleted)
            Text(
              goal.progressText,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            )
          else
            const Icon(Icons.check, color: Colors.green, size: 16),
        ],
      ),
    );
  }
}
