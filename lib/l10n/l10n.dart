import 'package:flutter/material.dart';
import 'app_localizations.dart';

class L10n {
  static const all = [
    Locale('en'), // English
    Locale('tr'), // Turkish
  ];

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'tr':
        return 'Türkçe';
      default:
        return languageCode;
    }
  }

  static AppLocalizations of(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    assert(l10n != null, 'AppLocalizations not found');
    return l10n!;
  }
}