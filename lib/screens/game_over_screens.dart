import 'package:flame/components.dart';
import 'package:flappybirdgame/game/assets.dart';
import 'package:flappybirdgame/game/flappy_bird_game.dart';
import 'package:flutter/material.dart';

class GameOverScreen extends StatelessWidget {
  final FlappyBirdGame game;
  static const String id = 'gameOver';

  const GameOverScreen({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black38,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: ${game.bird.score}',
              style: const TextStyle(
                fontSize: 60,
                color: Colors.white,
                fontFamily: 'Game',
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(Assets.gameOver),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
              ),
              child: const Text(
                'Restart',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onRestart() {
    game.bird.reset();
    game.resetPipes();  // Reset the pipes so they don't interfere with the bird
    game.bird.position = Vector2(50, game.size.y / 2 - game.bird.size.y / 2);  // Reset bird's position

    Future.delayed(const Duration(milliseconds: 500), () {
      game.resumeEngine();  // Start the game engine after a short delay
    });

    game.overlays.remove('gameOver');  // Hide the Game Over screen
  }


  void resetGame() {
    // Reset game state (bird, pipes, score)
    game.resetGame(); // Call the method you defined in FlappyBirdGame
  }

  void resetTimers() {
    // Reset any timers or periodic events
    game.interval.start(); // Ensure the pipe generation timer is reset
  }
}
