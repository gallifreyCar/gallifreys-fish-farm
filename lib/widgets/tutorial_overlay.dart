import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tutorial_service.dart';

/// 新手引导遮罩组件
class TutorialOverlay extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onComplete;

  const TutorialOverlay({
    super.key,
    required this.child,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorialState = ref.watch(tutorialProvider);

    if (!tutorialState.isTutorialActive) {
      return child;
    }

    return Stack(
      children: [
        child,
        if (tutorialState.currentStep != TutorialStep.completed)
          _buildTutorialDialog(context, ref),
      ],
    );
  }

  Widget _buildTutorialDialog(BuildContext context, WidgetRef ref) {
    final hint = ref.watch(currentTutorialHintProvider);
    final tutorialState = ref.watch(tutorialProvider);

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 进度指示器
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final stepIndex = TutorialStep.values.indexOf(tutorialState.currentStep);
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index <= stepIndex ? Colors.blue : Colors.grey,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Emoji
                Text(
                  hint.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 12),

                // 标题
                Text(
                  hint.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // 描述
                Text(
                  hint.description,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // 按钮
                if (tutorialState.currentStep == TutorialStep.welcome)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          ref.read(tutorialProvider.notifier).skipTutorial();
                        },
                        child: Text(
                          '跳过',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(tutorialProvider.notifier).markWelcomeSeen();
                          ref.read(tutorialProvider.notifier).completeStep();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('开始冒险'),
                      ),
                    ],
                  )
                else
                  TextButton(
                    onPressed: () {
                      ref.read(tutorialProvider.notifier).skipTutorial();
                    },
                    child: Text(
                      '我知道了',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 引导高亮组件
class TutorialHighlight extends ConsumerWidget {
  final String featureId;
  final Widget child;
  final VoidCallback? onTap;

  const TutorialHighlight({
    super.key,
    required this.featureId,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnlocked = ref.watch(featureUnlockProvider(featureId));

    if (!isUnlocked) {
      return _buildLockedWidget(context);
    }

    return GestureDetector(
      onTap: () {
        onTap?.call();
        _checkTutorialProgress(context, ref);
      },
      child: child,
    );
  }

  Widget _buildLockedWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔒 此功能尚未解锁，请完成引导'),
            backgroundColor: Colors.grey[800],
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Stack(
        children: [
          Opacity(
            opacity: 0.5,
            child: child,
          ),
          Positioned.fill(
            child: Center(
              child: Icon(
                Icons.lock,
                color: Colors.grey[400],
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkTutorialProgress(BuildContext context, WidgetRef ref) {
    final tutorialState = ref.read(tutorialProvider);
    final notifier = ref.read(tutorialProvider.notifier);

    switch (tutorialState.currentStep) {
      case TutorialStep.firstFishing:
        if (featureId == 'fishing') {
          notifier.completeStep();
        }
        break;
      case TutorialStep.viewCollection:
        if (featureId == 'collection') {
          notifier.completeStep();
        }
        break;
      case TutorialStep.firstBattle:
        if (featureId == 'battle') {
          notifier.completeStep();
        }
        break;
      case TutorialStep.upgradeBuilding:
        if (featureId == 'buildings') {
          notifier.completeStep();
        }
        break;
      default:
        break;
    }
  }
}

/// 新手引导提示气泡
class TutorialTip extends ConsumerWidget {
  final String message;
  final Offset? position;

  const TutorialTip({
    super.key,
    required this.message,
    this.position,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      left: position?.dx,
      top: position?.dy,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[700],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '👆',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
