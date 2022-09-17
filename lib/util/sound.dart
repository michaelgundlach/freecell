import 'package:just_audio/just_audio.dart';

class Sound {
  Sound._() : _player = AudioPlayer();
  final AudioPlayer _player;
  static final _sound = Sound._();

  static play(Sounds sound) {
    // TODO Convince Flutter they have a bug re assets/ - it will randomly want to find them with or
    // without the assets/ prefix! >:(
    Future.delayed(Duration.zero, () async {
      final file = _sound._fileForType(sound);
      if (file == null) return;
      try {
        await _sound._player.setAsset('assets/audio/$file');
      } catch (e) {
        await _sound._player.setAsset('audio/$file');
      }
      await _sound._player.play();
    });
  }

  String? _fileForType(Sounds sound) {
    // TODO find out why some sounds work and some don't. What is wrong with their encoding?
    // card-switch.wav : click
    // card1.wav: slop
    // cardSlid7.wav: shhhlop
    switch (sound) {
      case Sounds.highlighted:
        return null;
      case Sounds.played:
        return "card-switch.wav";
      case Sounds.failed:
        return "cardSlide7.wav";
    }
  }
}

enum Sounds {
  highlighted,
  played,
  failed,
}
