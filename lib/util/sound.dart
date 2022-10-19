import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
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
  final AudioPlayer _winMusicPlayer = AudioPlayer();
  final _musicVolume = 0.12;

  init() async {
    await _musicPlayer.setLoopMode(LoopMode.one);
    await _musicPlayer.setVolume(_musicVolume);
    await _preloadSound(_musicPlayer, Sounds.polka);
    // Just in case this would slow things down
    Future.delayed(const Duration(seconds: 5), () {
      _winMusicPlayer.setLoopMode(LoopMode.one);
      _winMusicPlayer.setVolume(_musicVolume);
      _preloadSound(_winMusicPlayer, Sounds.winMusic);
    });
    if (!kIsWeb) toggleMusic();
  }

  get musicPlaying => _musicPlayer.playing;

  toggleMusic({fade = false}) async {
    if (_musicPlayer.playing) {
      await _musicPlayer.pause();
      await _musicPlayer.seek(Duration.zero);
      print("MUSIC OFF");
    } else {
      if (fade) {
        _musicPlayer.setVolume(0);
        final stopwatch = Stopwatch()..start();
        const duration = 10.0;
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
          double animation = (stopwatch.elapsed.inMilliseconds / 1000) / duration;
          if (animation < 1) {
            _musicPlayer.setVolume(
              Tween(begin: 0, end: _musicVolume)
                  .chain(CurveTween(curve: Curves.easeIn))
                  .transform(animation)
                  .toDouble(),
            );
          } else {
            _musicPlayer.setVolume(_musicVolume);
            timer.cancel();
          }
        });
      }
      _musicPlayer.play();
      print("MUSIC ON");
      _polkaNo = null;
    }
    notifyListeners();
  }

  playWinMusic() {
    _musicPlayer.stop();
    if (!_winMusicPlayer.playing) _winMusicPlayer.play();
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
      case Sounds.winMusic:
        return "win.mp3";
    }
  }
}

enum Sounds {
  highlighted,
  played,
  failed,
  polka,
  winMusic,
}
