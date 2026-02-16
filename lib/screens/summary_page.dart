import 'package:flutter/material.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Extracción segura de argumentos
    final args = ModalRoute.of(context)?.settings.arguments;

    // Valores por defecto
    int days = 0;
    int score = 0;

    // Verificamos si recibimos un Mapa (la nueva lógica)
    if (args is Map) {
      days = args['days'] ?? 0;
      score = args['score'] ?? 0;
    }
    // Por compatibilidad, si por error recibimos solo un int (lógica vieja)
    else if (args is int) {
      days = args;
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.red.shade900],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const Icon(
                  Icons.face_retouching_off_sharp,
                  size: 80,
                  color: Colors.white54,
                ),
                const SizedBox(height: 20),
                const Text(
                  "MISIÓN FALLIDA",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Tus sobrevivientes han caído.",
                  style: TextStyle(color: Colors.white60),
                ),

                const SizedBox(height: 40),

                // 2. Diseño lado a lado para las estadísticas
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard("DÍAS", "$days", Colors.blueAccent),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildStatCard("PUNTOS", "$score", Colors.amber),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // Botones de acción
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/game'),
                  icon: const Icon(Icons.refresh),
                  label: const Text("REINTENTAR MISIÓN"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  child: const Text(
                    "Volver al Menú Principal",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para no repetir código de las tarjetas
  Widget _buildStatCard(String label, String value, Color valueColor) {
    return Card(
      color: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
