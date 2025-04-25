import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LikedSongsScreen extends StatefulWidget {
  const LikedSongsScreen({super.key});

  @override
  State<LikedSongsScreen> createState() => _LikedSongsScreenState();
}

class _LikedSongsScreenState extends State<LikedSongsScreen> {
  List<String> likedSongs = [];

  @override
  void initState() {
    super.initState();
    _loadLikedSongs();
  }

  Future<void> _loadLikedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final songs = prefs.getStringList('liked_songs') ?? [];
    if (!mounted) return;
    setState(() {
      likedSongs = songs;
    });
  }

  Future<void> _removeSong(int index) async {
    final prefs = await SharedPreferences.getInstance();
    likedSongs.removeAt(index);
    await prefs.setStringList('liked_songs', likedSongs);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('❤️ Liked Songs'),
      ),
      body: likedSongs.isEmpty
          ? const Center(
              child: Text("No liked songs yet."),
            )
          : ListView.builder(
              itemCount: likedSongs.length,
              itemBuilder: (context, index) {
                final song = likedSongs[index].split('|');
                final title = song[0];
                final thumbnail = song.length > 1 ? song[1] : '';

                return ListTile(
                  leading: thumbnail.isNotEmpty
                      ? Image.network(thumbnail, width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.music_note),
                  title: Text(title),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeSong(index),
                  ),
                );
              },
            ),
    );
  }
}
