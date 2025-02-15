import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flappybirdgame/components/pipe.dart';
import 'package:flappybirdgame/game/configuration.dart';
import 'package:flappybirdgame/game/flappy_bird_game.dart';
import 'package:flappybirdgame/game/pipe_position.dart';

import 'AudioPlayerManager.dart';

class PipeGroup extends PositionComponent with HasGameRef<FlappyBirdGame> {
  PipeGroup();
  final AudioPlayerManager _audioPlayerManager = AudioPlayerManager();
  final _random = Random();

  // Define a fixed gap value between the pipes
  final double fixedGap = 150.0; // Adjust this value to the gap you want
  final double minPipeHeight = 50.0;  // Minimum height before the top pipe
  final double maxPipeHeight = 300.0; // Maximum height for the top pipe
  final double maxGap = 300.0;        // Max gap distance between top and bottom pipe

  double lastGap = 0.0; // Store the gap from the previous pipe

  @override
  Future<void> onLoad() async {
    position.x = gameRef.size.x;

    // Get the height excluding the ground to prevent pipes from going past the floor
    final heightMinusGround = gameRef.size.y - Config.groundHeight;

    // Prevent the next pipe's gap from being at the very top or bottom
    double topPipeHeight;
    double bottomPipeHeight;

    // If last gap is 0, set a random centerY, else adjust to ensure the gap is reasonable
    if (lastGap == 0.0) {
      topPipeHeight = _random.nextDouble() * (heightMinusGround - fixedGap);
    } else {
      // Calculate a top pipe height that prevents the gap from being too small or too large
      final range = minPipeHeight + (lastGap - fixedGap) * 0.5; // Ensure safe range
      topPipeHeight = _random.nextDouble() * (heightMinusGround - range);
    }

    // Calculate the bottom pipe height based on the top pipe height and fixed gap
    bottomPipeHeight = heightMinusGround - (topPipeHeight + fixedGap);

    // Update the lastGap for the next pipe
    lastGap = topPipeHeight;

    // Add the pipes (top and bottom) with the adjusted gap
    addAll([
      Pipe(
        height: topPipeHeight,
        pipePosition: PipePosition.top,
      ),
      Pipe(
        height: bottomPipeHeight,
        pipePosition: PipePosition.bottom,
      ),
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move the pipes to the left
    position.x -= Config.gameSpeed * dt;

    // If the pipes move off the screen, remove them from the parent
    if (position.x < -10) {
      removeFromParent();
      updateScore();
    }

    // If a collision with the bird is detected, remove the pipes
    if (gameRef.isHit) {
      removeFromParent();
      gameRef.isHit = false;
    }
  }

  void updateScore() {
    // Increment the score when the pipes are passed
    gameRef.bird.score++;
    _audioPlayerManager.playDing();
  }
}
