import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioManager extends ChangeNotifier {
  static final AudioManager instance = AudioManager._internal();
  factory AudioManager() => instance;

  AudioManager._internal();

  final AudioPlayer _player = AudioPlayer();
  String? currentTitle;
  String? currentVideoId;
  String? thumbnail;

  final List<Map<String, String>> likedSongs = [];

  Future<void> setSong({
    required String videoId,
    required String title,
    required String thumbnail,
  }) async {
    currentVideoId = videoId;
    currentTitle = title;
    this.thumbnail = thumbnail;

    final url = 'https://www.youtube.com/watch?v=$videoId';
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      debugPrint('❌ Failed to play audio: $e');
    }

    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    notifyListeners();
  }

  void addToLiked(String videoId, String title, String thumbnail) {
    likedSongs.add({
      'videoId': videoId,
      'title': title,
      'thumbnail': thumbnail,
    });
    notifyListeners();
  }

  Future<void> loadLikedSongs() async {
    likedSongs.clear();
    notifyListeners();
  }
}
