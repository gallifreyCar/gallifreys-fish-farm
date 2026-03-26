# 钓鱼农场性能优化报告

> 分析日期: 2026-03-27
> 分析范围: 关键渲染路径和状态管理

---

## 一、性能问题诊断

### 1.1 状态管理问题

**问题位置:** `lib/providers/game_provider.dart`

```dart
// 问题代码：每秒创建新 Player 对象
void _collectIncome() {
  state = state.copyWith(
    player: Player(  // ❌ 每次都创建新对象
      coins: state.player.coins + income,
      fishFood: state.player.fishFood,
      ownedFish: state.player.ownedFish,  // 复制整个列表
      ...
    ),
  );
}
```

**影响:**
- 每秒触发状态更新 → 所有监听者重建
- Player 对象频繁创建/销毁 → GC 压力
- ownedFish 列表复制 → 内存压力

### 1.2 渲染问题

**问题位置:** `lib/widgets/world_renderer.dart`

```dart
void _drawBackground(Canvas canvas, Size size) {
  final skyPaint = Paint()..color = const Color(0xFF87CEEB);  // ❌ 每帧创建
  final grassPaint = Paint()..color = const Color(0xFF4CAF50);  // ❌ 每帧创建
  ...
}

void _drawBuilding(Canvas canvas, Building building) {
  final textPainter = TextPainter(...)..layout();  // ❌ 每帧创建和布局
}
```

**影响:**
- Paint 对象每帧创建 → 对象创建开销
- TextPainter 每次 layout → 文字测量开销
- 波浪效果 sin 计算 → CPU 计算

### 1.3 战斗渲染问题

**问题位置:** `lib/widgets/battle_arena.dart`

```dart
void _drawBoss(Canvas canvas, Size size) {
  final textPainter = TextPainter(
    text: TextSpan(text: boss.emoji, style: const TextStyle(fontSize: 60)),
    ...
  )..layout();  // ❌ 每帧创建和布局
}
```

**影响:**
- 50ms 一帧的战斗循环中频繁创建对象
- 战斗时内存波动大

---

## 二、优化方案

### 2.1 状态管理优化

**方案 A: 细粒度状态分离**

```dart
// 将频繁变化的状态单独管理
final coinsProvider = StateProvider<int>((ref) => 0);
final incomeProvider = StateProvider<int>((ref) => 0);

// 稳定的玩家数据
final playerDataProvider = StateNotifierProvider<PlayerDataNotifier, PlayerData>((ref) {
  return PlayerDataNotifier();
});
```

**方案 B: 批量更新 + 防抖**

```dart
// 收入累积，批量更新
class GameNotifier extends StateNotifier<GameState> {
  int _pendingIncome = 0;
  Timer? _updateTimer;

  void _collectIncome() {
    _pendingIncome += state.player.incomePerSecond;

    // 每5秒批量更新一次UI
    _updateTimer?.cancel();
    _updateTimer = Timer(const Duration(seconds: 5), _flushPendingIncome);
  }

  void _flushPendingIncome() {
    if (_pendingIncome > 0) {
      state = state.copyWith(
        player: state.player.copyWith(coins: state.player.coins + _pendingIncome),
      );
      _pendingIncome = 0;
    }
  }
}
```

### 2.2 渲染优化

**方案 A: 缓存 Paint 对象**

```dart
class WorldPainter extends CustomPainter {
  // 静态 Paint 缓存
  static final Paint _skyPaint = Paint()..color = const Color(0xFF87CEEB);
  static final Paint _grassPaint = Paint()..color = const Color(0xFF4CAF50);
  static final Paint _waterPaint = Paint()..color = const Color(0xFF2196F3).withAlpha(180);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 150), _skyPaint);
    ...
  }
}
```

**方案 B: 预布局 TextPainter**

```dart
class WorldPainter extends CustomPainter {
  // 缓存常用的 TextPainter
  static TextPainter? _zoneLabelSea;
  static TextPainter? _zoneLabelVillage;

  static TextPainter _getZoneLabel(String text) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void _drawZones(Canvas canvas, Size size) {
    _zoneLabelSea ??= _getZoneLabel('🌊 海边');
    _zoneLabelSea!.paint(canvas, const Offset(10, 155));
    ...
  }
}
```

**方案 C: 波浪效果优化**

