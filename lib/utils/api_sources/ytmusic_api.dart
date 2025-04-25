import 'dart:convert';
import 'package:http/http.dart' as http;

class YtMusicAPI {
  static const String baseUrl = 'https://deluluserver-v1.onrender.com';

  /// Search songs via backend using ytmusicapi
  static Future<List<Map<String, String>>> search(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search?query=$query'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);

      return data
          .where((item) =>
              item['videoId'] != null &&
              item['title'] != null &&
              item['thumbnails'] != null &&
              (item['thumbnails'] as List).isNotEmpty)
          .map<Map<String, String>>((item) => {
                'videoId': item['videoId'].toString(),
                'title': item['title'].toString(),
                'thumbnail': item['thumbnails'].last['url'].toString(), // Best quality thumbnail
              })
          .toList();
    } else {
      throw Exception('Failed to search songs: ${response.body}');
    }
  }

  /// Get audio URL from backend by videoId
  static Future<String> getAudioUrl(String videoId) async {
    final response = await http.get(Uri.parse('$baseUrl/audio/$videoId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['audioUrl'];
    } else {
      throw Exception('Failed to fetch audio URL: ${response.body}');
    }
  }
}
