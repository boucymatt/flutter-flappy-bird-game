import 'dart:async';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flappybirdgame/components/background.dart';
import 'package:flappybirdgame/components/bird.dart';
import 'package:flappybirdgame/components/ground.dart';
import 'package:flappybirdgame/components/pipe_group.dart';
import 'package:flappybirdgame/game/configuration.dart';
import 'package:flutter/painting.dart';

class FlappyBirdGame extends FlameGame with TapDetector, HasCollisionDetection {
  late Bird bird;
  late TextComponent score;
  Timer interval = Timer(Config.pipeInterval, repeat: true);
  bool isHit = false;

  // List to keep track of active pipe groups
  List<PipeGroup> pipeGroups = [];

  @override
  Future<void> onLoad() async {
    // Load all components here
    addAll([
      Background(),
      Ground(),
      bird = Bird(),
      score = buildScore(),
    ]);
    score.priority = 10;

    interval.onTick = () {
      PipeGroup pipeGroup = PipeGroup();  // Create new pipe group
      pipeGroups.add(pipeGroup);  // Add it to the list of pipe groups
      add(pipeGroup);  // Add the new pipe group to the game
    };
  }

  // Method to reset pipes when the game restarts
  void resetPipes() {
    // Clear the list of active pipe groups
    pipeGroups.forEach((pipeGroup) {
      pipeGroup.removeFromParent();  // Remove each pipe group from the game
    });
    pipeGroups.clear();  // Clear the list of pipe groups

    // Optionally, you can spawn new pipes or reset pipe positions here
  }

  // Method to build and return the score text component
  TextComponent buildScore() {
    return TextComponent(
      text: 'Score: 0',
      position: Vector2(
        size.x / 2,
        size.y / 2 * 0.2,
      ),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          fontFamily: 'Game',
        ),
      ),
    );
  }

  // Reset the game state, including bird, score, and pipes
  void resetGame() {
    // Reset the bird's state and score
    bird.reset();
    bird.score = 0;

    // Clear any previously added components like pipes or score
    removeAllComponents();
    pipeGroups.clear();
    // Add all components back
    addAll([
      Background(),
      Ground(),
      bird = Bird(),
      score = buildScore(),
    ]);

    // Reset the timer
    interval.start();
  }
  void removeAllComponents() {
    // Use `children` to access the list of all components and remove them
    children.toList().forEach((component) {
      component.removeFromParent();
    });
  }
  @override
  void onTap() {
    super.onTap();
    bird.fly();
  }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);

    score.text = 'Score: ${bird.score}';
  }
}