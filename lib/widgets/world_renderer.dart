import 'dart:math';
import 'package:flutter/material.dart';
import '../models/fish.dart';
import '../models/building.dart';
import '../providers/world_provider.dart';

/// 俯视世界场景渲染器
class WorldRenderer extends StatelessWidget {
  final WorldState worldState;
  final VoidCallback? onBuildingTap;
  final void Function(Fish)? onFishTap;

  const WorldRenderer({
    super.key,
    required this.worldState,
    this.onBuildingTap,
    this.onFishTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WorldPainter(
        buildings: worldState.buildings,
        worldFish: worldState.worldFish,
        time: worldState.time,
      ),
      size: Size.infinite,
    );
  }
}

/// 场景绘制器
class WorldPainter extends CustomPainter {
  final List<Building> buildings;
  final List<WorldFish> worldFish;
  final double time;

  WorldPainter({
    required this.buildings,
    required this.worldFish,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景（草地+水）
    _drawBackground(canvas, size);

    // 绘制区域分隔
    _drawZones(canvas, size);

    // 绘制建筑
    for (final building in buildings) {
      _drawBuilding(canvas, building);
    }

    // 绘制鱼
    for (final wf in worldFish) {
      _drawFish(canvas, wf);
    }

    // 绘制资源产出动画
    _drawResourceAnimations(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    // 天空
    final skyPaint = Paint()..color = const Color(0xFF87CEEB);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 150), skyPaint);

    // 草地
    final grassPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(Rect.fromLTWH(0, 150, size.width, size.height - 150), grassPaint);

    // 海洋区域（左侧）
    final waterPaint = Paint()..color = const Color(0xFF2196F3).withAlpha(180);
    canvas.drawRect(Rect.fromLTWH(0, 150, 150, size.height - 150), waterPaint);

    // 添加水波纹效果
    final wavePaint = Paint()
      ..color = Colors.white.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      final waveY = 200.0 + i * 80 + sin(time * 2 + i) * 5;
      final path = Path();
      path.moveTo(0, waveY);
      for (double x = 0; x < 150; x += 5) {
        path.lineTo(x, waveY + sin(x * 0.05 + time * 3 + i) * 3);
      }
      canvas.drawPath(path, wavePaint);
    }
  }

  void _drawZones(Canvas canvas, Size size) {
    // 区域标签
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 海边区域标签
    textPainter.text = const TextSpan(
      text: '🌊 海边',
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(10, 155));

    // 村庄区域标签
    textPainter.text = const TextSpan(
      text: '🏠 鱼村',
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(180, 155));

    // 山区区域标签
    textPainter.text = const TextSpan(
      text: '🏔️ 探险区',
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(340, 155));
  }

  void _drawBuilding(Canvas canvas, Building building) {
    if (!building.isUnlocked) {
      // 未解锁的建筑显示为阴影
      final shadowPaint = Paint()..color = Colors.grey.withAlpha(100);
      canvas.drawRect(
        Rect.fromLTWH(
          building.posX.toDouble(),
          building.posY.toDouble(),
          building.size.$1 * 40.0,
          building.size.$2 * 40.0,
        ),
        shadowPaint,
      );

      // 绁锁图标
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '🔒',
          style: TextStyle(fontSize: 24),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          building.posX + building.size.$1 * 20 - 12,
          building.posY + building.size.$2 * 20 - 12,
        ),
      );
      return;
    }

    // 建筑背景
    final bgPaint = Paint()
      ..color = _getBuildingColor(building.type);
    canvas.drawRect(
      Rect.fromLTWH(
        building.posX.toDouble(),
        building.posY.toDouble(),
        building.size.$1 * 40.0,
        building.size.$2 * 40.0,
      ),
      bgPaint,
    );

    // 建筑边框
    final borderPaint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(
      Rect.fromLTWH(
        building.posX.toDouble(),
        building.posY.toDouble(),
        building.size.$1 * 40.0,
        building.size.$2 * 40.0,
      ),
      borderPaint,
    );

    // 建筑图标
    final textPainter = TextPainter(
      text: TextSpan(
        text: building.emoji,
        style: const TextStyle(fontSize: 32),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        building.posX + building.size.$1 * 20 - 16,
        building.posY + building.size.$2 * 20 - 20,
      ),
    );

    // 等级标签
    final levelPainter = TextPainter(
      text: TextSpan(
        text: 'Lv.${building.level}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    levelPainter.paint(
      canvas,
      Offset(building.posX + 2, building.posY + 2),
    );
  }

  Color _getBuildingColor(BuildingType type) {
    switch (type) {
      case BuildingType.dock:
        return const Color(0xFF8B4513);
      case BuildingType.shop:
        return const Color(0xFFFFA726);
      case BuildingType.farm:
        return const Color(0xFF8BC34A);
      case BuildingType.mine:
        return const Color(0xFF795548);
      case BuildingType.training:
        return const Color(0xFFE91E63);
      case BuildingType.temple:
        return const Color(0xFF9C27B0);
    }
  }

  void _drawFish(Canvas canvas, WorldFish wf) {
    // 鱼的阴影
    final shadowPaint = Paint()..color = Colors.black.withAlpha(30);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(wf.x, wf.y + 15),
        width: 20,
        height: 8,
      ),
      shadowPaint,
    );

    // 根据状态调整动画
    double scale = 1.0;
    double offsetY = 0;

    switch (wf.state) {
      case FishState.idle:
        // 待机时微微上下浮动
        offsetY = sin(wf.animFrame * 0.5) * 2;
        break;
      case FishState.walking:
        // 移动时左右摇摆
        scale = 1.0 + sin(wf.animFrame) * 0.05;
        break;
      case FishState.working:
        // 工作时有节奏的缩放
        scale = 1.0 + sin(wf.animFrame * 2) * 0.1;
        break;
      case FishState.fighting:
        // 战斗时快速抖动
        offsetY = sin(wf.animFrame * 5) * 3;
        break;
    }

    // 绘制鱼图标
    final textPainter = TextPainter(
      text: TextSpan(
        text: wf.fish.emoji,
        style: TextStyle(
          fontSize: 24 * scale,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        wf.x - textPainter.width / 2,
        wf.y - textPainter.height / 2 + offsetY,
      ),
    );

    // 工作状态指示器
    if (wf.state == FishState.working) {
      final indicatorPainter = TextPainter(
        text: TextSpan(
          text: _getJobEmoji(wf.fish.currentJob),
          style: const TextStyle(fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      indicatorPainter.paint(
        canvas,
        Offset(wf.x + 8, wf.y - 20),
      );
    }
  }

  String _getJobEmoji(JobType job) {
    switch (job) {
      case JobType.idle:
        return '😴';
      case JobType.fishing:
        return '🎣';
      case JobType.farming:
        return '🌾';
      case JobType.mining:
        return '⛏️';
      case JobType.shop:
        return '💰';
    }
  }

  void _drawResourceAnimations(Canvas canvas, Size size) {
    // 金币飘动动画
    for (final building in buildings) {
      if (!building.isUnlocked || building.outputRate == 0) continue;

      // 每隔一段时间显示产出图标
      final cycleTime = (time + building.posX * 0.1) % 3;
      if (cycleTime < 1) {
        final alpha = (1 - cycleTime) * 255;
        final yOffset = cycleTime * 30;

        final textPainter = TextPainter(
          text: TextSpan(
            text: '💰',
            style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(alpha.toInt())),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(
            building.posX + 20.0,
            building.posY - yOffset,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(WorldPainter oldDelegate) {
    return time != oldDelegate.time ||
        worldFish.length != oldDelegate.worldFish.length ||
        buildings.any((b) =>
            oldDelegate.buildings.firstWhere((ob) => ob.id == b.id,
                orElse: () => Building(id: '', type: BuildingType.dock, name: '', emoji: '')).isUnlocked != b.isUnlocked);
  }
}
