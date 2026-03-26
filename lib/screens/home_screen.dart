import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../models/fish.dart';
import '../models/player.dart';
import '../utils/constants.dart';
import 'collection_screen.dart';
import 'work_screen.dart';
import 'shop_screen.dart';
import 'dart:math' show sin;

/// 主页面 - 钓鱼场景
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 延迟显示离线收益
    Future.delayed(const Duration(milliseconds: 500), () {
      ref.read(gameProvider.notifier).calculateOfflineIncome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final player = gameState.player;

    // 监听通知
    ref.listen<GameState>(gameProvider, (prev, next) {
      if (next.notification != null && next.notification != prev?.notification) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.notification!),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Future.delayed(const Duration(milliseconds: 100), () {
          ref.read(gameProvider.notifier).clearNotification();
        });
      }
    });

    final screens = [
      _FishingView(player: player),
      CollectionScreen(player: player),
      WorkScreen(player: player),
      ShopScreen(player: player),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.pool_outlined),
            selectedIcon: Icon(Icons.pool),
            label: '钓鱼',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_outlined),
            selectedIcon: Icon(Icons.collections),
            label: '图鉴',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: '工作',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: '商店',
          ),
        ],
      ),
    );
  }
}

/// 钓鱼视图
class _FishingView extends ConsumerWidget {
  final Player player;

  const _FishingView({required this.player});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return SafeArea(
      child: Column(
        children: [
          // 顶部状态栏
          _TopBar(player: player),

          // 钓鱼区域
          Expanded(
            child: _FishingPond(
              isFishing: gameState.isFishing,
              lastCaughtFish: gameState.lastCaughtFish,
              onToggleFishing: () {
                ref.read(gameProvider.notifier).toggleFishing();
              },
              onClearLastCaughtFish: () {
                ref.read(gameProvider.notifier).clearLastCaughtFish();
              },
            ),
          ),

          // 底部信息
          _BottomInfo(player: player),
        ],
      ),
    );
  }
}

/// 顶部状态栏
class _TopBar extends StatelessWidget {
  final Player player;

  const _TopBar({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: '💰',
            label: '金币',
            value: player.coins.toString(),
          ),
          _StatItem(
            icon: '🐟',
            label: '鱼数',
            value: '${player.ownedFish.length}/${player.equipment.pondCapacity}',
          ),
          _StatItem(
            icon: '📈',
            label: '收入/秒',
            value: player.incomePerSecond.toString(),
          ),
          _StatItem(
            icon: '🍖',
            label: '鱼食',
            value: player.fishFood.toString(),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// 钓鱼池塘
class _FishingPond extends StatefulWidget {
  final bool isFishing;
  final Fish? lastCaughtFish;
  final VoidCallback onToggleFishing;
  final VoidCallback onClearLastCaughtFish;

  const _FishingPond({
    required this.isFishing,
    this.lastCaughtFish,
    required this.onToggleFishing,
    required this.onClearLastCaughtFish,
  });

  @override
  State<_FishingPond> createState() => _FishingPondState();
}

class _FishingPondState extends State<_FishingPond>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showCaughtFish = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void didUpdateWidget(_FishingPond oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastCaughtFish != null && widget.lastCaughtFish != oldWidget.lastCaughtFish) {
      setState(() => _showCaughtFish = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showCaughtFish = false);
          widget.onClearLastCaughtFish();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onToggleFishing,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[300]!,
              Colors.blue[600]!,
              Colors.blue[900]!,
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 水波纹动画
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _WavePainter(_controller.value),
                  size: Size.infinite,
                );
              },
            ),

            // 钓鱼状态提示
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.isFishing ? '🎣 钓鱼中...' : '⏸️ 已暂停',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(color: Colors.black54, blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '点击${widget.isFishing ? '暂停' : '继续'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),

            // 钓到的鱼展示
            if (_showCaughtFish && widget.lastCaughtFish != null)
              Positioned(
                top: 100,
                child: _CaughtFishDisplay(fish: widget.lastCaughtFish!),
              ),

            // 游泳的鱼
            ...List.generate(5, (index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final offset = (_controller.value + index * 0.2) % 1.0;
                  return Positioned(
                    left: MediaQuery.of(context).size.width * offset,
                    top: 150.0 + index * 80,
                    child: Opacity(
                      opacity: 0.3,
                      child: Text(
                        ['🐟', '🐠', '🐡', '🐬', '🐋'][index],
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// 钓到的鱼展示
class _CaughtFishDisplay extends StatelessWidget {
  final Fish fish;

  const _CaughtFishDisplay({required this.fish});

  @override
  Widget build(BuildContext context) {
    final rarityColor = Color(GameConstants.rarityColors[fish.rarity]!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            fish.emoji,
            style: const TextStyle(fontSize: 60),
          ),
          const SizedBox(height: 8),
          Text(
            fish.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: rarityColor,
            ),
          ),
          Text(
            GameConstants.rarityNames[fish.rarity]!,
            style: TextStyle(
              fontSize: 14,
              color: rarityColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// 底部信息
class _BottomInfo extends StatelessWidget {
  final Player player;

  const _BottomInfo({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoItem(
                icon: '🎣',
                label: '鱼竿等级',
                value: 'Lv.${player.equipment.rodLevel}',
              ),
              _InfoItem(
                icon: '🪱',
                label: '鱼饵等级',
                value: 'Lv.${player.equipment.baitLevel}',
              ),
              _InfoItem(
                icon: '🏠',
                label: '鱼池等级',
                value: 'Lv.${player.equipment.pondLevel}',
              ),
              _InfoItem(
                icon: '📊',
                label: '总钓获',
                value: player.totalFishCaught.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

/// 水波纹绘制器
class _WavePainter extends CustomPainter {
  final double animationValue;

  _WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final y = size.height * (0.3 + i * 0.2);
      final amplitude = 20.0;
      final frequency = 2.0;
      final phase = animationValue * 2 * 3.14159 + i * 1.0;

      path.moveTo(0, y);
      for (double x = 0; x <= size.width; x++) {
        final dy = amplitude * sin((x / size.width * frequency * 3.14159) + phase);
        path.lineTo(x, y + dy);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => true;
}
