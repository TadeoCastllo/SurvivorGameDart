import 'package:flutter/material.dart';
import '../models/card_model.dart';
import 'survivor_card.dart';

class BoardColumn extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final List<GameCard> cards;
  final Function(GameCard) onAccept;

  const BoardColumn({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.cards,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<GameCard>(
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        // Detectamos si una carta está flotando encima para iluminar la columna
        bool isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            // Fondo semitransparente oscuro
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            // Borde brillante si pasas una carta por encima
            border: Border.all(
              color: isHovering
                  ? accentColor
                  : accentColor.withValues(alpha: 0.3),
              width: isHovering ? 2.5 : 1,
            ),
            boxShadow: [
              if (isHovering)
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Column(
            children: [
              // --- CABECERA ESTILIZADA ---
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: accentColor, size: 20),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- LISTA DE CARTAS ---
              Expanded(
                child: cards.isEmpty
                    ? Center(
                        // Mensaje si la lista está vacía
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, size: 40, color: Colors.white10),
                            const SizedBox(height: 10),
                            const Text(
                              "Vacío",
                              style: TextStyle(color: Colors.white24),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          return SurvivorCard(card: cards[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
