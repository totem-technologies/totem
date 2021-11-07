import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/components/circle_session_content.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';
import 'components/circle_session_controls.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final activeSessionProvider =
    ChangeNotifierProvider.autoDispose<ActiveSession>((ref) {
  final repo = ref.read(repositoryProvider);
  ref.onDispose(() {
    repo.clearActiveSession();
  });
  return repo.activeSession!;
});

class CircleSessionPage extends ConsumerWidget {
  const CircleSessionPage({Key? key, required this.activeSession})
      : super(key: key);
  final ActiveSession activeSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;
    final textStyles = themeData.textStyles;
    final t = AppLocalizations.of(context)!;
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: WillPopScope(
          onWillPop: () async {
            return await _exitPrompt(context);
          },
          child: SafeArea(
            top: true,
            bottom: false,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SubPageHeader(
                      title: activeSession.session.circle.name,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                            left: themeData.pageHorizontalPadding,
                            right: themeData.pageHorizontalPadding,
                            top: 12,
                            bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (activeSession.session.circle.description !=
                                    null &&
                                activeSession.session.circle.description!
                                    .isNotEmpty) ...[
                              Text(
                                t.circleDescription,
                                style: textStyles.headline3,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(activeSession.session.circle.description!),
                              Divider(
                                height: 48,
                                thickness: 1,
                                color: themeColors.divider,
                              ),
                            ],
                            const CircleSessionContent(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: CircleSessionControls(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _exitPrompt(BuildContext context) async {
    return true;
  }
}
