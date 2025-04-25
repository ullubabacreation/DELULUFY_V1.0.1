import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:convert';

class AudioPlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String thumbnail;

  const AudioPlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
    required this.thumbnail,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isLiked = false;
  bool isPlaying = false;
  bool isLooping = false;
  bool isAutoplay = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _wavePhase = 0;
  int _errorCount = 0;
  bool isShuffled = false;

  late AnimationController _waveController;
  List<Map<String, String>> _playlist = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() {
        setState(() {
          _wavePhase += 0.2;
        });
      })
      ..repeat();

    _loadPlaylist().then((_) {
      _currentIndex = _playlist.indexWhere((item) => item['id'] == widget.videoId);
      if (_currentIndex == -1) {
        _playlist.insert(0, {
          'id': widget.videoId,
          'title': widget.title,
          'thumbnail': widget.thumbnail,
        });
        _currentIndex = 0;
      }
      _checkIfLiked();
      _setupAudio();
    });
  }

  Future<void> _loadPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('likedSongs') ?? [];
    setState(() {
      _playlist = saved.map((s) => Map<String, String>.from(json.decode(s))).toList();
    });
  }

  // ignore: unused_element
  Future<void> _savePlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('likedSongs', _playlist.map((e) => json.encode(e)).toList());
  }

  Future<void> _checkIfLiked() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('likedSongs') ?? [];
    final ids = saved.map((s) => json.decode(s)['id']).toList();
    setState(() => isLiked = ids.contains(widget.videoId));
  }

  Future<void> _toggleLike() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('likedSongs') ?? [];

    final likedMap = {
      'id': widget.videoId,
      'title': widget.title,
      'thumbnail': widget.thumbnail,
    };

    final updated = List<String>.from(saved);
    final index = saved.indexWhere((s) => json.decode(s)['id'] == widget.videoId);

    if (index != -1) {
      updated.removeAt(index);
    } else {
      updated.add(json.encode(likedMap));
    }

    await prefs.setStringList('likedSongs', updated);
    setState(() => isLiked = !isLiked);
    await _loadPlaylist();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isLiked ? 'Added to Playlist ❤️' : 'Removed from Playlist 💔',
          style: const TextStyle(fontFamily: 'UbuntuMono'),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _setupAudio() async {
    try {
      await _audioPlayer.stop();
      final yt = YoutubeExplode();
      final manifest = await yt.videos.streamsClient.getManifest(_playlist[_currentIndex]['id']!);
      final audioStream = manifest.audioOnly.toList()..sort((a, b) => b.bitrate.compareTo(a.bitrate));
      final audioUrl = audioStream.first.url.toString();

      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.setLoopMode(isLooping ? LoopMode.one : LoopMode.off);

      _audioPlayer.playerStateStream.listen((state) {
        setState(() => isPlaying = state.playing);
      });

      _audioPlayer.durationStream.listen((d) {
        setState(() => _duration = d ?? Duration.zero);
      });

      _audioPlayer.positionStream.listen((p) {
        setState(() => _position = p);
      });

      yt.close();

      if (isAutoplay) {
        await _audioPlayer.play();
        _waveController.repeat();
      }
    } catch (e) {
      _errorCount++;
      _showErrorSnackbar();
    }
  }

  void _togglePlayback() {
    if (isPlaying) {
      _audioPlayer.pause();
      _waveController.stop();
    } else {
      _audioPlayer.play();
      _waveController.repeat();
    }
  }

  void _toggleLoop() {
    setState(() => isLooping = !isLooping);
    _audioPlayer.setLoopMode(isLooping ? LoopMode.one : LoopMode.off);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isLooping ? 'Loop Enabled 🔁' : 'Loop Disabled ❌',
          style: const TextStyle(fontFamily: 'UbuntuMono'),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleAutoplay() {
    setState(() => isAutoplay = !isAutoplay);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAutoplay ? 'Autoplay Enabled ▶️' : 'Autoplay Disabled ❌',
          style: const TextStyle(fontFamily: 'UbuntuMono'),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shufflePlaylist() {
    setState(() {
      isShuffled = !isShuffled;
      if (isShuffled) {
        _playlist.shuffle();
      } else {
        _playlist.sort((a, b) => a['title']!.compareTo(b['title']!));
      }
    });
  }

  void _playNext() {
    if (_currentIndex < _playlist.length - 1) {
      setState(() => _currentIndex++);
      _setupAudio();
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _setupAudio();
    }
  }

  void _showErrorSnackbar() {
    if (_errorCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Launching... Please wait 2 mins. If nothing plays, try restarting the app.',
            style: TextStyle(fontFamily: 'UbuntuMono'),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.black,
          title: const Text('⚠️ Playback Failed', style: TextStyle(color: Colors.white, fontFamily: 'UbuntuMono')),
          content: const Text('Could not play the song. Try restarting the app.', style: TextStyle(color: Colors.white70, fontFamily: 'UbuntuMono')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.purpleAccent, fontFamily: 'UbuntuMono')),
            )
          ],
        ),
      );
    }
  }

  Widget _waveform() => CustomPaint(size: const Size(double.infinity, 80), painter: SyncedWaveformPainter(_wavePhase));
  Widget _equalizer() => CustomPaint(size: const Size(double.infinity, 40), painter: RainbowEqualizerPainter(_wavePhase));
  String _formatDuration(Duration d) => "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(d.inSeconds.remainder(60)).toString().padLeft(2, '0')}";

  @override
  void dispose() {
    _audioPlayer.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _playlist[_currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                const Spacer(),
                IconButton(
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.redAccent : Colors.white),
                  onPressed: _toggleLike,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(currentSong['thumbnail']!, width: 220, height: 220, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            Text(currentSong['title']!, style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'UbuntuMono'), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            _waveform(),
            const SizedBox(height: 20),
            Slider(
              activeColor: Colors.cyanAccent,
              inactiveColor: Colors.white24,
              min: 0,
              max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds.clamp(0, _duration.inSeconds).toDouble(),
              onChanged: (value) => _audioPlayer.seek(Duration(seconds: value.toInt())),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position), style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'UbuntuMono')),
                  Text(_formatDuration(_duration), style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'UbuntuMono')),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.skip_previous, color: Colors.cyan, size: 28), onPressed: _playPrevious),
                const SizedBox(width: 10),
                IconButton(icon: Icon(isLooping ? Icons.repeat_on : Icons.repeat, color: Colors.cyan, size: 28), onPressed: _toggleLoop),
                const SizedBox(width: 10),
                IconButton(icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: Colors.cyan, size: 50), onPressed: _togglePlayback),
                const SizedBox(width: 10),
                Column(
                  children: [
                    IconButton(icon: Icon(isAutoplay ? Icons.play_arrow_rounded : Icons.block, color: Colors.cyan, size: 28), onPressed: _toggleAutoplay),
                    const Text("Auto", style: TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'UbuntuMono')),
                  ],
                ),
                const SizedBox(width: 10),
                IconButton(icon: const Icon(Icons.skip_next, color: Colors.cyan, size: 28), onPressed: _playNext),
                IconButton(icon: Icon(isShuffled ? Icons.shuffle_on : Icons.shuffle, color: Colors.cyanAccent), onPressed: _shufflePlaylist),
              ],
            ),
            const SizedBox(height: 20),
            _equalizer(),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _playlist.length,
                itemBuilder: (context, index) {
                  final song = _playlist[index];
                  final isCurrent = index == _currentIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _currentIndex = index);
                      _setupAudio();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: isCurrent ? Colors.cyanAccent : Colors.transparent, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.network(song['thumbnail']!, width: 50, height: 50),
                    ),
                  );
                },
              ),
            ),
            const Text('🔊 Powered Delulufy with ❤️ by Manasvi', style: TextStyle(color: Color.fromARGB(127, 255, 255, 255), fontSize: 14, fontFamily: 'UbuntuMono')),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class SyncedWaveformPainter extends CustomPainter {
  final double phase;
  SyncedWaveformPainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [const Color.fromARGB(255, 255, 1, 1), Colors.blueAccent, Colors.cyanAccent, const Color.fromARGB(255, 2, 255, 19)];
    final double baseY = size.height / 2;

    for (int wave = 0; wave < 3; wave++) {
      final paint = Paint()
        ..color = colors[wave % colors.length].withAlpha((0.7 * 255).toInt())
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;

      final path = Path();
      for (double x = 0; x < size.width; x++) {
        final freq = 20 + wave * 5;
        final amp = 10 + wave * 4;
        final y = sin((x / freq) + phase + wave) * amp + baseY;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SyncedWaveformPainter oldDelegate) => oldDelegate.phase != phase;
}

class RainbowEqualizerPainter extends CustomPainter {
  final double phase;
  RainbowEqualizerPainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = 30;
    final barWidth = size.width / barCount;
    final rainbowColors = [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.cyan, Colors.blue, Colors.purple];

    for (int i = 0; i < barCount; i++) {
      final color = rainbowColors[i % rainbowColors.length];
      final paint = Paint()..color = color;
      final height = 10 + sin(phase + i / 2) * 30;
      final x = i * barWidth;
      canvas.drawRect(Rect.fromLTWH(x, size.height - height, barWidth - 2, height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant RainbowEqualizerPainter oldDelegate) => true;
}
