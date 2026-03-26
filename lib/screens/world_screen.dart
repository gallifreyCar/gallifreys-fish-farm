import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fish.dart';
import '../models/boss.dart';
import '../models/battle_narrative.dart';
import '../providers/game_provider.dart' as game;
import '../providers/world_provider.dart';
import '../providers/battle_provider.dart';
import '../services/tutorial_service.dart';
import '../services/goal_service.dart';
import '../widgets/world_renderer.dart';
import '../widgets/battle_arena.dart';
import '../widgets/goal_panel.dart';
import 'achievement_screen.dart';

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

  // 战斗文案状态
  String? _battleNarrative;
  String? _skillMessage;
  int _lastCombo = 0;
  String? _lastBossIntro;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _updateTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      ref.read(worldProvider.notifier).update(0.033);
      _updateGoalProgress();
    });

    // 显示欢迎引导弹窗
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialogIfNeeded();
    });
  }

  /// 显示欢迎引导弹窗
  void _showWelcomeDialogIfNeeded() {
    final tutorialState = ref.read(tutorialProvider);
    if (tutorialState.currentStep == TutorialStep.welcome && !tutorialState.hasSeenWelcome) {
      ref.read(tutorialProvider.notifier).markWelcomeSeen();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _WelcomeDialog(
          onStart: () {
            Navigator.pop(context);
            ref.read(tutorialProvider.notifier).completeStep();
          },
          onSkip: () {
            Navigator.pop(context);
            ref.read(tutorialProvider.notifier).skipTutorial();
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _animController?.dispose();
    super.dispose();
  }

  /// 更新目标进度
  void _updateGoalProgress() {
    final gameState = ref.read(game.gameProvider);

    // 更新钓鱼数量目标
    ref.read(goalProvider.notifier).updateProgress('catch_1', gameState.player.totalFishCaught);
    ref.read(goalProvider.notifier).updateProgress('catch_10', gameState.player.totalFishCaught);
    ref.read(goalProvider.notifier).updateProgress('catch_50', gameState.player.totalFishCaught);
    ref.read(goalProvider.notifier).updateProgress('catch_100', gameState.player.totalFishCaught);

    // 更新收集目标
    final fishCount = gameState.player.ownedFish.length;
    ref.read(goalProvider.notifier).updateProgress('fish_10', fishCount);
    ref.read(goalProvider.notifier).updateProgress('fish_50', fishCount);

    final rareCount = gameState.player.ownedFish.where((f) => f.rarity.index >= 1).length;
    ref.read(goalProvider.notifier).updateProgress('rare_5', rareCount);

    final legendaryCount = gameState.player.ownedFish.where((f) => f.rarity == Rarity.legendary).length;
    ref.read(goalProvider.notifier).updateProgress('legendary_1', legendaryCount);

    // 更新金币目标
    ref.read(goalProvider.notifier).updateProgress('coins_1000', gameState.player.coins);
    ref.read(goalProvider.notifier).updateProgress('coins_10000', gameState.player.coins);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(game.gameProvider);
    final worldState = ref.watch(worldProvider);
    final battleState = ref.watch(battleProvider);
    final tutorialState = ref.watch(tutorialProvider);

    // 如果在战斗中，显示战斗场景
    if (battleState.phase == BattlePhase.fighting) {
      return _buildBattleScene(battleState);
    }

    // 如果在战斗结束，显示结果
    if (battleState.phase == BattlePhase.victory ||
        battleState.phase == BattlePhase.defeat) {
      return _buildBattleResult(battleState);
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

          // 目标提示按钮
          Positioned(
            top: 60,
            right: 10,
            child: _buildGoalButton(),
          ),

          // 新手引导覆盖层
          if (tutorialState.isTutorialActive &&
              tutorialState.currentStep != TutorialStep.welcome)
            _buildTutorialHint(),
        ],
      ),
    );
  }

  Widget _buildGoalButton() {
    final claimableCount = ref.watch(claimableGoalsCountProvider);

    return GestureDetector(
      onTap: () => _showGoalPanel(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(180),
          borderRadius: BorderRadius.circular(20),
          border: claimableCount > 0
              ? Border.all(color: Colors.orange, width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 16)),
            if (claimableCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$claimableCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showGoalPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: const GoalPanel(),
      ),
    );
  }

  Widget _buildTutorialHint() {
    final hint = ref.watch(currentTutorialHintProvider);
    final tutorialState = ref.watch(tutorialProvider);

    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[700],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(hint.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hint.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    hint.description,
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // 步骤指示器
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${TutorialStep.values.indexOf(tutorialState.currentStep) + 1}/5',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
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
    final claimableAchievements = gameState.claimableAchievements;

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
              featureId: 'fishing',
              onTap: () {
                _showFishingPanel(gameState);
                _checkTutorialStep(TutorialStep.firstFishing);
              },
            ),
            _ActionButton(
              icon: '⚔️',
              label: '战斗',
              featureId: 'battle',
              onTap: () {
                _showBattlePanel(gameState);
                _checkTutorialStep(TutorialStep.firstBattle);
              },
            ),
            _ActionButton(
              icon: '🏗️',
              label: '建筑',
              featureId: 'buildings',
              onTap: () {
                _showBuildingPanel();
                _checkTutorialStep(TutorialStep.upgradeBuilding);
              },
            ),
            _ActionButton(
              icon: '📖',
              label: '图鉴',
              featureId: 'collection',
              onTap: () {
                _showCollectionPanel(gameState);
                _checkTutorialStep(TutorialStep.viewCollection);
              },
            ),
            _ActionButton(
              icon: '🏆',
              label: '成就',
              featureId: 'achievements',
              badge: claimableAchievements > 0 ? claimableAchievements : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AchievementScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _checkTutorialStep(TutorialStep step) {
    final tutorialState = ref.read(tutorialProvider);
    if (tutorialState.currentStep == step) {
      ref.read(tutorialProvider.notifier).completeStep();
    }
  }

  Widget _buildBattleScene(BattleStateData battleState) {
    final boss = battleState.currentBoss!;

    // 战斗开始时显示 Boss 开场白
    if (_lastBossIntro != boss.id) {
      _lastBossIntro = boss.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _battleNarrative = BattleNarrator.getIntro(boss);
        });
      });
    }

    // 检测连击变化
    if (battleState.combo > 0 && battleState.combo != _lastCombo) {
      _lastCombo = battleState.combo;
      if (battleState.combo % 10 == 0) {
        final comboText = BattleNarrator.describeCombo(battleState.combo);
        if (comboText.isNotEmpty) {
          setState(() {
            _skillMessage = comboText;
          });
        }
      }
    }

    // 技能消息
    if (battleState.skillMessage != null && battleState.skillMessage != _skillMessage) {
      setState(() {
        _skillMessage = battleState.skillMessage;
      });
    }

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
                  boss: boss,
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

          // 战斗文案提示
          if (_battleNarrative != null)
            Positioned(
              bottom: 120,
              left: 16,
              right: 16,
              child: _buildNarrativeBox(_battleNarrative!),
            ),

          // 技能消息
          if (_skillMessage != null)
            Positioned(
              top: 200,
              left: 16,
              right: 16,
              child: _buildSkillMessage(_skillMessage!),
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
                  setState(() {
                    _battleNarrative = null;
                    _skillMessage = null;
                    _lastCombo = 0;
                    _lastBossIntro = null;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleResult(BattleStateData battleState) {
    final boss = battleState.currentBoss!;
    final isVictory = battleState.phase == BattlePhase.victory;

    final narrative = isVictory
        ? BattleNarrator.describeVictory(boss, 1000, _lastCombo)
        : BattleNarrator.describeDefeat(boss);

    // 更新战斗相关目标
    if (isVictory) {
      ref.read(goalProvider.notifier).addProgress('defeat_boss_1', 1);
      ref.read(goalProvider.notifier).addProgress('defeat_boss_5', 1);
      ref.read(goalProvider.notifier).addProgress('defeat_boss_10', 1);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isVictory
                ? [Colors.blue[900]!, Colors.blue[700]!]
                : [Colors.red[900]!, Colors.red[700]!],
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(180),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isVictory ? '🎉 胜利！' : '💔 失败...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  narrative,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (isVictory) ...[
                  Text(
                    '奖励：',
                    style: TextStyle(color: Colors.amber[300], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...boss.rewards.map((r) => Text(
                    '• ${r.description}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  )),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(battleProvider.notifier).reset();
                    setState(() {
                      _battleNarrative = null;
                      _skillMessage = null;
                      _lastCombo = 0;
                      _lastBossIntro = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVictory ? Colors.green : Colors.orange,
                  ),
                  child: Text(isVictory ? '领取奖励' : '再试一次'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNarrativeBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(200),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withAlpha(100)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSkillMessage(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
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

          // 连击显示
          if (battleState.combo >= 10)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '⚡ 连击 x${battleState.combo}',
                style: TextStyle(
                  color: Colors.orange[300],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⚔️ Boss 战斗',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '总战力: ${availableFish.fold<int>(0, (sum, f) => sum + f.power)}',
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 16),

              // Boss列表 - 按难度分组
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildBossTier('初级 Boss', bosses.where((b) => b.tier == BossTier.easy).toList(), availableFish),
                    _buildBossTier('中级 Boss', bosses.where((b) => b.tier == BossTier.medium).toList(), availableFish),
                    _buildBossTier('高级 Boss', bosses.where((b) => b.tier == BossTier.hard).toList(), availableFish),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBossTier(String title, List<Boss> tierBosses, List<Fish> availableFish) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tierBosses.length,
            itemBuilder: (context, index) {
              final boss = tierBosses[index];
              final globalIndex = Boss.defaultBosses.indexOf(boss);
              final isUnlocked = globalIndex == 0 || Boss.defaultBosses[globalIndex - 1].isDefeated;
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

    // 重置战斗文案状态
    setState(() {
      _battleNarrative = null;
      _skillMessage = null;
      _lastCombo = 0;
    });
  }

  void _showBuildingPanel() {
    final worldState = ref.read(worldProvider);
    final gameState = ref.read(game.gameProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏗️ 建筑',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
      backgroundColor: Colors.grey[900],
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
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
  final String featureId;
  final VoidCallback onTap;
  final int? badge;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.featureId,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final isUnlocked = ref.watch(featureUnlockProvider(featureId));

        return GestureDetector(
          onTap: isUnlocked ? onTap : null,
          child: Opacity(
            opacity: isUnlocked ? 1.0 : 0.4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: isUnlocked
                            ? Text(icon, style: const TextStyle(fontSize: 24))
                            : const Icon(Icons.lock, color: Colors.grey, size: 20),
                      ),
                    ),
                    if (badge != null && badge! > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$badge',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
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
    Color tierColor;
    switch (boss.tier) {
      case BossTier.easy:
        tierColor = Colors.green;
        break;
      case BossTier.medium:
        tierColor = Colors.orange;
        break;
      case BossTier.hard:
        tierColor = Colors.red;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.grey[800] : Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: boss.isDefeated ? Colors.green : (isUnlocked ? tierColor : Colors.grey),
            width: 2,
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
      color: Colors.grey[800],
      child: ListTile(
        leading: Text(building.emoji, style: const TextStyle(fontSize: 32)),
        title: Text(building.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          building.isUnlocked ? '等级: ${building.level}' : '未解锁',
          style: TextStyle(color: Colors.grey[400]),
        ),
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

  Color _getRarityColor() {
    switch (fish.rarity) {
      case Rarity.common:
        return Colors.grey;
      case Rarity.rare:
        return Colors.blue;
      case Rarity.epic:
        return Colors.purple;
      case Rarity.legendary:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: _getRarityColor(), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(fish.emoji, style: const TextStyle(fontSize: 28)),
        ),
        title: Text(fish.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          'Lv.${fish.level} | ⚔️${fish.attack} 🛡️${fish.defense} ❤️${fish.hp}',
          style: TextStyle(color: Colors.grey[400]),
        ),
        trailing: Text(
          '战力: ${fish.power}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getRarityColor(),
          ),
        ),
      ),
    );
  }
}

/// 欢迎引导弹窗
class _WelcomeDialog extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onSkip;

  const _WelcomeDialog({
    required this.onStart,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[900]!, Colors.blue[700]!],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withAlpha(100),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题动画
            const Text(
              '🎣',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              '欢迎来到钓鱼农场',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '加利弗雷鱼农场',
              style: TextStyle(
                color: Colors.blue[200],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _FeatureItem(icon: '🐟', text: '钓取各种稀有鱼宠'),
                  _FeatureItem(icon: '⚔️', text: '挑战强大的Boss'),
                  _FeatureItem(icon: '🏗️', text: '建造升级建筑'),
                  _FeatureItem(icon: '🏆', text: '解锁成就奖励'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSkip,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('跳过引导'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('开始冒险!', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
