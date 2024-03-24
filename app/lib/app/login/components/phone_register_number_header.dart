import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/theme/index.dart';

class PhoneRegisterNumberHeader extends StatelessWidget {
  const PhoneRegisterNumberHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;
    return Column(
      children: [
        SizedBox(height: Theme.of(context).titleTopPadding),
        Text(
          t.signup,
          style: textTheme.displayLarge,
        ),
        const Center(
          child: ContentDivider(),
        ),
        const SizedBox(height: 20),
        Text(t.enterPhonePrompt, style: textTheme.displaySmall),
        const SizedBox(height: 10),
        Text(
          t.enterPhonePromptDetail,
        ),
        const SizedBox(height: 90),
      ],
    );
  }
}
