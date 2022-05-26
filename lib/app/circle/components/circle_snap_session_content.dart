import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:totem/app/circle/components/circle_live_video_session.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

final audioLevelStream = StreamProvider.autoDispose<AudioLevelData>((ref) {
  final audioLevel = AudioLevel();
  return audioLevel.stream;
});

class CircleSnapSessionContent extends ConsumerStatefulWidget {
  const CircleSnapSessionContent({
    Key? key,
    required this.circle,
  }) : super(key: key);
  final SnapCircle circle;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CircleSnapSessionContentState();
}

class _CircleSnapSessionContentState
    extends ConsumerState<CircleSnapSessionContent>
    with AfterLayoutMixin<CircleSnapSessionContent> {
  // String? _sessionUserId;

  late bool _validSession;
  bool _retry = false;
  @override
  void initState() {
    _validSession = true; //widget.circle.activeSession != null;
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
    ref.watch(audioLevelStream);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: WillPopScope(
          onWillPop: () async {
            return await _exitPrompt(context);
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: (sessionProvider.state == SessionState.live)
                ? const CircleLiveVideoSession()
                : Stack(
                    children: [
                      SafeArea(
                        top: true,
                        bottom: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (sessionProvider.state !=
                                          SessionState.live &&
                                      sessionProvider.state !=
                                          SessionState.complete &&
                                      sessionProvider.state !=
                                          SessionState.ending)
                                    SubPageHeader(
                                      title: widget.circle.name,
                                      onClose: (commProvider.state !=
                                              CommunicationState.disconnecting)
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
                                  if (sessionProvider.state ==
                                          SessionState.live ||
                                      sessionProvider.state ==
                                          SessionState.complete ||
                                      sessionProvider.state ==
                                          SessionState.ending)
                                    _altHeader(context, commProvider),
                                  if (sessionProvider.state ==
                                          SessionState.waiting &&
                                      widget.circle.description != null &&
                                      widget.circle.description!.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: Theme.of(context)
                                              .pageHorizontalPadding,
                                          vertical: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            t.circleDescription,
                                            style: textStyles.headline3,
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          //Text(widget.circle.description!),
                                          TrimmedText(
                                            widget.circle.description!,
                                            trimLines: 3,
                                            style: textStyles.bodyText1,
                                            more: Row(
                                              children: [
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      alignment:
                                                          Alignment.centerLeft),
                                                  onPressed: () async {
                                                    await CircleSessionInfoPage
                                                        .showDialog(context);
                                                  },
                                                  child: Text(t.moreInfo),
                                                )
                                              ],
                                            ),
                                          ),
                                          Divider(
                                            height: 48,
                                            thickness: 1,
                                            color: themeColors.divider,
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (sessionProvider.state !=
                                      SessionState.live)
                                    Expanded(
                                      child: _validSession
                                          ? AnimatedSwitcher(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              child: _sessionContent(
                                                  context,
                                                  commProvider,
                                                  sessionProvider),
                                            )
                                          : _invalidSession(context),
                                    ),
                                ],
                              ),
                            ),
                            if (commProvider.state ==
                                    CommunicationState.active &&
                                sessionProvider.state != SessionState.live)
                              const CircleSessionControls(),
                          ],
                        ),
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
    return Padding(
      padding: EdgeInsets.only(top: themeData.titleTopPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: themeData.pageHorizontalPadding),
          Expanded(
            child: Text(
              widget.circle.name,
              style: textStyles.headline2,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
      ),
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
        sessionProvider.state == SessionState.ending ||
        sessionProvider.state == SessionState.cancelling) {
      return _circleStartingOrEnding(context, sessionProvider.state);
    }
    switch (commProvider.state) {
      case CommunicationState.failed:
        return _errorSession(context);
      case CommunicationState.joining:
        return _joiningSession(context);
      case CommunicationState.active:
      case CommunicationState.networkConnectivity:
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
    return Container();
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
            Text(
              ErrorCodeTranslation.get(
                  context, commProvider.lastError ?? "unknown"),
              textAlign: TextAlign.center,
            ),
            if (commProvider.lastError ==
                CommunicationErrors.noMicrophonePermission) ...[
              const SizedBox(height: 30),
              Text(
                t.errorEnablePermissions,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Center(
                child: ThemedRaisedButton(
                  label: _retry ? t.errorRetryStart : t.errorDeviceSettings,
                  onPressed: () {
                    // trigger app settings
                    if (!_retry) {
                      openAppSettings();
                      setState(() => _retry = true);
                    } else {
                      setState(() => _retry = false);
                      // user says they have reset, retry
                      _joinSession();
                    }
                  },
                ),
              ),
            ],
            const SizedBox(
              height: 50,
            ),
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
      await commProvider.leaveSession(requested: true);
    } else {
      await commProvider.endSession();
    }
    if (!complete) {
      // leave page
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // join the session once the page is ready
    _joinSession();
  }

  void _joinSession() {
    Size fullscreenSize = const Size(600, 600);
//    if (widget.circle != null) {
    final provider = ref.read(communicationsProvider);
    provider.joinSession(
        session: SnapSession.fromJson({}, circle: widget.circle),
        enableVideo: true,
        handler: CommunicationHandler(
          joinedCircle: (String sessionId, String sessionUserId) {
            debugPrint("joined circle as: $sessionUserId");
          },
          leaveCircle: () {
            // prompt?
            Future.delayed(const Duration(milliseconds: 0), () {
              // Navigator.of(context).pop();
            });
          },
        ),
        fullScreenSize: fullscreenSize);
  }
//  }
}
