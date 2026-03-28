import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/fish.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';

/// 工作页面 - 指派鱼工作
class WorkScreen extends ConsumerWidget {
  final Player player;

  const WorkScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workingFish = player.ownedFish.where((f) => f.currentJob != JobType.idle).toList();
    final idleFish = player.ownedFish.where((f) => f.currentJob == JobType.idle).toList();

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // 收入概览
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    '当前每秒收入',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '💰',
                        style: TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        player.incomePerSecond.toString(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${workingFish.length} 条鱼正在工作',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // 标签栏
            const TabBar(
              tabs: [
                Tab(text: '工作中的鱼'),
                Tab(text: '闲置的鱼'),
              ],
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
            ),

            // 鱼列表
            Expanded(
              child: TabBarView(
                children: [
                  _FishJobList(
                    fishList: workingFish,
                    player: player,
                  ),
                  _FishJobList(
                    fishList: idleFish,
                    player: player,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FishJobList extends ConsumerWidget {
  final List<Fish> fishList;
  final Player player;

  const _FishJobList({
    required this.fishList,
    required this.player,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (fishList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🐟', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              '没有${context.findAncestorWidgetOfExactType<Tab>()?.text ?? '鱼'}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fishList.length,
      itemBuilder: (context, index) {
        final fish = fishList[index];
        return _JobFishCard(
          fish: fish,
          onAssignJob: (job) {
            ref.read(gameProvider.notifier).assignJob(fish.id, job);
          },
          onFeed: () {
            if (ref.read(gameProvider.notifier).feedFish(fish.id)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('喂食了 ${fish.emoji} ${fish.name}！'),
                  duration: const Duration(seconds: 1),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('鱼食不足！'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          canFeed: player.fishFood > 0,
          onSell: () {
            _showSellDialog(context, ref, fish);
          },
        );
      },
    );
  }

  void _showSellDialog(BuildContext context, WidgetRef ref, Fish fish) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('出售 ${fish.emoji} ${fish.name}？'),
        content: Text('出售价格：${fish.baseValue * fish.level} 金币'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(gameProvider.notifier).sellFish(fish.id);
              Navigator.pop(context);
            },
            child: const Text('确认出售'),
          ),
        ],
      ),
    );
  }
}

class _JobFishCard extends StatelessWidget {
  final Fish fish;
  final void Function(JobType) onAssignJob;
  final VoidCallback onFeed;
  final bool canFeed;
  final VoidCallback onSell;

  const _JobFishCard({
    required this.fish,
    required this.onAssignJob,
    required this.onFeed,
    required this.canFeed,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = Color(GameConstants.rarityColors[fish.rarity]!);
    final trait = fish.trait;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 基本信息
            Row(
              children: [
                Text(fish.emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            fish.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: rarityColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Lv.${fish.level}',
                              style: TextStyle(
                                fontSize: 12,
                                color: rarityColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '💰 ${fish.income}/秒',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                        ),
                      ),
                      if (trait != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: rarityColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${trait.emoji} ${trait.name} · ${trait.description}',
                            style: TextStyle(
                              fontSize: 11,
                              color: rarityColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 操作按钮
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: canFeed ? onFeed : null,
                      icon: const Icon(Icons.restaurant),
                      tooltip: '喂食',
                      color: canFeed ? Colors.orange : Colors.grey,
                    ),
                    IconButton(
                      onPressed: onSell,
                      icon: const Icon(Icons.sell),
                      tooltip: '出售',
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),

            const Divider(),

            // 工作选择
            Wrap(
              spacing: 8,
              children: JobType.values.map((job) {
                final isSelected = fish.currentJob == job;
                final jobEmoji = GameConstants.jobEmojis[job]!;
                final jobName = GameConstants.jobNames[job]!;

                return ChoiceChip(
                  label: Text('$jobEmoji $jobName'),
                  selected: isSelected,
                  onSelected: (_) => onAssignJob(job),
                  selectedColor: Colors.green[200],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
