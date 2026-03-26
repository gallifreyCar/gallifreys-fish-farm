import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/game_provider.dart';
import 'services/save_service.dart';
import 'screens/world_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Gallifrey's Fish Farm",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const WorldScreen(),
    );
  }
}
