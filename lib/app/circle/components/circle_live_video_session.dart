import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keybinder/keybinder.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';

class CircleLiveVideoSession extends ConsumerStatefulWidget {
  const CircleLiveVideoSession({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CircleLiveVideoSessionState();
}

class _CircleLiveVideoSessionState
    extends ConsumerState<CircleLiveVideoSession> {
  final GlobalKey _sliderPass = GlobalKey();
  final GlobalKey _sliderReceive = GlobalKey();
  bool _myTurn = false;
  bool _processingRequest = false;
  @override
  void initState() {
    if (kIsWeb) {
      Keybinder.bind(Keybinding.from({LogicalKeyboardKey.space}), (pressed) {
        // handle keyboard space event
        if (!pressed && !_processingRequest) {
          // space key was released
          setState(() => _processingRequest = true);
          _handleSpace();
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    if (kIsWeb) {
      Keybinder.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeSession = ref.watch(activeSessionProvider);
    final participants = activeSession.activeParticipants;
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;
    final textStyles = themeData.textStyles;
    final totemParticipant = activeSession.totemParticipant;
    _myTurn = totemParticipant != null && totemParticipant.me;
    if (totemParticipant != null) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final isPhoneLayout = DeviceType.isPhone() ||
              (constraints.maxWidth <= Theme.of(context).portraitBreak);
          return Container(
            color: Colors.black,
            child: SafeArea(
              top: true,
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: themeData.pageHorizontalPadding),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                activeSession.circle.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textStyles.headline2!.merge(
                                  TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: themeColors.reversedText),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: participants.isNotEmpty
                                    ? AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        child: activeSession.totemReceived &&
                                                (totemParticipant.me)
                                            ? _speakerUserView(context,
                                                activeSession: activeSession,
                                                participants: participants,
                                                isPhoneLayout: isPhoneLayout)
                                            : ListenerUserLayout(
                                                constrainSpeaker:
                                                    activeSession.totemReceived,
                                                speaker: SpeakerVideoView(
                                                  onReceive: () {
                                                    final participant =
                                                        activeSession
                                                            .totemParticipant;
                                                    _receiveTurn(
                                                        context, participant!);
                                                  },
                                                  onPass: () {
                                                    final participant =
                                                        activeSession
                                                            .totemParticipant;
                                                    _endTurn(
                                                        context, participant!);
                                                  },
                                                  onSettings: () {
                                                    _showDeviceSettings();
                                                  },
                                                ),
                                                userList:
                                                    CircleLiveSessionUsers(
                                                        isPhoneLayout:
                                                            isPhoneLayout),
                                                isPhoneLayout: isPhoneLayout,
                                              ),
                                      )
                                    : Center(
                                        child: Text(
                                          t.noParticipantsActiveSession,
                                          style: textStyles.headline3,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                          if (activeSession.totemReceived &&
                              totemParticipant.me)
                            _speakerControlsView(
                              context,
                              participants: participants,
                              activeSession: activeSession,
                            ),
                          /*const Align(
                            alignment: Alignment.bottomCenter,
                            child: CircleMutedIndicator(
                              live: true,
                            ),
                          ),*/
                        ],
                      ),
                    ),
                  ),
                  const CircleSessionControls(),
                ],
              ),
            ),
          );
        },
      );
    }
    return Container();
  }

