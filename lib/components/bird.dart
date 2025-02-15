import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flappybirdgame/game/assets.dart';
import 'package:flappybirdgame/game/configuration.dart';
import 'package:flappybirdgame/game/flappy_bird_game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AudioPlayerManager.dart';

class Bird extends SpriteComponent with HasGameRef<FlappyBirdGame>, CollisionCallbacks {
  Bird();

  int score = 0;
  int highScore = 0;
  final AudioPlayerManager _audioPlayerManager = AudioPlayerManager();
  double fallSpeed = 0; // Keep track of the bird's falling speed

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(Assets.bird);
    size = Vector2(50, 40);
    position = Vector2(50, gameRef.size.y / 2 - size.y / 2);
    highScore = await getScore();
    // Set the pivot (anchor) to the center of the bird for smooth rotation
    anchor = Anchor.center;

    add(CircleHitbox());
  }

  void fly() {
    _audioPlayerManager.playFlap();

    fallSpeed = Config.birdVelocity * -1.3; // Upward movement based on Config

    // Apply a slight rotation for the upward movement
    add(
      RotateEffect.by(
        -0.3, // Slight upward tilt
        EffectController(duration: 0.2, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply gravity from the Config class to fall faster over time
    fallSpeed -= Config.gravity * 2 * dt; // Using gravity from Config to update fallSpeed
    position.y += fallSpeed * dt; // Update the bird's position based on fallSpeed

    // Apply rotation based on the current movement (falling or flying)
    if (fallSpeed < 0) {
      // Upward tilt while flying
      angle = lerpAngle(angle, -0.3, 0.6); // Smooth upward tilt transition
    } else if (fallSpeed > 150) {
      // Downward tilt when falling
      angle = lerpAngle(angle, 1.5, 0.2); // Smooth downward tilt transition
    }

    // Game over if the bird hits the ground
    if (position.y < 1) {
      gameOver();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    gameOver(); // Trigger game over on collision
  }

  void gameOver() {
    _audioPlayerManager.playCol();
    gameRef.overlays.add('gameOver');
    gameRef.pauseEngine();
    game.isHit = true;
    saveScore(score);
  }

  void reset() {
    position = Vector2(50, gameRef.size.y / 2 - size.y / 2);
    angle = 0; // Reset rotation
    fallSpeed = 0; // Reset fall speed
    score = 0; // Reset score
  }

  // Custom lerpAngle function to smoothly transition angles
  double lerpAngle(double start, double end, double t) {
    double diff = (end - start) % (2 * 3.141592653589793); // Ensure the shortest rotation
    if (diff > 3.141592653589793) diff -= 2 * 3.141592653589793;
    if (diff < -3.141592653589793) diff += 2 * 3.141592653589793;
    return start + diff * t;
  }
  Future<void> saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();

    // Get the previously saved score, default to 0 if not found
    int previousScore = prefs.getInt('score') ?? 0;

    // Only save the new score if it's higher than the previous score
    if (score > previousScore) {
      await prefs.setInt('score', score);  // Save the new high score
    }
  }

  // Retrieve the score from SharedPreferences
  Future<int> getScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('score') ?? 0;  // Default value is 0 if not found
  }
}
