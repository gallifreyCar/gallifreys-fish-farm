/// 新手引导系统
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 引导步骤
enum TutorialStep {
  welcome,        // 欢迎界面
  firstFishing,   // 第一次钓鱼
  viewCollection, // 查看图鉴
  firstBattle,    // 第一次战斗
  upgradeBuilding,// 升级建筑
  completed,      // 引导完成
}

/// 引导提示
class TutorialHint {
  final String title;
  final String description;
  final String targetWidget;
  final String actionText;
  final String emoji;

  const TutorialHint({
    required this.title,
    required this.description,
    required this.targetWidget,
    required this.actionText,
    this.emoji = '👆',
  });
}

/// 功能解锁配置
class FeatureUnlock {
  final String featureId;
  final String featureName;
  final TutorialStep requiredStep;

  const FeatureUnlock({
    required this.featureId,
    required this.featureName,
    required this.requiredStep,
  });

  static const List<FeatureUnlock> allFeatures = [
    FeatureUnlock(featureId: 'fishing', featureName: '钓鱼', requiredStep: TutorialStep.welcome),
    FeatureUnlock(featureId: 'collection', featureName: '图鉴', requiredStep: TutorialStep.firstFishing),
    FeatureUnlock(featureId: 'battle', featureName: '战斗', requiredStep: TutorialStep.viewCollection),
    FeatureUnlock(featureId: 'buildings', featureName: '建筑', requiredStep: TutorialStep.firstBattle),
    FeatureUnlock(featureId: 'shop', featureName: '商店', requiredStep: TutorialStep.upgradeBuilding),
    FeatureUnlock(featureId: 'prestige', featureName: '转生', requiredStep: TutorialStep.completed),
    FeatureUnlock(featureId: 'achievements', featureName: '成就', requiredStep: TutorialStep.completed),
  ];
}

/// 引导状态
class TutorialState {
  final TutorialStep currentStep;
  final Set<String> unlockedFeatures;
  final bool isTutorialActive;
  final bool hasSeenWelcome;

  const TutorialState({
    this.currentStep = TutorialStep.welcome,
    this.unlockedFeatures = const {},
    this.isTutorialActive = true,
    this.hasSeenWelcome = false,
  });

  bool isFeatureUnlocked(String featureId) => unlockedFeatures.contains(featureId);

  TutorialState copyWith({
    TutorialStep? currentStep,
    Set<String>? unlockedFeatures,
    bool? isTutorialActive,
    bool? hasSeenWelcome,
  }) {
    return TutorialState(
      currentStep: currentStep ?? this.currentStep,
      unlockedFeatures: unlockedFeatures ?? this.unlockedFeatures,
      isTutorialActive: isTutorialActive ?? this.isTutorialActive,
      hasSeenWelcome: hasSeenWelcome ?? this.hasSeenWelcome,
    );
  }

  Map<String, dynamic> toJson() => {
    'currentStep': currentStep.index,
    'unlockedFeatures': unlockedFeatures.toList(),
    'isTutorialActive': isTutorialActive,
    'hasSeenWelcome': hasSeenWelcome,
  };

  factory TutorialState.fromJson(Map<String, dynamic> json) {
    return TutorialState(
      currentStep: TutorialStep.values[json['currentStep'] ?? 0],
      unlockedFeatures: Set<String>.from(json['unlockedFeatures'] ?? []),
      isTutorialActive: json['isTutorialActive'] ?? true,
      hasSeenWelcome: json['hasSeenWelcome'] ?? false,
    );
  }
}

/// 引导管理器
class TutorialNotifier extends StateNotifier<TutorialState> {
  TutorialNotifier() : super(const TutorialState()) {
    _updateUnlockedFeatures();
  }

  /// 从存档加载
  void loadFromSave(TutorialState savedState) {
    state = savedState;
  }

