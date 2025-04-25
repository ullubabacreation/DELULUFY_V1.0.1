import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeAPI {
  static final YoutubeExplode _yt = YoutubeExplode();

  static Future<List<Map<String, String>>> search(String query) async {
    final searchResults = await _yt.search.search(query);
    return searchResults.take(10).map((video) {
      return {
        'videoId': video.id.value,
        'title': video.title,
        'thumbnail': video.thumbnails.highResUrl,
      };
    }).toList();
  }
}
