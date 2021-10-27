import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Localized {
  final Locale locale;
  Localized(this.locale) {
    globalLocaleValue = locale.languageCode;
    if (locale.countryCode != null) {
      globalLocaleValue += "_" + locale.countryCode!.toUpperCase();
    } else if (locale.languageCode == "en") {
      globalLocaleValue += "_US";
    }
  }

  static String globalLocaleValue = "en_US";
  static String localizedValue(Map? values, {String defaultValue = ""}) {
    if (values == null) return defaultValue;
    if (values[globalLocaleValue] != null) return values[globalLocaleValue];
    return values["en_US"] ?? defaultValue;
  }
  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static Localized of(BuildContext context) {
    return Localizations.of<Localized>(context, Localized)!;
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<Localized> delegate = _LocalizedDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String path = 'i18n/${locale.languageCode}.json';
    String jsonString = await rootBundle.loadString(path, cache: false);
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
    });

    return true;
  }

  // This method will be called from every widget which needs a localized text
  String t(String key, [Map<String, String>? replace]) {
    String? result = _localizedStrings[key];
    if (result != null) {
      if (replace != null) {
        replace.forEach((key, value) {
          result = result!.replaceAll('%{' + key + '}', value);
        });
      }
      return result!;
    } else {
      return key;
    }
  }
}

class _LocalizedDelegate extends LocalizationsDelegate<Localized> {
  const _LocalizedDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en'].contains(locale.languageCode);
  }

  @override
  Future<Localized> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    Localized localizations = Localized(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_LocalizedDelegate old) => false;
}