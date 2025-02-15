import 'package:flame/components.dart';
import 'package:flappybirdgame/game/assets.dart';
import 'package:flappybirdgame/game/flappy_bird_game.dart';
import 'package:flutter/material.dart';

class GameOverScreen extends StatefulWidget {
  final FlappyBirdGame game;

  const GameOverScreen({super.key, required this.game});

  @override
  _GameOverScreenState createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  late int highScore;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    // Fetch the high score from your ScoreManager or game
    highScore = await widget.game.bird.getScore();  // Assuming getHighScore() is implemented correctly
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black38,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'High Score: $highScore',
              style: const TextStyle(
                fontSize: 60,
                color: Colors.white,
                fontFamily: 'Game',
              ),
            ),
            Text(
              'Score: ${widget.game.bird.score}',
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
    widget.game.bird.reset();
    widget.game.resetPipes();  // Reset the pipes so they don't interfere with the bird
    widget.game.bird.position = Vector2(50, widget.game.size.y / 2 - widget.game.bird.size.y / 2);  // Reset bird's position

    Future.delayed(const Duration(milliseconds: 500), () {
      widget.game.resumeEngine();  // Start the game engine after a short delay
    });

    widget.game.overlays.remove('gameOver');  // Hide the Game Over screen
  }
}
