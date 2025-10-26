import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final languageControllerProvider = StateNotifierProvider<LanguageController, String>((ref) {
  return LanguageController();
});

class LanguageController extends StateNotifier<String> {
  LanguageController() : super('tr') {
    _loadLanguage();
  }

  static const _key = 'selectedLanguage';

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key) ?? 'tr';
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    state = languageCode;
    await prefs.setString(_key, languageCode);
  }

  String get currentLanguage => state;
  bool get isTurkish => state == 'tr';
  bool get isEnglish => state == 'en';
}