  /// 获取当前步骤的提示
  TutorialHint getCurrentHint() {
    switch (state.currentStep) {
      case TutorialStep.welcome:
        return const TutorialHint(
          title: '欢迎来到钓鱼农场',
          description: '在这里，你将经营自己的钓鱼帝国。点击开始你的冒险！',
          targetWidget: 'start_button',
          actionText: '开始冒险',
          emoji: '🎣',
        );
      case TutorialStep.firstFishing:
        return const TutorialHint(
          title: '开始钓鱼',
          description: '点击下方的【钓鱼】按钮，钓到你的第一条鱼！',
          targetWidget: 'fishing_button',
          actionText: '去钓鱼',
          emoji: '🎣',
        );
      case TutorialStep.viewCollection:
        return const TutorialHint(
          title: '查看你的鱼宠',
          description: '太棒了！你钓到了鱼！点击【图鉴】查看你的收藏。',
          targetWidget: 'collection_button',
          actionText: '查看图鉴',
          emoji: '📖',
        );
      case TutorialStep.firstBattle:
        return const TutorialHint(
          title: '挑战Boss',
          description: '你的鱼宠已经准备好了！点击【战斗】挑战第一个Boss。',
          targetWidget: 'battle_button',
          actionText: '去战斗',
          emoji: '⚔️',
        );
      case TutorialStep.upgradeBuilding:
        return const TutorialHint(
          title: '升级建筑',
          description: '用金币升级建筑可以增加收入！点击【建筑】查看。',
          targetWidget: 'building_button',
          actionText: '查看建筑',
          emoji: '🏗️',
        );
      case TutorialStep.completed:
        return const TutorialHint(
          title: '引导完成',
          description: '恭喜！你已经掌握了基本玩法。继续钓鱼、战斗、升级吧！',
          targetWidget: '',
          actionText: '',
          emoji: '🎉',
        );
    }
  }

  /// 完成当前步骤
  void completeStep() {
    final nextStep = TutorialStep.values[state.currentStep.index + 1];
    state = state.copyWith(currentStep: nextStep);
    _updateUnlockedFeatures();

    if (nextStep == TutorialStep.completed) {
      state = state.copyWith(isTutorialActive: false);
    }
  }

  /// 跳过引导
  void skipTutorial() {
    state = TutorialState(
      currentStep: TutorialStep.completed,
      unlockedFeatures: FeatureUnlock.allFeatures.map((f) => f.featureId).toSet(),
      isTutorialActive: false,
      hasSeenWelcome: true,
    );
  }

  /// 标记欢迎界面已显示
  void markWelcomeSeen() {
    state = state.copyWith(hasSeenWelcome: true);
    _unlockFeature('fishing');
  }

  /// 更新已解锁功能
  void _updateUnlockedFeatures() {
    final currentStepIndex = state.currentStep.index;
    final unlocked = <String>{};

    for (final feature in FeatureUnlock.allFeatures) {
      if (feature.requiredStep.index <= currentStepIndex) {
        unlocked.add(feature.featureId);
      }
    }

    state = state.copyWith(unlockedFeatures: unlocked);
  }

  /// 解锁单个功能
  void _unlockFeature(String featureId) {
    final newFeatures = Set<String>.from(state.unlockedFeatures);
    newFeatures.add(featureId);
    state = state.copyWith(unlockedFeatures: newFeatures);
  }

  /// 检查功能是否解锁
  bool isFeatureUnlocked(String featureId) => state.isFeatureUnlocked(featureId);

  /// 获取下一步建议
  String getNextSuggestion() {
    switch (state.currentStep) {
      case TutorialStep.welcome:
        return '点击开始冒险';
      case TutorialStep.firstFishing:
        return '尝试钓鱼';
      case TutorialStep.viewCollection:
        return '查看你的鱼宠';
      case TutorialStep.firstBattle:
        return '挑战Boss';
      case TutorialStep.upgradeBuilding:
        return '升级建筑';
      case TutorialStep.completed:
        return '继续探索更多玩法！';
    }
  }
}

/// Provider
final tutorialProvider = StateNotifierProvider<TutorialNotifier, TutorialState>((ref) {
  return TutorialNotifier();
});

/// 当前引导提示 Provider
final currentTutorialHintProvider = Provider<TutorialHint>((ref) {
  return ref.watch(tutorialProvider.notifier).getCurrentHint();
});

/// 功能解锁状态 Provider
final featureUnlockProvider = Provider.family<bool, String>((ref, featureId) {
  return ref.watch(tutorialProvider).isFeatureUnlocked(featureId);
});
