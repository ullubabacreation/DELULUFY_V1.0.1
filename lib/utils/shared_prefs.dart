import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const _accessGrantedKey = 'access_granted';
  static const _generatedKey = 'generated_key';

  // Save access granted flag
  static Future<void> saveAccessGranted(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_accessGrantedKey, granted);
  }

  // Get access granted flag
  static Future<bool> getAccessGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_accessGrantedKey) ?? false;
  }

  // Save generated access key
  static Future<void> saveGeneratedKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_generatedKey, key);
  }

  // Get saved access key
  static Future<String?> getGeneratedKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_generatedKey);
  }

  // Optional: Clear all saved data (for reset/debug)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessGrantedKey);
    await prefs.remove(_generatedKey);
  }
}
