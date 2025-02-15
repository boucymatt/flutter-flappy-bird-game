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
  final double fixedGap = 120.0; // Adjust this value to keep the gap the same
  // Define the minimum and maximum variation for the gap position
  final double minGapVariation = 50.0;
  final double maxGapVariation = 50.0;

  double lastCenterY = 0.0;

  @override
  Future<void> onLoad() async {
    position.x = gameRef.size.x;

    // Get the height excluding the ground to prevent pipes from going past the floor
    final heightMinusGround = gameRef.size.y - Config.groundHeight;

    // Randomize the centerY but ensure the new position is not too far from the previous gap
    double centerY;
    if (lastCenterY == 0.0) {
      centerY = _random.nextDouble() * (heightMinusGround - fixedGap);
    } else {
      final minY = max(lastCenterY - maxGapVariation, 0.0);
      final maxY = min(lastCenterY + maxGapVariation, heightMinusGround - fixedGap);
      centerY = _random.nextDouble() * (maxY - minY) + minY;
    }

    // Store the current centerY as the last position for the next pipe
    lastCenterY = centerY;

    // Add pipes with fixed gap
    addAll([
      Pipe(
        height: centerY,  // Top pipe height
        pipePosition: PipePosition.top,
      ),
      Pipe(
        height: heightMinusGround - (centerY + fixedGap),  // Bottom pipe height
        pipePosition: PipePosition.bottom,
      ),
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= Config.gameSpeed * dt;

    // If the pipes move off the screen, remove them
    if (position.x < -10) {
      removeFromParent();
      updateScore();
    }

    // If the bird collides with the pipes, remove them
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
