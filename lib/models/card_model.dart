enum CardType { survivor, threat, resource }

class GameCard {
  final String id;
  final String name;
  final CardType type;
  double health; // 0.0 a 1.0
  final double power; // Daño (si es amenaza) o Curación (si es recurso)

  GameCard({
    required this.id,
    required this.name,
    required this.type,
    this.health = 1.0,
    this.power = 0.0,
  });
}