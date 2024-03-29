import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/auth_user.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class GuidelineScreen extends ConsumerWidget {
  const GuidelineScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textTheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final authService = ref.watch(authServiceProvider);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 35,
                      right: 35,
                      top: 40,
                      bottom: 120 + bottomPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.guidelinesHeader,
                        style: textStyles.displayLarge,
                        textAlign: TextAlign.center,
                      ),
                      const Center(child: ContentDivider()),
                      const SizedBox(height: 24),
                      Text(
                        'Last Time Updated: May 12,2021',
                        style: textStyles.bodyLarge!.merge(
                            const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        t.guidelines,
                        style: textStyles.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _bottomControls(context, authService),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomControls(BuildContext context, AuthService authService) {
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textTheme;
    final themeColors = Theme.of(context).themeColors;
    final AuthUser? authUser = authService.currentUser();
    return BottomTrayContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
              onPressed: () {
                authService.signOut();
                Navigator.of(context).pop();
              },
              child: Row(
                children: [
                  Icon(
                    LucideIcons.arrowLeft,
                    color: themeColors.primaryText,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    t.back,
                    style: textStyles.labelLarge,
                  ),
                ],
              )),
          ThemedRaisedButton(
            label: t.acceptGuidelines,
            onPressed: () {
              if (authUser != null && authUser.isNewUser) {
                context.pushReplacementNamed(AppRoutes.loginOnboarding);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
