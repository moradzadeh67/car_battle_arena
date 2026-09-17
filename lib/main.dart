import 'package:flutter/material.dart';
import 'package:car_battle_arena/features/lobby/network_menu.dart';
import 'package:car_battle_arena/features/gameplay/gameplay_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Car Battle Arena',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const MainEntry(),
    );
  }
}

class MainEntry extends StatefulWidget {
  const MainEntry({super.key});

  @override
  State<MainEntry> createState() => _MainEntryState();
}

class _MainEntryState extends State<MainEntry> {
  @override
  Widget build(BuildContext context) {
    return NetworkMenu(
      onStartGame: (transport, isHost) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GameplayPage(transport: transport, isHost: isHost),
          ),
        );
      },
    );
  }
}
