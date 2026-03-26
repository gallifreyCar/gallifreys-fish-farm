import 'dart:math';
import 'package:flutter/material.dart';
import '../models/battle.dart';
import '../models/boss.dart';

/// 横版战斗竞技场渲染器
class BattleArena extends StatelessWidget {
  final List<BattleFish> battleFish;
  final Boss boss;
  final double time;

  const BattleArena({
    super.key,
    required this.battleFish,
    required this.boss,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BattleArenaPainter(
        battleFish: battleFish,
        boss: boss,
        time: time,
      ),
      size: Size.infinite,
    );
  }
}

class BattleArenaPainter extends CustomPainter {
  final List<BattleFish> battleFish;
  final Boss boss;
  final double time;

  BattleArenaPainter({
    required this.battleFish,
    required this.boss,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景
    _drawBackground(canvas, size);

    // 绘制地面
    _drawGround(canvas, size);

    // 绘制Boss
    _drawBoss(canvas, size);

    // 绘制鱼宠
    for (final bf in battleFish) {
      _drawBattleFish(canvas, bf, size);
    }

    // 绘制战斗特效
    _drawBattleEffects(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    // 天空渐变
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF1a237e),
        const Color(0xFF3949ab),
      ],
    );
    final skyPaint = Paint()
      ..shader = skyGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.7));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.7), skyPaint);

    // 星星效果
    final starPaint = Paint()..color = Colors.white.withAlpha(150);
    for (int i = 0; i < 20; i++) {
      final x = (i * 47 + time * 0.5) % size.width;
      final y = (i * 31) % (size.height * 0.5);
      final twinkle = sin(time * 3 + i) * 0.5 + 0.5;
      canvas.drawCircle(
        Offset(x, y),
        1 + twinkle,
        starPaint,
      );
    }
  }

  void _drawGround(Canvas canvas, Size size) {
    // 地面
    final groundPaint = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3),
      groundPaint,
    );

    // 地面纹理
    final grassPaint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..strokeWidth = 2;

    for (int i = 0; i < 10; i++) {
      final x = i * size.width / 10 + sin(time + i) * 2;
      canvas.drawLine(
        Offset(x, size.height * 0.7),
        Offset(x + 5, size.height * 0.72),
        grassPaint,
      );
    }
  }

  void _drawBoss(Canvas canvas, Size size) {
    final bossX = size.width - 100;
    final bossY = size.height * 0.5;

    // Boss阴影
    final shadowPaint = Paint()..color = Colors.black.withAlpha(50);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bossX, size.height * 0.75),
        width: 80,
        height: 30,
      ),
      shadowPaint,
    );

    // Boss抖动效果
    final shakeX = sin(time * 10) * 2;
    final shakeY = cos(time * 8) * 1;

    // Boss图标
    final textPainter = TextPainter(
      text: TextSpan(
        text: boss.emoji,
        style: const TextStyle(fontSize: 60),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        bossX - textPainter.width / 2 + shakeX,
        bossY - textPainter.height / 2 + shakeY,
      ),
    );

    // Boss名称
    final namePainter = TextPainter(
      text: TextSpan(
        text: boss.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    namePainter.paint(
      canvas,
      Offset(bossX - namePainter.width / 2, bossY - 50),
    );

    // HP条
    _drawHpBar(
      canvas,
      Offset(bossX - 50, bossY + 40),
      100,
      boss.hpPercent,
      Colors.red,
    );
  }

  void _drawBattleFish(Canvas canvas, BattleFish bf, Size size) {
    if (!bf.isAlive) {
      // 阵亡显示
      final deadPainter = TextPainter(
        text: const TextSpan(
          text: '💀',
          style: TextStyle(fontSize: 20),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      deadPainter.paint(canvas, Offset(bf.posX - 10, bf.posY - 10));
      return;
    }

    // 移动动画
    final bounce = sin(time * 8 + bf.posY) * 3;

    // 攻击动画
    double scale = 1.0;
    if (bf.isAttacking) {
      scale = 1.3;
    }

    // 受伤闪烁
    Color? tint;
    if (bf.isHurt) {
      tint = Colors.red.withAlpha(100);
      Future.delayed(const Duration(milliseconds: 100), () {
        bf.isHurt = false;
      });
    }

    // 鱼图标
    final textPainter = TextPainter(
      text: TextSpan(
        text: bf.fish.emoji,
        style: TextStyle(fontSize: 28 * scale),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        bf.posX - textPainter.width / 2,
        bf.posY - textPainter.height / 2 + bounce,
      ),
    );

    // HP条
    _drawHpBar(
      canvas,
      Offset(bf.posX - 20, bf.posY - 30),
      40,
      bf.hpPercent,
      Colors.green,
    );
  }

  void _drawHpBar(Canvas canvas, Offset pos, double width, double percent, Color color) {
    // 背景
    final bgPaint = Paint()..color = Colors.grey.shade800;
    canvas.drawRect(Rect.fromLTWH(pos.dx, pos.dy, width, 6), bgPaint);

    // HP
    final hpPaint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(pos.dx, pos.dy, width * percent, 6), hpPaint);

    // 边框
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(Rect.fromLTWH(pos.dx, pos.dy, width, 6), borderPaint);
  }

  void _drawBattleEffects(Canvas canvas, Size size) {
    // 攻击特效
    for (final bf in battleFish) {
      if (bf.isAttacking && bf.isAlive) {
        // 冲击波效果
        final effectPaint = Paint()
          ..color = Colors.yellow.withAlpha(100)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

        final effectRadius = 10 + sin(time * 20) * 5;
        canvas.drawCircle(
          Offset(bf.posX + 20, bf.posY),
          effectRadius,
          effectPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(BattleArenaPainter oldDelegate) {
    return time != oldDelegate.time ||
        battleFish.any((bf) =>
            oldDelegate.battleFish.firstWhere(
              (obf) => obf.fish.id == bf.fish.id,
              orElse: () => BattleFish(fish: bf.fish),
            ).currentHp != bf.currentHp);
  }
}
