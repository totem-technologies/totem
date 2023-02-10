import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/components/index.dart';
import 'package:totem/theme/index.dart';

class CircleErrorLoading extends StatelessWidget {
  const CircleErrorLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 250),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(LucideIcons.alertCircle,
                size: 40, color: Theme.of(context).themeColors.error),
            const SizedBox(
              height: 20,
            ),
            Text(
              AppLocalizations.of(context)!.errorLoadingCircle,
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ThemedRaisedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              label: AppLocalizations.of(context)!.ok,
            ),
          ],
        ),
      ),
    );
  }
}
