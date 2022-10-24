import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../model/game-state.dart';

final soundProvider = ChangeNotifierProvider<Sound>((ref) {
  return Sound._(ref);
}, dependencies: [GameState.provider]);

class Sound extends ChangeNotifier {
  final Ref ref;
  Sound._(this.ref) {
    _init();
  }

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _winMusicPlayer = AudioPlayer();
  final _musicVolume = 0.12;
  String? _winSong;

  // Needed to force lazy provider to create sound and start preloading
  wakeUp() {}

  _init() async {
    await _musicPlayer.setLoopMode(LoopMode.one);
    await _musicPlayer.setVolume(_musicVolume);
    await _preloadSound(_musicPlayer, Sounds.polka);
    _winMusicPlayer.setLoopMode(LoopMode.one);
    _winMusicPlayer.setVolume(_musicVolume);
    ref.listen(fireImmediately: true, GameState.provider.select((gs) => gs.numFreeCells), (_, n) => _chooseWinSong(n));
    ref.listen(fireImmediately: true, GameState.provider.select((gs) => gs.stage), (oldStage, newStage) {
      // TODO have one music player.  always play victory music. On deal, honor the user's on/off request.
      if (newStage == "init" && !kIsWeb) {
        print("Game startup, not on web: sound playing music");
        _toggleWinMusic(play: false);
        toggleMusic(play: true);
      }
      if (oldStage != "winning" && newStage == "winning") {
        print("Entered 'winning' stage, sound playing victory music $_winSong");
        toggleMusic(play: false);
        _toggleWinMusic(play: true);
      } else if (oldStage != "playing" && newStage == "playing") {
        print("Entered 'playing' stage, sound playing music");
        _toggleWinMusic(play: false);
        toggleMusic(play: true);
      }
    });
  }

  get musicPlaying => _musicPlayer.playing;
  get winMusicPlaying => _winMusicPlayer.playing;

  toggleMusic({bool? play, fade = false}) async {
    bool shouldPlay = play ?? !_musicPlayer.playing;
    if (shouldPlay == _musicPlayer.playing) return;
    if (!shouldPlay) {
      await _musicPlayer.pause();
      await _musicPlayer.seek(Duration.zero);
      print("MUSIC OFF");
    } else {
      if (_winMusicPlayer.playing) {
        await _winMusicPlayer.pause();
        await _winMusicPlayer.seek(Duration.zero);
        print("WIN MUSIC OFF");
      }
      if (fade) {
        _musicPlayer.setVolume(0);
        final stopwatch = Stopwatch()..start();
        const duration = 1.5;
        // TODO what's the right way to do this with a PlayAnimation?
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

  /// TODO watch gamestate instead
  _chooseWinSong(numFreeCells) {
    String choice;
    if (numFreeCells <= 3) {
      choice = "win-a.mp3";
    } else if (numFreeCells <= 6) {
      choice = "win-b.mp3";
    } else {
      choice = "win-f.mp3";
    }
    if (choice == _winSong) return;
    _winSong = choice;
    print("Num free cells increased to $numFreeCells, adjusting win music to $_winSong");
    _preloadSound(_winMusicPlayer, Sounds.winMusic);
  }

  _toggleWinMusic({bool? play}) async {
    if (play ?? !_winMusicPlayer.playing) {
      if (_musicPlayer.playing) {
        await _musicPlayer.pause();
        await _musicPlayer.seek(Duration.zero);
        print("MUSIC PLAYER TURNED OFF BY WIN MUSIC");
      }
      if (!_winMusicPlayer.playing) {
        print("WIN MUSIC ON");
        _winMusicPlayer.play();
      }
    } else {
      await _winMusicPlayer.pause();
      await _winMusicPlayer.seek(Duration.zero);
      print("WIN MUSIC OFF");
    }
  }

  Future<bool> _preloadSound(AudioPlayer player, sound) async {
    // TODO Convince Flutter they have a bug re assets/ - it will randomly want to find them with or
    // without the assets/ prefix! >:(
    final file = _fileForType(sound);
    if (file == null) return false;
    print("Preload begun for $file");
    try {
      await player.setAsset('audio/$file');
      print("Preloaded $file");
      return true;
    } catch (e) {
      await player.setAsset('assets/audio/$file');
      print("Preloaded $file");
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
    switch (sound) {
      case Sounds.highlighted:
        return null;
      case Sounds.played:
        return "card-switch.wav";
      case Sounds.failed:
        return "card-fail.mp3";
      case Sounds.polka:
        return "waltz-polka.mp3";
      case Sounds.winMusic:
        return _winSong;
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
