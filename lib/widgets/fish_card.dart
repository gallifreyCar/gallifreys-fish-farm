import 'package:flutter/material.dart';
import '../models/fish.dart';
import '../utils/constants.dart';

/// 鱼卡片组件
class FishCard extends StatelessWidget {
  final Fish fish;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FishCard({
    super.key,
    required this.fish,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = Color(GameConstants.rarityColors[fish.rarity]!);
    final rarityName = GameConstants.rarityNames[fish.rarity]!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: rarityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 鱼图标
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: rarityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    fish.emoji,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 鱼信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fish.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$rarityName · Lv.${fish.level}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // 收入
              Text(
                '💰${fish.income}/s',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
