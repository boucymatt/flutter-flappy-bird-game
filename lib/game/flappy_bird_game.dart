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
  Timer interval = Timer(
    Config.pipeInterval,
    repeat: true,
  );
  bool isHit = false;

  @override
  Future<void> onLoad() async {
    addAll([
      Background(),
      Ground(),
      bird = Bird(),
      score = buildScore(),
    ]);

    interval.onTick = () => add(PipeGroup());
  }

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
