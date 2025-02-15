import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flappybirdgame/components/pipe.dart';
import 'package:flappybirdgame/game/assets.dart';
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

  @override
  Future<void> onLoad() async {
    position.x = gameRef.size.x;

    // Get the height excluding the ground to prevent pipes from going past the floor
    final heightMinusGround = gameRef.size.y - Config.groundHeight;

    // Set the center of the pipes
    final centerY = _random.nextDouble() * (heightMinusGround - fixedGap);

    // Calculate the top pipe height based on the fixed gap
    final topPipeHeight = centerY;

    // Ensure the bottom pipe doesn't go past the floor by using fixed gap
    final bottomPipeHeight = heightMinusGround - (centerY + fixedGap);

    // Add the pipes (top and bottom) with the fixed gap
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