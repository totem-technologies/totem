import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/app/index.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleSessionEndedPage extends StatelessWidget {
  const CircleSessionEndedPage(
      {super.key,
      this.removed = false,
      this.circle,
      this.sessionState = SessionState.complete});
  final bool removed;
  final Circle? circle;
  final SessionState sessionState;

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _circleHeader(context),
            Expanded(
              child: Center(
                  child: (removed)
                      ? _circleUserRemoved(context)
                      : _sessionDisconnected(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleHeader(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    return Padding(
      padding: EdgeInsets.only(top: themeData.titleTopPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: themeData.pageHorizontalPadding),
          if (circle != null) ...[
            CircleImage(
              circle: circle!,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              circle?.name ?? t.circle,
              style: textStyles.displayMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _circleUserRemoved(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textStyles;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(t.sessionUserRemoved, style: textStyles.displaySmall),
        const SizedBox(height: 20),
        ThemedRaisedButton(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.logOut),
              const SizedBox(width: 10),
              Text(t.exit),
            ],
          ),
          onPressed: () async {
            context.pop();
          },
        ),
        _donateAndFeedbackButtons(),
      ],
    );
  }

  Widget _sessionDisconnected(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textStyles;
    // then prompt the user about leaving
    if (sessionState == SessionState.complete ||
        sessionState == SessionState.cancelled) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
              sessionState == SessionState.complete
                  ? t.sessionStateComplete
                  : t.sessionStateCancelled,
              style: textStyles.displaySmall),
          const SizedBox(height: 20),
          ThemedRaisedButton(
            label: t.returnHome,
            onPressed: () async {
              context.pop();
            },
          ),
          if (sessionState == SessionState.complete && circle != null)
            _donateAndFeedbackButtons(),
        ],
      );
    }
    return Container();
  }

  Widget _donateAndFeedbackButtons() {
    return const Padding(
      padding: EdgeInsets.only(top: 60),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        // DonateButton(),
        // SizedBox(width: 60),
        UserFeedbackButton(),
      ]),
    );
  }
}