```dart
// 预计算波浪路径，减少 sin 调用
class WavePathCache {
  static final List<Path> _cachedPaths = [];
  static double _lastTime = 0;

  static List<Path> getPaths(double time, double width) {
    // 每0.1秒更新一次缓存
    if ((time - _lastTime).abs() < 0.1) return _cachedPaths;

    _cachedPaths.clear();
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final waveY = 200.0 + i * 80;
      path.moveTo(0, waveY);
      for (double x = 0; x < width; x += 10) {  // 步长从5改为10
        path.lineTo(x, waveY + sin(x * 0.05 + time * 3 + i) * 3);
      }
      _cachedPaths.add(path);
    }
    _lastTime = time;
    return _cachedPaths;
  }
}
```

### 2.3 列表渲染优化

**方案: ListView.builder + const 构造器**

```dart
// 使用 const 构造器
class _FishCard extends StatelessWidget {
  final Fish fish;

  const _FishCard({required this.fish});  // const 构造器

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(fish.emoji, style: const TextStyle(fontSize: 32)),
        ...
      ),
    );
  }
}

// 使用 builder
ListView.builder(
  itemCount: fish.length,
  itemBuilder: (context, index) {
    return _FishCard(fish: fish[index]);  // 自动复用
  },
);
```

---

## 三、优化优先级

| 优先级 | 优化项 | 预期收益 | 实现难度 |
|--------|--------|----------|----------|
| P0 | Paint 对象缓存 | 高 | 低 |
| P0 | TextPainter 缓存 | 高 | 低 |
| P1 | 收入批量更新 | 中 | 中 |
| P1 | 波浪路径缓存 | 中 | 低 |
| P2 | 细粒度状态分离 | 高 | 高 |
| P2 | 列表虚拟化 | 中 | 低 |

---

## 四、已实现的优化

项目中已经有一些优化措施：

### 4.1 battle_arena.dart
```dart
// ✅ 已经缓存 Paint 对象
static final Paint _skyPaint = Paint();
static final Paint _starPaint = Paint()..color = const Color(0xFFFFFFFF);
static final Paint _groundPaint = Paint()..color = const Color(0xFF2E7D32);
```

### 4.2 game_provider.dart
```dart
// ✅ 已经有细粒度 Provider
final coinsProvider = Provider<int>((ref) {
  return ref.watch(gameProvider.select((state) => state.player.coins));
});
```

### 4.3 world_renderer.dart
```dart
// ✅ shouldRepaint 有优化
@override
bool shouldRepaint(WorldPainter oldDelegate) {
  if ((time - oldDelegate.time).abs() > 0.001) return true;
  ...
}
```

---

## 五、待实施优化

### 5.1 world_renderer.dart Paint 缓存

```dart
// 需要添加静态 Paint 缓存
class WorldPainter extends CustomPainter {
  static final Paint _skyPaint = Paint()..color = const Color(0xFF87CEEB);
  static final Paint _grassPaint = Paint()..color = const Color(0xFF4CAF50);
  static final Paint _waterPaint = Paint()..color = const Color(0xFF2196F3).withAlpha(180);
  static final Paint _wavePaint = Paint()
    ..color = Colors.white.withAlpha(30)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  static final Paint _shadowPaint = Paint()..color = Colors.grey.withAlpha(100);
  static final Paint _borderPaint = Paint()
    ..color = Colors.brown
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  ...
}
```

### 5.2 收入累积优化

```dart
class GameNotifier extends StateNotifier<GameState> {
  int _accumulatedIncome = 0;
  static const int _incomeUpdateThreshold = 100; // 累积100金币再更新

  void _collectIncome() {
    final income = state.player.incomePerSecond;
    if (income <= 0) return;

    _accumulatedIncome += income;

    // 只有累积到阈值或玩家主动操作时才更新状态
    if (_accumulatedIncome >= _incomeUpdateThreshold) {
      state = state.copyWith(
        player: state.player.copyWith(
          coins: state.player.coins + _accumulatedIncome,
        ),
      );
      _accumulatedIncome = 0;
    }
  }
}
```

---

## 六、性能测试建议

1. **帧率监控**: 使用 Flutter DevTools 的 Performance 面板
2. **内存分析**: 观察是否有内存泄漏或频繁 GC
3. **关键指标**:
   - 战斗场景帧率 >= 30fps
   - 主界面帧率 >= 60fps
   - 内存波动 < 10MB/min

---

**文档版本:** v1.0
**作者:** Claude (P10 视角)
