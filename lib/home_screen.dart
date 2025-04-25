import 'package:flutter/material.dart';
import 'package:delulufy_v1/utils/api_manager.dart';
import 'package:delulufy_v1/widgets/mini_player_widget.dart';
import 'package:delulufy_v1/screens/settings_screen.dart';
import 'package:delulufy_v1/audio_manager.dart';
import 'audio_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _currentApi = ApiManager.activeApiName;

  final AudioManager _audioManager = AudioManager.instance;

  final List<String> _availableApis = [
    'Server V3🤖',
    'Server V1🎵',
    'MUSIC',
    'IN',
    'POCKET'
  ];

  @override
  void initState() {
    super.initState();
    _audioManager.loadLikedSongs().then((_) => setState(() {}));
    _audioManager.addListener(_updateMiniPlayer);
  }

  @override
  void dispose() {
    _audioManager.removeListener(_updateMiniPlayer);
    super.dispose();
  }

  void _updateMiniPlayer() => setState(() {});

  void _searchMusic(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final result = await ApiManager.search(query);
      setState(() {
        _results = result;
        _isLoading = false;
        _currentApi = ApiManager.activeApiName;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _results = [];
      });
      _showErrorDialog("Failed to fetch music. Try again later.");
    }
  }

  void _refreshSameQuery() {
    if (_controller.text.isNotEmpty) {
      _searchMusic(_controller.text);
    }
  }

  void _openAudioPlayer(Map<String, dynamic> song) async {
    await _audioManager.setSong(
      videoId: song['videoId'],
      title: song['title'],
      thumbnail: song['thumbnail'],
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AudioPlayerScreen(
          videoId: song['videoId'],
          title: song['title'],
          thumbnail: song['thumbnail'],
        ),
      ),
    );
  }

  void _changeApi(String newApi) async {
    await ApiManager.setForcedAPI(newApi);
    setState(() {
      _currentApi = ApiManager.activeApiName;
      _results.clear();
      _hasSearched = false;
    });
    if (_controller.text.isNotEmpty) _searchMusic(_controller.text);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("Error", style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final likedSongs = _audioManager.likedSongs;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Delulufy',
          style: TextStyle(fontFamily: 'UbuntuMono', color: Colors.white),
        ),
        actions: [
          DropdownButton<String>(
            value: _currentApi,
            dropdownColor: Colors.black,
            style: const TextStyle(color: Colors.white, fontFamily: 'UbuntuMono'),
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items: _availableApis.map((api) {
              return DropdownMenuItem(
                value: api,
                child: Text(api),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) _changeApi(value);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshSameQuery,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  onSubmitted: _searchMusic,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search for music...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () => _searchMusic(_controller.text),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.white)
                else if (_hasSearched && _results.isEmpty)
                  const Text("No results yet.", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          if (!_hasSearched && likedSongs.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Liked Songs", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'UbuntuMono')),
                  Icon(Icons.favorite, color: Colors.pinkAccent),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: likedSongs.length,
                itemBuilder: (context, index) {
                  final song = likedSongs[index];
                  return GestureDetector(
                    onTap: () => _openAudioPlayer(song),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              song['thumbnail'] ?? '',
                              height: 100,
                              width: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            song['title'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontFamily: 'UbuntuMono',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          if (_results.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final song = _results[index];
                  return ListTile(
                    leading: Image.network(song['thumbnail'], width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(song['title'], style: const TextStyle(color: Colors.white)),
                    onTap: () => _openAudioPlayer(song),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          const Text(
            'Made with ❤️ by Manasvi',
            style: TextStyle(fontFamily: 'UbuntuMono', fontSize: 15, color: Colors.white60),
          ),
          const SizedBox(height: 8),

          if (_audioManager.currentTitle != null)
            MiniPlayerWidget(
              title: _audioManager.currentTitle!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AudioPlayerScreen(
                      videoId: _audioManager.currentVideoId!,
                      title: _audioManager.currentTitle!,
                      thumbnail: _audioManager.thumbnail!,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
