import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flappybirdgame/game/assets.dart';
import 'package:flappybirdgame/game/configuration.dart';
import 'package:flappybirdgame/game/flappy_bird_game.dart';
import 'package:flappybirdgame/game/pipe_position.dart';

class Pipe extends SpriteComponent with HasGameRef<FlappyBirdGame> {
  @override
  final double height;
  final PipePosition pipePosition;

  Pipe({
    required this.height,
    required this.pipePosition,
  });

  @override
  Future<void> onLoad() async {
    final pipe = await Flame.images.load(Assets.pipe);

    size = Vector2(
      50,
      height,
    );
    switch (pipePosition) {
      case PipePosition.top:
      // Set the anchor for the top pipe to the top-center
        anchor = Anchor.bottomCenter;
        position.y = 0; // Position the top pipe at the very top of the screen
        sprite = Sprite(pipe);
        angle = 3.14159; // Rotate by 180 degrees (in radians)
        break;
      case PipePosition.bottom:
        anchor = Anchor.topCenter;
        position.y = gameRef.size.y - size.y - Config.groundHeight;
        sprite = Sprite(pipe);
        break;
    }

    // collision detection
    add(RectangleHitbox());
  }
}
