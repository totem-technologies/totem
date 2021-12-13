import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

import 'circle_session_content.dart';
import 'circle_session_controls.dart';

class CircleSnapSessionContent extends ConsumerStatefulWidget {
  const CircleSnapSessionContent({
    Key? key,
    required this.circle,
    this.sessionImage,
  }) : super(key: key);
  final SnapCircle circle;
  final String? sessionImage;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CircleSnapSessionContentState();
}

class _CircleSnapSessionContentState
    extends ConsumerState<CircleSnapSessionContent>
    with AfterLayoutMixin<CircleSnapSessionContent> {
  // String? _sessionUserId;

  late bool _validSession;

  @override
  void initState() {
    _validSession = widget.circle.activeSession != null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;
    final textStyles = themeData.textStyles;
    final t = AppLocalizations.of(context)!;
    final commProvider = ref.watch(communicationsProvider);
    final sessionProvider = ref.watch(activeSessionProvider);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (sessionProvider.state != SessionState.live &&
                    sessionProvider.state != SessionState.complete)
                  SubPageHeader(
                    title: widget.circle.name,
                    onClose:
                        (commProvider.state != CommunicationState.disconnecting)
                            ? () async {
                                if (commProvider.state !=
                                    CommunicationState.active) {
                                  Navigator.of(context).pop();
                                } else {
                                  await _exitPrompt(context);
                                }
                              }
                            : null,
                  ),
                if (sessionProvider.state == SessionState.live ||
                    sessionProvider.state == SessionState.complete ||
                    sessionProvider.state == SessionState.ending)
                  _altHeader(context, commProvider),
                if (sessionProvider.state == SessionState.waiting &&
                    widget.circle.description != null &&
                    widget.circle.description!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Theme.of(context).pageHorizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          t.circleDescription,
                          style: textStyles.headline3,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(widget.circle.description!),
                        Divider(
                          height: 48,
                          thickness: 1,
                          color: themeColors.divider,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _validSession
                      ? AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _sessionContent(
                              context, commProvider, sessionProvider),
                        )
                      : _invalidSession(context),
                ),
                if (commProvider.state == CommunicationState.active)
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

  Widget _altHeader(BuildContext context, CommunicationProvider commProvider) {
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;
    final textStyles = themeData.textStyles;
    return Row(
      children: [
        SizedBox(width: themeData.pageHorizontalPadding),
        Expanded(
          child: Text(widget.circle.name, style: textStyles.headline1),
        ),
        IconButton(
          onPressed: (commProvider.state != CommunicationState.disconnecting)
              ? () async {
                  if (commProvider.state != CommunicationState.active) {
                    Navigator.of(context).pop();
                  } else {
                    await _exitPrompt(context);
                  }
                }
              : null,
          icon: Icon(
            Icons.close,
            color: themeColors.primaryText,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _circleStartingOrEnding(BuildContext context, SessionState state) {
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textStyles;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            state == SessionState.starting ? t.circleStarting : t.circleEnding,
            style: textStyles.headline3,
          ),
          const SizedBox(
            height: 20,
          ),
          const BusyIndicator(),
        ],
      ),
    );
  }

  Widget _sessionContent(BuildContext context,
      CommunicationProvider commProvider, ActiveSession sessionProvider) {
    if (sessionProvider.state == SessionState.starting ||
        sessionProvider.state == SessionState.ending) {
      return _circleStartingOrEnding(context, sessionProvider.state);
    }
    switch (commProvider.state) {
      case CommunicationState.failed:
        return _errorSession(context);
      case CommunicationState.joining:
        return _joiningSession(context);
      case CommunicationState.active:
        return const CircleSessionContent();
      case CommunicationState.disconnecting:
        return _sessionDisconnecting(context);
      case CommunicationState.disconnected:
        return _sessionDisconnected(context, sessionProvider);
    }
  }

  Widget _sessionDisconnecting(BuildContext context) {
    return const Center(child: BusyIndicator());
  }

  Widget _sessionDisconnected(
      BuildContext context, ActiveSession sessionProvider) {
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textStyles;
    final repo = ref.read(repositoryProvider);
    final commProvider = ref.read(communicationsProvider);
    // then prompt the user about leaving
    if (sessionProvider.state == SessionState.complete ||
        sessionProvider.state == SessionState.cancelled) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              repo.activeSession!.state == SessionState.complete
                  ? t.sessionStateComplete
                  : t.sessionStateCancelled,
              style: textStyles.headline3),
          const SizedBox(height: 20),
          ThemedRaisedButton(
            label: t.leaveSession,
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            t.errorJoinSession,
            style: textStyles.headline3,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            ErrorCodeTranslation.get(
                context, commProvider.lastError ?? "unknown"),
          ),
        ],
      ),
    );
  }

  Widget _errorSession(BuildContext context) {
    final commProvider = ref.read(communicationsProvider);
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textStyles;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Theme.of(context).pageHorizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              t.errorJoinSession,
              style: textStyles.headline3,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(ErrorCodeTranslation.get(
                context, commProvider.lastError ?? "unknown")),
          ],
        ),
      ),
    );
  }

  Widget _joiningSession(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textStyles;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            t.joiningCircle,
            style: textStyles.headline3,
          ),
          const SizedBox(
            height: 20,
          ),
          const BusyIndicator(),
        ],
      ),
    );
  }

  Future<bool> _exitPrompt(BuildContext context) async {
    final repo = ref.read(repositoryProvider);
    final authUser = ref.read(authServiceProvider).currentUser()!;
    // then prompt the user about leaving
    final commProvider = ref.read(communicationsProvider);
    if (repo.activeSession != null) {
      final role = repo.activeSession!.participantRole(authUser.uid);
      if (commProvider.state == CommunicationState.active) {
        // prompt
        FocusScope.of(context).unfocus();
        final t = AppLocalizations.of(context)!;
        // set up the AlertDialog
        final actions = [
          TextButton(
            child: Text(t.leaveSession),
            onPressed: () {
              Navigator.of(context).pop("leave");
            },
          ),
          TextButton(
            child: Text(t.cancel),
            onPressed: () {
              Navigator.of(context).pop("cancel");
            },
          ),
        ];
        if (role == Role.keeper) {
          actions.insert(
            0,
            TextButton(
              child: Text(t.endSession),
              onPressed: () {
                Navigator.of(context).pop("end");
              },
            ),
          );
        }

        AlertDialog alert = AlertDialog(
          title: Text(
              role == Role.keeper ? t.endSessionPrompt : t.leaveSessionPrompt),
          content: Text(role == Role.keeper
              ? t.endSessionPromptMessage
              : t.leaveSessionPromptMessage),
          actions: actions,
        );
        // show the dialog
        final result = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return alert;
          },
        );
        if (result != "cancel") {
          await completeSession(result == "end");
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Widget _invalidSession(BuildContext context) {
    // the active session doesn't exist, this is likely
    // a completed session
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textStyles;
    return Column(
      children: [
        Text(
          t.errorSessionInvalid,
          style: textStyles.headline3,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> completeSession(bool complete) async {
//    final repo = ref.read(repositoryProvider);
    final commProvider = ref.read(communicationsProvider);
    if (!complete) {
      await commProvider.leaveSession();
    } else {
      await commProvider.endSession();
    }
    if (!complete) {
      // leave page
      Navigator.of(context).pop();
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // join the session once the page is ready
    if (widget.circle.activeSession != null) {
      final provider = ref.read(communicationsProvider);
      provider.joinSession(
        session: widget.circle.activeSession!,
        sessionImage: widget.sessionImage,
        handler: CommunicationHandler(
            joinedCircle: (String sessionId, String sessionUserId) {
          debugPrint("joined circle as: " + sessionUserId);
        }, leaveCircle: () {
          // prompt?
          Future.delayed(const Duration(milliseconds: 0), () {
            // Navigator.of(context).pop();
          });
        }),
      );
    }
  }
}
