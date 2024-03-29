import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/login/components/phone_register_number_header.dart';
import 'package:totem/components/widgets/themed_raised_button.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class PhoneRegisterNumberError extends ConsumerWidget {
  const PhoneRegisterNumberError({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);
    final textTheme = Theme.of(context).textTheme;
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    return Padding(
        padding: const EdgeInsets.only(left: 35, right: 35),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: Theme.of(context).maxRenderWidth),
          child: Column(
            children: [
              const PhoneRegisterNumberHeader(),
              Text(t.errorRegister,
                  style: textTheme.bodyLarge!.merge(TextStyle(
                      color: themeColors.error, fontWeight: FontWeight.bold))),
              const SizedBox(
                height: 10,
              ),
              Text(auth.lastRegisterError ?? t.errorRegisterUnknown),
              const SizedBox(
                height: 30,
              ),
              ThemedRaisedButton(
                label: t.retrySignin,
                onPressed: () {
                  auth.resetAuthError();
                },
                width: 294,
              ),
            ],
          ),
        ));
  }
}
