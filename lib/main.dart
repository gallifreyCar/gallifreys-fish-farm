import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/game_provider.dart';
import 'services/save_service.dart';
import 'screens/world_screen.dart';

const _fontFallback = <String>[
  'PingFang SC',
  'Hiragino Sans GB',
  'Noto Sans CJK SC',
  'Microsoft YaHei',
  'WenQuanYi Micro Hei',
  'Segoe UI Emoji',
  'Apple Color Emoji',
  'Noto Color Emoji',
  'sans-serif',
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 加载存档
  final savedPlayer = await SaveService.load();

  runApp(
    ProviderScope(
      overrides: [
        gameProvider.overrideWith((ref) {
          return GameNotifier(
            player: savedPlayer,
            onSave: (data) => SaveService.save(data),
          );
        }),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  TextTheme _withFallback(TextTheme base) {
    TextStyle? merge(TextStyle? style) => style?.copyWith(
      fontFamilyFallback: _fontFallback,
      height: 1.2,
    );

    return base.copyWith(
      displayLarge: merge(base.displayLarge),
      displayMedium: merge(base.displayMedium),
      displaySmall: merge(base.displaySmall),
      headlineLarge: merge(base.headlineLarge),
      headlineMedium: merge(base.headlineMedium),
      headlineSmall: merge(base.headlineSmall),
      titleLarge: merge(base.titleLarge),
      titleMedium: merge(base.titleMedium),
      titleSmall: merge(base.titleSmall),
      bodyLarge: merge(base.bodyLarge),
      bodyMedium: merge(base.bodyMedium),
      bodySmall: merge(base.bodySmall),
      labelLarge: merge(base.labelLarge),
      labelMedium: merge(base.labelMedium),
      labelSmall: merge(base.labelSmall),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: "Gallifrey's Fish Farm",
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: _withFallback(baseTheme.textTheme),
        primaryTextTheme: _withFallback(baseTheme.primaryTextTheme),
      ),
      home: const WorldScreen(),
    );
  }
}