/*  Widget _speakerVideoView(BuildContext context, ActiveSession activeSession) {
    if (activeSession.totemParticipant != null &&
        (!activeSession.totemReceived ||
            !(activeSession.totemParticipant!.me))) {
      return prov.ChangeNotifierProvider<SessionParticipant>.value(
        value: activeSession.totemParticipant!,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final sizeOfVideo =
                min(constraints.maxWidth, constraints.maxHeight);
            return SizedBox(
              width: sizeOfVideo,
              height: sizeOfVideo,
              child: prov.Consumer<SessionParticipant>(
                builder: (_, participant, __) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: Stack(
                      children: [
                        CircleLiveSessionVideo(participant: participant),
                        if (participant.videoMuted)
                          const Positioned.fill(
                            child: CameraMuted(),
                          ),
                        if (!participant.me && participant.networkUnstable)
                          const Positioned(
                            top: 10,
                            left: 10,
                            child: CircleNetworkUnstable(),
                          ),
                        if (participant.muted)
                          const PositionedDirectional(
                            top: 10,
                            end: 10,
                            child: MuteIndicator(),
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    }
    return Container();
  } */

  Widget _speakerUserView(BuildContext context,
      {required List<SessionParticipant> participants,
      required ActiveSession activeSession,
      required bool isPhoneLayout}) {
    return CircleLiveSessionUsers(
      speakerView: true,
      isPhoneLayout: isPhoneLayout,
    );
  }

  Widget _speakerControlsView(
    BuildContext context, {
    required List<SessionParticipant> participants,
    required ActiveSession activeSession,
  }) {
    return Column(
      children: [
        Expanded(child: Container()),
        SizedBox(
          height: 60,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _sessionControl(context, activeSession),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget? _sessionControl(BuildContext context, ActiveSession activeSession) {
    final participant = activeSession.totemParticipant;
    if (participant != null && participant.me) {
      final themeColors = Theme.of(context).themeColors;
      final textStyles = Theme.of(context).textStyles;
      final t = AppLocalizations.of(context)!;
      bool isMobile = DeviceType.isMobile();
      {
        return Center(
          child: !isMobile
              ? ((activeSession.totemReceived)
                  ? ThemedRaisedButton(
                      width: 200,
                      height: 50,
                      backgroundColor: themeColors.alternateButtonBackground,
                      onPressed: !_processingRequest
                          ? () {
                              _endTurn(context, participant);
                            }
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(FontAwesomeIcons.hand,
                              size: 20, color: themeColors.primaryText),
                          const SizedBox(width: 10),
                          Text(t.pass)
                        ],
                      ),
                    )
                  : ThemedRaisedButton(
                      width: 200,
                      height: 50,
                      label: t.receive,
                      onPressed: !_processingRequest
                          ? () {
                              _receiveTurn(context, participant);
                            }
                          : null))
              : (activeSession.totemReceived)
                  ? SizedBox(
                      key: _sliderPass,
                      width: 250,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border:
                              Border.all(width: 1, color: themeColors.primary),
                        ),
                        child: SlideAction(
                          borderRadius: 30,
                          elevation: 0,
                          height: 60,
                          sliderRotate: false,
                          innerColor: themeColors.profileBackground,
                          outerColor: Colors.transparent,
                          sliderButtonIconPadding: 0,
                          sliderButtonIcon: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: themeColors.primary,
                            ),
                            child: Center(
                              child: Icon(Icons.check_circle_outline,
                                  size: 24, color: themeColors.primaryText),
                            ),
                          ),
                          submittedIcon: const SizedBox(height: 48, width: 48),
                          onSubmit: !_processingRequest
                              ? () {
                                  // delay to allow for animation to complete
                                  Future.delayed(
                                      const Duration(milliseconds: 300), () {
                                    _endTurn(context, participant);
                                  });
                                }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(1),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: themeColors.sliderBackground
                                      .withAlpha(120),
                                  borderRadius: BorderRadius.circular(30)),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 40,
                                  ),
                                  child: Text(
                                    t.slideToPass,
                                    style: textStyles.headline3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      key: _sliderReceive,
                      width: 250,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border:
                              Border.all(width: 1, color: themeColors.primary),
                        ),
                        child: SlideAction(
                          borderRadius: 30,
                          elevation: 0,
                          height: 60,
                          innerColor: themeColors.profileBackground,
                          outerColor: Colors.transparent,
                          sliderButtonIconPadding: 0,
                          sliderButtonIcon:
                              const SizedBox(height: 48, width: 48),
                          submittedIcon: Icon(Icons.check_circle_outline,
                              size: 24, color: themeColors.primaryText),
                          onSubmit: !_processingRequest
                              ? () {
                                  // delay to allow for animation to complete
                                  Future.delayed(
                                      const Duration(milliseconds: 300), () {
                                    _receiveTurn(context, participant);
                                  });
                                }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(1),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: themeColors.sliderBackground
                                      .withAlpha(120),
                                  borderRadius: BorderRadius.circular(30)),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 40,
                                  ),
                                  child: Text(
                                    t.slideToReceive,
                                    style: textStyles.headline3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
        );
      }
    }
    return null;
  }

  Future<void> _receiveTurn(
      BuildContext context, SessionParticipant participant) async {
    setState(() => _processingRequest = true);
    final commProvider = ref.read(communicationsProvider);
    await commProvider.receiveActiveSessionTotem(
        sessionUserId: participant.sessionUserId!);
    setState(() => _processingRequest = false);
  }

  Future<void> _endTurn(
    BuildContext context,
    SessionParticipant participant,
  ) async {
    setState(() => _processingRequest = true);
    final commProvider = ref.read(communicationsProvider);
    await commProvider.doneActiveSessionTotem(
        sessionUserId: participant.sessionUserId!);
    setState(() => _processingRequest = false);
  }

  Future<void> _handleSpace() async {
    debugPrint('Handling space key: is it my turn? ${_myTurn.toString()}');
    if (_myTurn) {
      final activeSession = ref.read(activeSessionProvider);
      if (activeSession.totemReceived) {
        await _endTurn(context, activeSession.totemParticipant!);
      } else {
        await _receiveTurn(context, activeSession.totemParticipant!);
      }
    } else {
      setState(() => _processingRequest = false);
    }
  }

  Future<void> _showDeviceSettings() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const CircleDeviceSelector();
      },
    );
  }
}
