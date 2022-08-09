import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';
import 'package:url_launcher/url_launcher.dart';

class CircleSessionEndedPage extends StatelessWidget {
  const CircleSessionEndedPage(
      {Key? key,
      this.removed = false,
      this.circle,
      this.sessionState = SessionState.complete})
      : super(key: key);
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: themeData.pageHorizontalPadding),
          Expanded(
            child: Text(
              circle?.name ?? t.circle,
              style: textStyles.headline2,
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
        Text(t.sessionUserRemoved, style: textStyles.headline3),
        const SizedBox(height: 20),
        ThemedRaisedButton(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.exit_to_app),
              const SizedBox(width: 10),
              Text(t.exit),
            ],
          ),
          onPressed: () async {
            context.pop();
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 60),
          child: ThemedRaisedButton(
            backgroundColor:
                Theme.of(context).themeColors.secondaryButtonBackground,
            label: t.sessionFeedbackRequest,
            textStyle: textStyles.button!.merge(const TextStyle(fontSize: 14)),
            onPressed: () async {
              _launchUserFeedback();
            },
          ),
        )
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
              style: textStyles.headline3),
          const SizedBox(height: 20),
          ThemedRaisedButton(
            label: t.leaveSession,
            onPressed: () async {
              context.pop();
            },
          ),
          if (sessionState == SessionState.complete && circle != null)
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: ThemedRaisedButton(
                backgroundColor:
                    Theme.of(context).themeColors.secondaryButtonBackground,
                label: t.sessionFeedbackRequest,
                textStyle:
                    textStyles.button!.merge(const TextStyle(fontSize: 14)),
                onPressed: () async {
                  _launchUserFeedback();
                },
              ),
            )
        ],
      );
    }
    return Container();
  }

  void _launchUserFeedback() async {
    await launchUrl(Uri.parse(DataUrls.userFeedback));
  }
}
