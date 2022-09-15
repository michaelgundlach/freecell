import 'dart:math';

import 'package:just_audio/just_audio.dart';

class Sound {
  Sound._() : _player = AudioPlayer();
  final AudioPlayer _player;
  static final _sound = Sound._();

  static Future<void> play(Sounds sound) async {
    // TODO Convince Flutter they have a bug re assets/ - it will randomly want to find them with or
    // without the assets/ prefix! >:(
    try {
      await _sound._player.setAsset('assets/audio/${_sound._fileForType(sound)}');
    } catch (e) {
      await _sound._player.setAsset('audio/${_sound._fileForType(sound)}');
    }
    _sound._player.play();
  }

  String _fileForType(Sounds sound) {
    // TODO find out why some sounds work and some don't. What is wrong with their encoding?
    switch (sound) {
      case Sounds.highlighted:
        return "card-switch.wav";
      case Sounds.played:
        return "card1.wav";
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
