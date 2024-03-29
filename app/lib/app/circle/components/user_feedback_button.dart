import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/app_theme_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class UserFeedbackButton extends StatelessWidget {
  const UserFeedbackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return ThemedRaisedButton(
      backgroundColor: Theme.of(context).themeColors.secondaryButtonBackground,
      onPressed: () {
        _launchUserFeedback();
      },
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(LucideIcons.messageCircle),
          const SizedBox(
            width: 8,
          ),
          Text(t.feedback),
        ],
      ),
    );
  }

  void _launchUserFeedback() async {
    await launchUrl(Uri.parse(DataUrls.userFeedback));
  }
}
