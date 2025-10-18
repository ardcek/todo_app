import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    return AppLocalizations.of(context)!;
  }
}