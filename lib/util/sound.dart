import 'package:just_audio/just_audio.dart';

class Sound {
  Sound._() : _player = AudioPlayer();
  final AudioPlayer _player;
  static final _sound = Sound._();

  static Future<void> play(Sounds sound) async {
    await _sound._player.setAsset('assets/audio/${_sound._fileForType(sound)}');
    await _sound._player.play();
  }

  String _fileForType(Sounds sound) {
    switch (sound) {
      case Sounds.highlighted:
        return "tap.mp3";
      case Sounds.played:
        return "tap2.mp3";
      case Sounds.failed:
        return "tap3.mp3";
    }
  }
}

enum Sounds {
  highlighted,
  played,
  failed,
}
