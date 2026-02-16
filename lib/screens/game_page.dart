import 'dart:async';
import 'dart:math'; // Necesario para el Random
import 'package:flutter/material.dart';
import '../widgets/board_column.dart';
import '../models/card_model.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int score = 0;
  Timer? gameTimer;
  int secondsActive = 0;
  bool gameStarted = false; // Control para esperar al jugador

  // Listas de Estado
  List<GameCard> shelterCards = [
    GameCard(id: '1', name: 'Sobreviviente Alpha', type: CardType.survivor),
    GameCard(id: '2', name: 'Sobreviviente Beta', type: CardType.survivor),
    GameCard(id: '3', name: 'Sobreviviente Gamma', type: CardType.survivor),
  ];
  List<GameCard> expeditionCards = [];
  List<GameCard> dangerCards = [];

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  // --- LÓGICA DEL MOTOR DE JUEGO ---

  void _startGameLoop() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsActive++;
        int tickScore = 1;
        int survivorsInExpedition = expeditionCards
            .where((c) => c.health > 0)
            .length;
        tickScore += (survivorsInExpedition * 5);
        score += tickScore;
        // 1. Desgaste en Expedición (Solo si están vivos)
        for (var card in expeditionCards) {
          if (card.health > 0) {
            card.health = (card.health - 0.04).clamp(0.0, 1.0);
          }
        }

        // 2. Recuperación en Refugio (Solo si están vivos, NO resucitan)
        for (var card in shelterCards) {
          if (card.health > 0) {
            card.health = (card.health + 0.03).clamp(0.0, 1.0);
          }
        }

        // 3. Daño Global por Amenazas Activas
        if (dangerCards.isNotEmpty) {
          double threatDamage =
              dangerCards.length * 0.02; // 2% de daño por cada amenaza
          // Afecta a TODOS los vivos en cualquier lugar
          for (var card in [...shelterCards, ...expeditionCards]) {
            if (card.health > 0) {
              card.health = (card.health - threatDamage).clamp(0.0, 1.0);
            }
          }
        }

        // 4. Eventos Aleatorios (Spawns)
        if (secondsActive % 8 == 0) _spawnThreat(); // Cada 8s una amenaza
        if (secondsActive % 12 == 0) _spawnResource(); // Cada 12s un recurso

        _checkGameOver();
      });
    });
  }

  void _spawnThreat() {
    final threats = [
      {'name': 'Tormenta', 'power': 0.0},
      {'name': 'Infección', 'power': 0.0},
      {'name': 'Horda', 'power': 0.0},
    ];
    final randomThreat = threats[Random().nextInt(threats.length)];

    setState(() {
      dangerCards.add(
        GameCard(
          id: "threat_${DateTime.now().millisecondsSinceEpoch}",
          name: randomThreat['name'] as String,
          type: CardType.threat,
          health: 1.0, // Las amenazas no usan vida, pero el modelo lo pide
        ),
      );
    });
  }

  void _spawnResource() {
    // Los recursos aparecen en la Expedición para obligarte a salir
    setState(() {
      expeditionCards.add(
        GameCard(
          id: "res_${DateTime.now().millisecondsSinceEpoch}",
          name: 'Suministros',
          type: CardType.resource,
          health: 1.0,
        ),
      );
    });
  }

  void _checkGameOver() {
    // El juego acaba si TODOS los sobrevivientes (en refugio o expedición) tienen 0 vida
    bool allDead = [
      ...shelterCards,
      ...expeditionCards,
    ].where((c) => c.type == CardType.survivor).every((c) => c.health <= 0);

    if (allDead) {
      gameTimer?.cancel();
      Navigator.pushReplacementNamed(
        context,
        '/summary',
        arguments: {'days': secondsActive, 'score': score},
      );
    }
  }

  // --- LÓGICA DE MOVIMIENTO (DRAG & DROP) ---
  void _moveCard(GameCard card, List<GameCard> targetList) {
    setState(() {
      // 1. Iniciar juego al primer movimiento
      if (!gameStarted) {
        gameStarted = true;
        _startGameLoop();
      }

      // 2. Lógica de Recursos (Consumibles)
      if (card.type == CardType.resource) {
        if (targetList == shelterCards) {
          score += 50;
          // Si sueltas recurso en refugio -> Cura a todos los vivos
          for (var survivor in shelterCards) {
            if (survivor.health > 0) {
              survivor.health = (survivor.health + 0.3).clamp(0.0, 1.0);
            }
          }
          // El recurso se consume (desaparece)
          _removeCardFromAll(card);
          return;
        }
      }

      // 3. Lógica de Combate (Sobreviviente ataca Amenaza)
      if (card.type == CardType.survivor && targetList == dangerCards) {
        if (dangerCards.isNotEmpty) {
          score += 100;
          // Elimina la amenaza más antigua
          dangerCards.removeAt(0);
          // El sobreviviente recibe daño por pelear
          card.health = (card.health - 0.25).clamp(0.0, 1.0);
          // El sobreviviente regresa al refugio "herido" automáticamente
          _removeCardFromAll(card);
          shelterCards.add(card);
          return;
        } else {
          // Si no hay amenazas, no dejes que el sobreviviente se quede en peligro
          return;
        }
      }

      // 4. Movimiento Normal (Cambio de columna)
      _removeCardFromAll(card);
      targetList.add(card);
    });
  }

  void _removeCardFromAll(GameCard card) {
    shelterCards.removeWhere((c) => c.id == card.id);
    expeditionCards.removeWhere((c) => c.id == card.id);
    dangerCards.removeWhere((c) => c.id == card.id);
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Extendemos el cuerpo detrás del AppBar para un look más inmersivo
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'SURVIVOR KANBAN',
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black.withValues(alpha: 0.5), // Transparente
        elevation: 0,
        actions: [
          // HUD Mejorado
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: gameStarted ? Colors.greenAccent : Colors.orangeAccent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: gameStarted
                      ? Colors.greenAccent.withValues(alpha: 0.2)
                      : Colors.orangeAccent.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.timer, size: 16, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  gameStarted ? "$secondsActive" : "WAITING",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                    color: Colors.white,
                  ),
                ),
                const VerticalDivider(
                  color: Colors.white24,
                  thickness: 1,
                  width: 20,
                ),
                Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  "$score",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        // FONDO ATMOSFÉRICO
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1c29), // Azul oscuro casi negro
              Color(0xFF0d0e15), // Negro profundo
            ],
          ),
        ),
        child: SafeArea(
          // Protegemos el contenido de los bordes del notch
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: OrientationBuilder(
              builder: (context, orientation) {
                // Pasamos iconos y colores temáticos a las columnas
                final columns = [
                  Expanded(
                    child: BoardColumn(
                      title: "REFUGIO",
                      subtitle: "+ Salud",
                      icon: Icons.security,
                      accentColor: Colors.greenAccent,
                      cards: shelterCards,
                      onAccept: (c) => _moveCard(c, shelterCards),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                    height: 8,
                  ), // Separación entre columnas
                  Expanded(
                    child: BoardColumn(
                      title: "EXPEDICIÓN",
                      subtitle: "+ Puntos / - Salud",
                      icon: Icons.explore,
                      accentColor: Colors.blueAccent,
                      cards: expeditionCards,
                      onAccept: (c) => _moveCard(c, expeditionCards),
                    ),
                  ),
                  const SizedBox(width: 8, height: 8),
                  Expanded(
                    child: BoardColumn(
                      title: "PELIGRO",
                      subtitle: "¡Amenaza Activa!",
                      icon: Icons.warning_amber_rounded,
                      accentColor: Colors.redAccent,
                      cards: dangerCards,
                      onAccept: (c) => _moveCard(c, dangerCards),
                    ),
                  ),
                ];

                return orientation == Orientation.portrait
                    ? Column(children: columns)
                    : Row(children: columns);
              },
            ),
          ),
        ),
      ),
    );
  }
}
