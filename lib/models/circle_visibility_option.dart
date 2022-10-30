import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CircleVisibilityOption {
  final String name;
  final dynamic value;
  CircleVisibilityOption({required this.name, required this.value});

  String getName(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    switch (name) {
      case 'private':
        return t.private;
      case 'public':
        return t.public;
      default:
        return name;
    }
  }
}
