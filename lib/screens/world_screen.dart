import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fish.dart';
import '../models/boss.dart';
import '../providers/game_provider.dart' as game;
import '../providers/world_provider.dart';
import '../providers/battle_provider.dart';
import '../widgets/world_renderer.dart';
import '../widgets/battle_arena.dart';

/// 主游戏场景
class WorldScreen extends ConsumerStatefulWidget {
  const WorldScreen({super.key});

  @override
  ConsumerState<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends ConsumerState<WorldScreen>
    with TickerProviderStateMixin {
  Timer? _updateTimer;
  AnimationController? _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _updateTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      ref.read(worldProvider.notifier).update(0.033);
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(game.gameProvider);
    final worldState = ref.watch(worldProvider);
    final battleState = ref.watch(battleProvider);

    // 如果在战斗中，显示战斗场景
    if (battleState.phase == BattlePhase.fighting) {
      return _buildBattleScene(battleState);
    }

    return Scaffold(
      body: Stack(
        children: [
          // 世界场景
          Positioned.fill(
            child: WorldRenderer(
              worldState: worldState,
            ),
          ),

          // 顶部状态栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(gameState),
          ),

          // 底部操作栏
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(gameState),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(game.GameState gameState) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(150),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(icon: '💰', value: gameState.player.coins.toString(), label: '金币'),
            _StatItem(icon: '🐟', value: gameState.player.ownedFish.length.toString(), label: '鱼宠'),
            _StatItem(icon: '📈', value: '${gameState.player.incomePerSecond}/秒', label: '收入'),
            _StatItem(icon: '🍖', value: gameState.player.fishFood.toString(), label: '鱼食'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(game.GameState gameState) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(180),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ActionButton(
              icon: '🎣',
              label: '钓鱼',
              onTap: () => _showFishingPanel(gameState),
            ),
            _ActionButton(
              icon: '⚔️',
              label: '战斗',
              onTap: () => _showBattlePanel(gameState),
            ),
            _ActionButton(
              icon: '🏗️',
              label: '建筑',
              onTap: () => _showBuildingPanel(),
            ),
            _ActionButton(
              icon: '📖',
              label: '图鉴',
              onTap: () => _showCollectionPanel(gameState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattleScene(BattleStateData battleState) {
    return Scaffold(
      body: Stack(
        children: [
          // 战斗场景
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animController!,
              builder: (context, child) {
                return BattleArena(
                  battleFish: battleState.battleFish,
                  boss: battleState.currentBoss!,
                  time: _animController!.value,
                );
              },
            ),
          ),

          // 战斗状态信息
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: _buildBattleInfo(battleState),
          ),

          // 返回按钮
          Positioned(
            top: 10,
            left: 10,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  ref.read(battleProvider.notifier).reset();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleInfo(BattleStateData battleState) {
    final boss = battleState.currentBoss!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(180),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Boss信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${boss.emoji} ${boss.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'HP: ${boss.currentHp}/${boss.maxHp}',
                style: TextStyle(color: Colors.red[300]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: boss.hpPercent,
              backgroundColor: Colors.grey,
              valueColor: const AlwaysStoppedAnimation(Colors.red),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 8),

          // 我方鱼宠状态
          Row(
            children: battleState.battleFish.map((bf) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    Text(bf.fish.emoji, style: const TextStyle(fontSize: 24)),
                    Text(
                      '${bf.currentHp}/${bf.fish.maxHp}',
                      style: TextStyle(
                        fontSize: 10,
                        color: bf.isAlive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showFishingPanel(game.GameState gameState) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              gameState.isFishing ? '🎣 钓鱼中...' : '⏸️ 已暂停',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '鱼竿等级: Lv.${gameState.player.equipment.rodLevel}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '钓鱼速度: ${(1 / gameState.player.equipment.fishingSpeedBonus).toStringAsFixed(1)}秒/次',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(game.gameProvider.notifier).toggleFishing();
                Navigator.pop(context);
              },
              child: Text(gameState.isFishing ? '暂停钓鱼' : '开始钓鱼'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBattlePanel(game.GameState gameState) {
    final bosses = Boss.defaultBosses;
    final availableFish = gameState.player.ownedFish;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⚔️ Boss 战斗',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Boss列表
              const Text('选择Boss:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: bosses.length,
                  itemBuilder: (context, index) {
                    final boss = bosses[index];
                    final isUnlocked = index == 0 || bosses[index - 1].isDefeated;
                    return _BossCard(
                      boss: boss,
                      isUnlocked: isUnlocked,
                      onTap: isUnlocked
                          ? () => _selectFishForBattle(boss, availableFish)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectFishForBattle(Boss boss, List<Fish> availableFish) {
    Navigator.pop(context);

    if (availableFish.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有可用的鱼宠！')),
      );
      return;
    }

    // 选择战斗力最高的鱼（最多5条）
    final sortedFish = List<Fish>.from(availableFish)
      ..sort((a, b) => b.power.compareTo(a.power));
    final selectedFish = sortedFish.take(5).toList();

    // 更新战斗provider
    ref.read(battleProvider.notifier).availableFish = availableFish;
    ref.read(battleProvider.notifier).startBattle(boss, selectedFish);
  }

  void _showBuildingPanel() {
    final worldState = ref.read(worldProvider);
    final gameState = ref.read(game.gameProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏗️ 建筑',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: worldState.buildings.length,
              itemBuilder: (context, index) {
                final building = worldState.buildings[index];
                return _BuildingCard(
                  building: building,
                  coins: gameState.player.coins,
                  onUnlock: () {
                    if (ref.read(worldProvider.notifier).unlockBuilding(building.id)) {
                      Navigator.pop(context);
                      _showBuildingPanel();
                    }
                  },
                  onUpgrade: () {
                    if (ref.read(worldProvider.notifier).upgradeBuilding(building.id)) {
                      Navigator.pop(context);
                      _showBuildingPanel();
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCollectionPanel(game.GameState gameState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📖 鱼宠图鉴 (${gameState.player.ownedFish.length})',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: gameState.player.ownedFish.length,
                  itemBuilder: (context, index) {
                    final fish = gameState.player.ownedFish[index];
                    return _FishCard(fish: fish);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 10),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _BossCard extends StatelessWidget {
  final Boss boss;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _BossCard({
    required this.boss,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.grey[800] : Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: boss.isDefeated ? Colors.green : Colors.grey,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isUnlocked ? boss.emoji : '❓',
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 8),
            Text(
              isUnlocked ? boss.name : '???',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '战力: ${boss.requiredPower}',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            if (boss.isDefeated)
              const Text('✅ 已击败', style: TextStyle(color: Colors.green, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _BuildingCard extends StatelessWidget {
  final dynamic building;
  final int coins;
  final VoidCallback onUnlock;
  final VoidCallback onUpgrade;

  const _BuildingCard({
    required this.building,
    required this.coins,
    required this.onUnlock,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(building.emoji, style: const TextStyle(fontSize: 32)),
        title: Text(building.name),
        subtitle: Text(building.isUnlocked ? '等级: ${building.level}' : '未解锁'),
        trailing: building.isUnlocked
            ? ElevatedButton(
                onPressed: coins >= building.upgradeCost ? onUpgrade : null,
                child: Text('升级 💰${building.upgradeCost}'),
              )
            : ElevatedButton(
                onPressed: coins >= building.unlockCost ? onUnlock : null,
                child: Text('解锁 💰${building.unlockCost}'),
              ),
      ),
    );
  }
}

class _FishCard extends StatelessWidget {
  final Fish fish;

  const _FishCard({required this.fish});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(fish.emoji, style: const TextStyle(fontSize: 32)),
        title: Text(fish.name),
        subtitle: Text(
          'Lv.${fish.level} | ⚔️${fish.attack} 🛡️${fish.defense} ❤️${fish.hp}',
        ),
        trailing: Text(
          '战力: ${fish.power}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
