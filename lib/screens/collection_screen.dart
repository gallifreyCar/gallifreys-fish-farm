import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/fish.dart';
import '../utils/constants.dart';

/// 图鉴页面 - 展示所有收集的鱼
class CollectionScreen extends StatelessWidget {
  final Player player;

  const CollectionScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🐟 我的鱼宠',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${player.ownedFish.length}/${player.equipment.pondCapacity}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // 鱼列表
          Expanded(
            child: player.ownedFish.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🎣', style: TextStyle(fontSize: 60)),
                        SizedBox(height: 16),
                        Text(
                          '还没有钓到鱼',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          '开始钓鱼吧！',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: player.ownedFish.length,
                    itemBuilder: (context, index) {
                      final fish = player.ownedFish[index];
                      return _FishListItem(fish: fish);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FishListItem extends StatelessWidget {
  final Fish fish;

  const _FishListItem({required this.fish});

  @override
  Widget build(BuildContext context) {
    final rarityColor = Color(GameConstants.rarityColors[fish.rarity]!);
    final rarityName = GameConstants.rarityNames[fish.rarity]!;
    final jobName = GameConstants.jobNames[fish.currentJob]!;
    final jobEmoji = GameConstants.jobEmojis[fish.currentJob]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: rarityColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 鱼图标
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: rarityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  fish.emoji,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 鱼信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        fish.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: rarityColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          rarityName,
                          style: TextStyle(
                            fontSize: 10,
                            color: rarityColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Lv.${fish.level}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$jobEmoji $jobName',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '💰 ${fish.income}/秒',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 状态图标
            Column(
              children: [
                Text(
                  fish.currentJob != JobType.idle ? '💼' : '😴',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  fish.currentJob != JobType.idle ? '工作中' : '闲置',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
