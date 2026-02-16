import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/game_page.dart';
import 'screens/summary_page.dart';

void main() {
  runApp(const SurvivorKanbanApp());
}

class SurvivorKanbanApp extends StatelessWidget {
  const SurvivorKanbanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Survivor Kanban',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark, // Tema oscuro para supervivencia
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/game': (context) => const GamePage(),
        '/summary': (context) => const SummaryPage(),
      },
    );
  }
}