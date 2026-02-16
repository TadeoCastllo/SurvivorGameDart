import 'package:flutter/material.dart';
import '../models/card_model.dart';

class SurvivorCard extends StatelessWidget {
  final GameCard card;

  const SurvivorCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final isDead = card.health <= 0 && card.type == CardType.survivor;
    final isThreat = card.type == CardType.threat;
    // Si está muerto o es una amenaza, NO se puede arrastrar (maxSimultaneousDrags: 0)
    return Draggable<GameCard>(
      data: card,
      maxSimultaneousDrags: (isDead || isThreat) ? 0 : 1,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 200, child: _buildCardUI(isDragging: true)),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCardUI(isDragging: false),
      ),
      child: _buildCardUI(isDragging: false),
    );
  }

  Widget _buildCardUI({required bool isDragging}) {
    final isDead = card.health <= 0 && card.type == CardType.survivor;
    final isThreat = card.type == CardType.threat;
    final isResource = card.type == CardType.resource;

    Color bgColor = Colors.blueGrey;
    if (isThreat) bgColor = Colors.red.shade900;
    if (isResource) bgColor = Colors.green.shade900;
    if (isDead) bgColor = Colors.grey.shade900;

    return Card(
      elevation: isDragging ? 8 : 2,
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isThreat
                      ? Icons.warning
                      : (isResource ? Icons.medical_services : Icons.person),
                  color: isDead ? Colors.grey : Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    card.name + (isDead ? " (RIP)" : ""),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isDead ? TextDecoration.lineThrough : null,
                      color: isDead ? Colors.grey : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (!isThreat && !isResource)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: LinearProgressIndicator(
                  value: card.health,
                  backgroundColor: Colors.black26,
                  color: card.health > 0.5 ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
