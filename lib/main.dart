import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/logic/game_logic.dart';
import 'src/ui/sonic_soccer_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameLogic(),
      child: const GameWatchApp(),
    ),
  );
}

class GameWatchApp extends StatelessWidget {
  const GameWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game & Watch: Sonic Soccer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0F14),
        fontFamily: 'monospace',
      ),
      home: const SonicSoccerScreen(),
    );
  }
}
