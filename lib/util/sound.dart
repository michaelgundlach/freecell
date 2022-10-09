import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

final soundProvider = ChangeNotifierProvider<Sound>((ref) {
  return Sound._();
});

class Sound extends ChangeNotifier {
  Sound._() {
    init();
  }

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  init() async {
    await _musicPlayer.setLoopMode(LoopMode.one);
    await _musicPlayer.setVolume(0.12);
    await _preloadSound(_musicPlayer, Sounds.polka);
    toggleMusic();
  }

  get musicPlaying => _musicPlayer.playing;

  toggleMusic() async {
    if (_musicPlayer.playing) {
      await _musicPlayer.pause();
      await _musicPlayer.seek(Duration.zero);
      print("MUSIC OFF");
    } else {
      _musicPlayer.play();
      print("MUSIC ON");
      _polkaNo = null;
    }
    notifyListeners();
  }

  Future<bool> _preloadSound(player, sound) async {
    // TODO Convince Flutter they have a bug re assets/ - it will randomly want to find them with or
    // without the assets/ prefix! >:(
    final file = _fileForType(sound);
    if (file == null) return false;
    try {
      await player.setAsset('assets/audio/$file');
      return true;
    } catch (e) {
      await player.setAsset('audio/$file');
      return true;
    }
  }

  sfx(Sounds sound) async {
    await _preloadSound(_sfxPlayer, sound);
    _sfxPlayer.play();
  }

  String? _polkaNo;
  polkaNo() {
    if (_polkaNo != null) return _polkaNo;
    const options = [
      "ACCORDI-OFF",
      "LESS AMBIANCE",
      "UNACCORDIATE",
      "ACCORDI-UNDO",
      "FEWER\nACCORDIONS",
    ];

    return _polkaNo = options[Random().nextInt(options.length)];
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
      case Sounds.polka:
        return "waltz-polka.mp3";
    }
  }
}

enum Sounds {
  highlighted,
  played,
  failed,
  polka,
}
