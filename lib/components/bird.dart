import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flappybirdgame/game/assets.dart';
import 'package:flappybirdgame/game/bird_movement.dart';
import 'package:flappybirdgame/game/configuration.dart';
import 'package:flappybirdgame/game/flappy_bird_game.dart';
import 'package:flutter/material.dart';

import 'AudioPlayerManager.dart';

class Bird extends SpriteGroupComponent<BirdMovement>
    with HasGameRef<FlappyBirdGame>, CollisionCallbacks {
  Bird();

  int score = 0;
  final AudioPlayerManager _audioPlayerManager = AudioPlayerManager();
  @override
  Future<void> onLoad() async {
    final birdMidFlap = await gameRef.loadSprite(Assets.birdMidFlap);
    final birdUpFlap = await gameRef.loadSprite(Assets.birdUpFlap);
    final birdDownFlap = await gameRef.loadSprite(Assets.birdDownFlap);

    // Print the details of each sprite to ensure they are loaded correctly
    print("birdMidFlap: ${birdMidFlap.image.toString()}");
    print("birdUpFlap: ${birdUpFlap.image.toString()}");
    print("birdDownFlap: ${birdDownFlap.image.toString()}");

    // Check if the sprites are not null
    if (birdMidFlap.image == null || birdUpFlap.image == null || birdDownFlap.image == null) {
      print("Error: One or more sprites failed to load.");
      return;  // Return early if there's an issue with the sprites
    }

    // Set the size and position of the bird
    size = Vector2(50, 40);
    position = Vector2(50, gameRef.size.y / 2 - size.y / 2);

    // Set the sprites map
    sprites = {
      BirdMovement.middle: birdMidFlap,
      BirdMovement.up: birdUpFlap,
      BirdMovement.down: birdDownFlap,
    };

    // Set the current sprite
    current = BirdMovement.middle;

    // Add a collision hitbox
    add(CircleHitbox());
  }


  void fly() {
    _audioPlayerManager.playFlap();
    add(
      MoveByEffect(
        Vector2(
          0,
          Config.gravity,
        ),
        EffectController(
          duration: 0.3,
          curve: Curves.decelerate,
        ),
        onComplete: () => current = BirdMovement.down,
      ),
    );
    current = BirdMovement.up;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    gameOver();
  }

  void reset() {
    position = Vector2(
      50,
      gameRef.size.y / 2 - size.y / 2,
    );
    score = 0;
  }

  void gameOver() {
    _audioPlayerManager.playCol();
    gameRef.overlays.add('gameOver');
    gameRef.pauseEngine();
    game.isHit = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += Config.birdVelocity * dt;
    if (position.y < 1) {
      gameOver();
    }
  }
}
