import 'package:audioplayers/audioplayers.dart';
import '../game/assets.dart';

class AudioPlayerManager {
  final List<AudioPlayer> _activePlayers = [];

  // Play flap sound without interrupting others
  Future<void> playFlap() async {
    try {
      AudioPlayer newPlayer = AudioPlayer();
      _activePlayers.add(newPlayer);

      await newPlayer.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          usageType: AndroidUsageType.game,
          contentType: AndroidContentType.sonification,
          audioFocus: AndroidAudioFocus.none,  // Ensures multiple sounds play
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,  // Allows multiple sounds
        ),
      ));

      await newPlayer.setReleaseMode(ReleaseMode.release);
      newPlayer.play(AssetSource(Assets.flying));  // Play without await to avoid blocking

      _removeAfterCompletion(newPlayer);
    } catch (e) {
      print("Error playing flap: $e");
    }
  }

  // Play ding sound without stopping other sounds
  Future<void> playDing() async {
    try {
      AudioPlayer newPlayer = AudioPlayer();
      _activePlayers.add(newPlayer);

      await newPlayer.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          usageType: AndroidUsageType.game,
          contentType: AndroidContentType.sonification,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
        ),
      ));

      await newPlayer.setReleaseMode(ReleaseMode.release);
      newPlayer.play(AssetSource(Assets.point));

      _removeAfterCompletion(newPlayer);
    } catch (e) {
      print("Error playing ding: $e");
    }
  }

  // Play collision sound independently
  Future<void> playCol() async {
    try {
      AudioPlayer newPlayer = AudioPlayer();
      _activePlayers.add(newPlayer);

      await newPlayer.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          usageType: AndroidUsageType.game,
          contentType: AndroidContentType.sonification,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
        ),
      ));

      await newPlayer.setReleaseMode(ReleaseMode.release);
      newPlayer.play(AssetSource(Assets.collision));

      _removeAfterCompletion(newPlayer);
    } catch (e) {
      print("Error playing collision: $e");
    }
  }

  // Removes the AudioPlayer after it has finished playing to free memory
  void _removeAfterCompletion(AudioPlayer player) {
    player.onPlayerComplete.listen((event) {
      _activePlayers.remove(player);
      player.dispose();  // Properly dispose of the player
    });
  }
}
