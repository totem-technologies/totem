import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/app_theme_styles.dart';

class DonateButton extends StatelessWidget {
  const DonateButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textStyles;
    return ThemedRaisedButton(
      backgroundColor: Theme.of(context).themeColors.secondaryButtonBackground,
      textStyle: textStyles.button!.merge(const TextStyle(fontSize: 14)),
      onPressed: () {
        _launchDonateLink();
      },
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(LucideIcons.coins),
          const SizedBox(
            width: 8,
          ),
          Text(t.donate),
        ],
      ),
    );
  }

  void _launchDonateLink() async {
    await DataUrls.launch(DataUrls.donate);
  }
}
