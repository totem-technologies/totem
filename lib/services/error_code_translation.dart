import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorCodeTranslation {
  static String get(BuildContext context, String errorCode) {
    final t = AppLocalizations.of(context)!;
    switch (errorCode) {
      case 'errorCommunicationNoMicrophonePermission':
        return t.errorCommunicationNoMicrophonePermission;
      case 'errorCommunicationError':
        return t.errorCommunciationError;
    }
    return errorCode;
  }
}
