import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/components/widgets/index.dart';

class CreateCircleButton extends StatelessWidget {
  const CreateCircleButton({Key? key, this.onPressed}) : super(key: key);
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return ThemedRaisedButton(
      height: 52,
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(t.createCircle),
          const SizedBox(
            width: 8,
          ),
          const Icon(LucideIcons.plus)
        ],
      ),
    );
  }
}
