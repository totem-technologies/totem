import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/index.dart';

class CreateCircleButton extends StatelessWidget {
  const CreateCircleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return ThemedRaisedButton(
      elevation: 5,
      height: 52,
      onPressed: () {
        // build new circle
        context.goNamed(AppRoutes.circleCreate);
      },
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
