import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<String> allSongs = [
    'Night Changes',
    'Shape of You',
    'Let Me Love You',
    'Believer',
    'Sugar',
    'Counting Stars',
    'Stay With Me',
  ];
  List<String> filteredSongs = [];

  @override
  void initState() {
    super.initState();
    filteredSongs = allSongs;
    _searchController.addListener(_filterSongs);
  }

  void _filterSongs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredSongs = allSongs
          .where((song) => song.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delulufy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                hintText: 'Search songs...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredSongs.length,
                itemBuilder: (context, index) {
                  final song = filteredSongs[index];
                  return ListTile(
                    title: Text(
                      song,
                      style: const TextStyle(color: Colors.white),
                    ),
                    leading: const Icon(Icons.music_note, color: Colors.white),
                    onTap: () {
                      // 🔜 Future: play YouTube audio here
                    },
                  );
                },
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Made with ❤️ by Manasvi',
                  style: const TextStyle(
                    color: Color.fromARGB(128, 255, 255, 255),
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
