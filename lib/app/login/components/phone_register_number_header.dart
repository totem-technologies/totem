import 'package:flutter/material.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/services/index.dart';

class PhoneRegisterNumberHeader extends StatelessWidget {
  const PhoneRegisterNumberHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final t = Localized.of(context).t;
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(t('signup'), style: textTheme.headline1,),
        const SizedBox(height: 8),
        const Center(
          child: ContentDivider(),
        ),
        const SizedBox(height: 20),
        Text(
            t('enterPhonePrompt'),
            style: textTheme.bodyText1!.merge(const TextStyle(fontWeight: FontWeight.w600))
        ),
        const SizedBox(height: 10),
        Text(t('enterPhonePromptDetail'),),
        const SizedBox(height: 90),
      ],
    );
  }
}