import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_controller.g.dart';

@riverpod
class LocaleController extends _$LocaleController {
  static const _localeKey = 'locale';

  @override
  String build() {
    return 'en'; // Default locale
  }

  Future<void> toggleLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale);
    state = locale;
  }

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale != null) {
      state = savedLocale;
    }
  }
}