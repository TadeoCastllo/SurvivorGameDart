class GameState {
  int daysSurvived;
  int resourcesCollected;
  bool isGameOver;

  GameState({
    this.daysSurvived = 0,
    this.resourcesCollected = 0,
    this.isGameOver = false,
  });
}