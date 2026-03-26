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

  // 预缓存 Paint 对象，避免每帧创建
  static final Paint _skyPaint = Paint();
  static final Paint _starPaint = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _groundPaint = Paint()..color = const Color(0xFF2E7D32);
  static final Paint _grassPaint = Paint()
    ..color = const Color(0xFF1B5E20)
    ..strokeWidth = 2;
  static final Paint _shadowPaint = Paint()..color = const Color(0x32000000);
  static final Paint _bgHpPaint = Paint()..color = const Color(0xFF424242);
  static final Paint _borderPaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

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
    // 天空渐变 - 使用缓存
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF1a237e),
        Color(0xFF3949ab),
      ],
    );
    _skyPaint.shader = skyGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.7));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.7), _skyPaint);

    // 星星效果 - 使用缓存的 Paint
    for (int i = 0; i < 20; i++) {
      final x = (i * 47 + time * 0.5) % size.width;
      final y = (i * 31) % (size.height * 0.5);
      final twinkle = sin(time * 3 + i) * 0.5 + 0.5;
      final alpha = (150 * twinkle).round().clamp(0, 255);
      _starPaint.color = Color(0xFFFFFFFF).withAlpha(alpha);
      canvas.drawCircle(Offset(x, y), 1 + twinkle, _starPaint);
    }
  }

  void _drawGround(Canvas canvas, Size size) {
    // 地面
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3),
      _groundPaint,
    );

    // 地面纹理
    for (int i = 0; i < 10; i++) {
      final x = i * size.width / 10 + sin(time + i) * 2;
      canvas.drawLine(
        Offset(x, size.height * 0.7),
        Offset(x + 5, size.height * 0.72),
        _grassPaint,
      );
    }
  }

  void _drawBoss(Canvas canvas, Size size) {
    final bossX = size.width - 100;
    final bossY = size.height * 0.5;

    // Boss阴影
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bossX, size.height * 0.75),
        width: 80,
        height: 30,
      ),
      _shadowPaint,
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
          color: Color(0xFFFFFFFF),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Color(0xFF000000), blurRadius: 2)],
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
      const Color(0xFFF44336),
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
      const Color(0xFF4CAF50),
    );
  }

  void _drawHpBar(Canvas canvas, Offset pos, double width, double percent, Color color) {
    // 背景
    canvas.drawRect(Rect.fromLTWH(pos.dx, pos.dy, width, 6), _bgHpPaint);

    // HP - 创建临时 Paint 避免颜色污染
    final hpPaint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(pos.dx, pos.dy, width * percent, 6), hpPaint);

    // 边框
    canvas.drawRect(Rect.fromLTWH(pos.dx, pos.dy, width, 6), _borderPaint);
  }

  // 缓存特效 Paint
  static final Paint _effectPaint = Paint()
    ..color = const Color(0x64FFEB3B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  void _drawBattleEffects(Canvas canvas, Size size) {
    // 攻击特效
    for (final bf in battleFish) {
      if (bf.isAttacking && bf.isAlive) {
        // 冲击波效果
        final effectRadius = 10 + sin(time * 20) * 5;
        canvas.drawCircle(
          Offset(bf.posX + 20, bf.posY),
          effectRadius,
          _effectPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(BattleArenaPainter oldDelegate) {
    // 时间变化必然重绘（动画需要）
    if ((time - oldDelegate.time).abs() > 0.001) return true;

    // Boss血量变化
    if (boss.currentHp != oldDelegate.boss.currentHp) return true;

    // 战斗鱼数量变化
    if (battleFish.length != oldDelegate.battleFish.length) return true;

    // 战斗鱼状态变化（血量、攻击状态）
    for (int i = 0; i < battleFish.length && i < oldDelegate.battleFish.length; i++) {
      if (battleFish[i].currentHp != oldDelegate.battleFish[i].currentHp ||
          battleFish[i].isAttacking != oldDelegate.battleFish[i].isAttacking ||
          battleFish[i].posX != oldDelegate.battleFish[i].posX) {
        return true;
      }
    }

    return false;
  }
}
