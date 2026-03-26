import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';

/// 商店页面 - 升级装备
class ShopScreen extends ConsumerWidget {
  final Player player;

  const ShopScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 金币显示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[400]!, Colors.amber[600]!],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    '💰 我的金币',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    player.coins.toString(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 升级项目
            const Text(
              '🔧 装备升级',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _UpgradeCard(
              icon: '🎣',
              title: '鱼竿',
              level: player.equipment.rodLevel,
              effect: '钓鱼速度 +${((player.equipment.fishingSpeedBonus - 1) * 100).toInt()}%',
              nextEffect: '钓鱼速度 +${((player.equipment.fishingSpeedBonus + 0.1 - 1) * 100).toInt()}%',
              cost: player.equipment.rodUpgradeCost,
              canAfford: player.coins >= player.equipment.rodUpgradeCost,
              onUpgrade: () => _upgradeRod(context, ref),
            ),

            const SizedBox(height: 12),

            _UpgradeCard(
              icon: '🪱',
              title: '鱼饵',
              level: player.equipment.baitLevel,
              effect: '稀有鱼概率 +${(player.equipment.rareFishBonus * 100).toInt()}%',
              nextEffect: '稀有鱼概率 +${((player.equipment.baitLevel) * 5)}%',
              cost: player.equipment.baitUpgradeCost,
              canAfford: player.coins >= player.equipment.baitUpgradeCost,
              onUpgrade: () => _upgradeBait(context, ref),
            ),

            const SizedBox(height: 12),

            _UpgradeCard(
              icon: '🏠',
              title: '鱼池',
              level: player.equipment.pondLevel,
              effect: '容量 ${player.equipment.pondCapacity} 条',
              nextEffect: '容量 ${player.equipment.pondCapacity + 5} 条',
              cost: player.equipment.pondUpgradeCost,
              canAfford: player.coins >= player.equipment.pondUpgradeCost,
              onUpgrade: () => _upgradePond(context, ref),
            ),

            const SizedBox(height: 24),

            // 购买鱼食
            const Text(
              '🍖 购买鱼食',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _FoodCard(
                    amount: 10,
                    cost: 50,
                    canAfford: player.coins >= 50,
                    onBuy: () => _buyFood(context, ref, 10, 50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FoodCard(
                    amount: 50,
                    cost: 200,
                    canAfford: player.coins >= 200,
                    onBuy: () => _buyFood(context, ref, 50, 200),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FoodCard(
                    amount: 100,
                    cost: 350,
                    canAfford: player.coins >= 350,
                    onBuy: () => _buyFood(context, ref, 100, 350),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _upgradeRod(BuildContext context, WidgetRef ref) {
    if (ref.read(gameProvider.notifier).upgradeRod()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎣 鱼竿升级成功！')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('金币不足！'), backgroundColor: Colors.red),
      );
    }
  }

  void _upgradeBait(BuildContext context, WidgetRef ref) {
    if (ref.read(gameProvider.notifier).upgradeBait()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🪱 鱼饵升级成功！')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('金币不足！'), backgroundColor: Colors.red),
      );
    }
  }

  void _upgradePond(BuildContext context, WidgetRef ref) {
    if (ref.read(gameProvider.notifier).upgradePond()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🏠 鱼池升级成功！')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('金币不足！'), backgroundColor: Colors.red),
      );
    }
  }

  void _buyFood(BuildContext context, WidgetRef ref, int amount, int cost) {
    // TODO: 实现购买鱼食
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🍖 购买了 $amount 鱼食！')),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  final String icon;
  final String title;
  final int level;
  final String effect;
  final String nextEffect;
  final int cost;
  final bool canAfford;
  final VoidCallback onUpgrade;

  const _UpgradeCard({
    required this.icon,
    required this.title,
    required this.level,
    required this.effect,
    required this.nextEffect,
    required this.cost,
    required this.canAfford,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 图标
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 16),

            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Lv.$level',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '当前：$effect',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '下一级：$nextEffect',
                    style: TextStyle(fontSize: 12, color: Colors.green[700]),
                  ),
                ],
              ),
            ),

            // 升级按钮
            ElevatedButton(
              onPressed: canAfford ? onUpgrade : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Column(
                children: [
                  const Text('升级', style: TextStyle(fontSize: 12)),
                  Text(
                    '💰$cost',
                    style: const TextStyle(fontSize: 10),
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

class _FoodCard extends StatelessWidget {
  final int amount;
  final int cost;
  final bool canAfford;
  final VoidCallback onBuy;

  const _FoodCard({
    required this.amount,
    required this.cost,
    required this.canAfford,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: canAfford ? onBuy : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text('🍖', style: TextStyle(fontSize: 28)),
              Text(
                'x$amount',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '💰$cost',
                style: TextStyle(
                  fontSize: 12,
                  color: canAfford ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
