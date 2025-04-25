import 'dart:developer'; // ✅ Added for logging
import 'package:delulufy_v1/utils/api_sources/youtube_api.dart';
import 'package:delulufy_v1/utils/api_sources/ytmusic_api.dart';

class ApiManager {
  static final List<_ApiHandler> _apis = [
    _ApiHandler('DeluluServer V3 🎥', (query) async {
      final results = await YouTubeAPI.search(query);
      return results.map((r) => r as Map<String, dynamic>).toList();
    }, 1000),

    _ApiHandler('DeluluServer V1 🎵', (query) async {
      log('🔍 DeluluServer V1 Searching: $query'); // ✅ Replaced print
      final results = await YtMusicAPI.search(query);
      log('✅ Got ${results.length} results from YtMusicAPI'); // ✅ Replaced print
      return results.map((r) => r as Map<String, dynamic>).toList();
    }, 1000),
  ];

  static String activeApiName = 'DeluluServer V3 🎥';
  static String? _forcedApi;

  static final Map<String, int> _usageCount = {};
  static final Map<String, DateTime> _lastReset = {};

  static Future<List<Map<String, dynamic>>> search(String query) async {
    if (_forcedApi != null) {
      final api = _apis.firstWhere((a) => a.name == _forcedApi);
      _resetIfNeeded(api.name);
      final usage = _usageCount[api.name] ?? 0;
      if (usage >= api.limit) throw Exception("${api.name} quota exceeded.");
      try {
        final results = await api.searchFunction(query);
        _usageCount[api.name] = usage + 1;
        activeApiName = api.name;
        return results;
      } catch (e) {
        log('❌ Forced API failed: $e'); // ✅ Replaced print
        throw Exception("${api.name} failed.");
      }
    }

    // Try all APIs (fallback mode)
    for (final api in _apis) {
      _resetIfNeeded(api.name);
      final usage = _usageCount[api.name] ?? 0;
      if (usage >= api.limit) continue;
      try {
        final results = await api.searchFunction(query);
        _usageCount[api.name] = usage + 1;
        activeApiName = api.name;
        return results;
      } catch (e) {
        log('⚠️ ${api.name} failed: $e'); // ✅ Replaced print
        continue;
      }
    }
    throw Exception("All APIs failed or are over quota.");
  }

  static void _resetIfNeeded(String apiName) {
    if (_lastReset[apiName] == null ||
        DateTime.now().difference(_lastReset[apiName]!) > const Duration(hours: 1)) {
      _usageCount[apiName] = 0;
      _lastReset[apiName] = DateTime.now();
    }
  }

  static Future<void> setForcedAPI(String apiName) async {
    final match = _apis.firstWhere(
      (api) => api.name == apiName,
      orElse: () => throw Exception("API $apiName not found"),
    );
    _forcedApi = match.name;
    activeApiName = match.name;
  }

  static void clearForcedAPI() {
    _forcedApi = null;
  }

  static Map<String, dynamic> getUsageInfo() {
    final Map<String, dynamic> usage = {};
    for (final api in _apis) {
      final count = _usageCount[api.name] ?? 0;
      final resetIn = _lastReset[api.name] == null
          ? "1h"
          : "${60 - DateTime.now().difference(_lastReset[api.name]!).inMinutes} min";
      usage[api.name] = {
        "used": count,
        "limit": api.limit,
        "resetIn": resetIn,
      };
    }
    return usage;
  }

  static String? get forcedApi => _forcedApi;
}

class _ApiHandler {
  final String name;
  final Future<List<Map<String, dynamic>>> Function(String) searchFunction;
  final int limit;

  _ApiHandler(this.name, this.searchFunction, this.limit);
}
