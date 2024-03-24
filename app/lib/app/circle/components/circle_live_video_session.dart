import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keybinder/keybinder.dart';
import 'package:totem/app/circle/components/circle_session_timer.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/components/widgets/slider_button.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';

import 'layouts.dart';

class CircleLiveVideoSession extends ConsumerStatefulWidget {
  const CircleLiveVideoSession({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CircleLiveVideoSessionState();
}

class _CircleLiveVideoSessionState
    extends ConsumerState<CircleLiveVideoSession> {
  final GlobalKey _sliderPass = GlobalKey();
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
    final commProvider = ref.watch(communicationsProvider);
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
                              if (kIsWeb) const SizedBox(height: 10),
                              Row(
                                children: [
                                  CircleImage(
                                    circle: activeSession.circle,
                                    size: 40,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      activeSession.circle.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textStyles.displayMedium!.merge(
                                        TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: themeColors.reversedText),
                                      ),
                                    ),
                                  ),
                                  const CircleSessionTimer(),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: commProvider.state ==
                                        CommunicationState.active
                                    ? (participants.isNotEmpty
                                        ? AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 500),
                                            child:
                                                activeSession.totemReceived &&
                                                        (totemParticipant.me)
                                                    ? _speakerUserView(context,
                                                        activeSession:
                                                            activeSession,
                                                        isPhoneLayout:
                                                            isPhoneLayout)
                                                    : ListenerUserLayout(
                                                        speaker:
                                                            SpeakerVideoView(
                                                          onReceive: () {
                                                            final participant =
                                                                activeSession
                                                                    .totemParticipant;
                                                            _receiveTurn(
                                                                context,
                                                                participant!);
                                                          },
                                                          onSettings: () {
                                                            _showDeviceSettings();
                                                          },
                                                        ),
                                                        userList:
                                                            CircleLiveSessionUsers(
                                                                isPhoneLayout:
                                                                    isPhoneLayout),
                                                        isPhoneLayout:
                                                            isPhoneLayout,
                                                      ),
                                          )
                                        : Center(
                                            child: Text(
                                              t.noParticipantsActiveSession,
                                              style: textStyles.displaySmall!
                                                  .merge(TextStyle(
                                                      color: themeColors
                                                          .reversedText)),
                                              textAlign: TextAlign.center,
                                            ),
                                          ))
                                    : _renderSessionState(commProvider.state),
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

  Widget _speakerUserView(BuildContext context,
      {required ActiveSession activeSession, required bool isPhoneLayout}) {
    final totemId = activeSession.totemParticipant?.uid;
    final participants = activeSession.speakOrderParticipants
        .where((element) => element.uid != totemId)
        .toList();

    return WaitingRoomListLayout(
      generate: (i, dimension) => CircleSessionParticipant(
        dimension: dimension,
        participant: participants[i],
        hasTotem: activeSession.totemUser == participants[i].sessionUserId,
        next: i == 0,
      ),
      count: participants.length,
      live: true,
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _passControl(context, activeSession),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget? _passControl(BuildContext context, ActiveSession activeSession) {
    final participant = activeSession.totemParticipant;
    if (participant != null && participant.me) {
      final themeColors = Theme.of(context).themeColors;
      final t = AppLocalizations.of(context)!;
      bool isMobile = DeviceType.isMobile();
      {
        return Center(
          child: !isMobile
              ? TotemActionButton(
                  busy: _processingRequest,
                  label: t.pass,
                  onPressed: !_processingRequest
                      ? () {
                          _endTurn(context, participant);
                        }
                      : null,
                )
              : SizedBox(
                  key: _sliderPass,
                  width: 250,
                  // height: 60,
                  child: SliderButton(
                    action: (controller) async {
                      await _endTurn(context, participant);
                    },
                  )),
        );
      }
    }
    return null;
  }

  Widget _renderSessionState(CommunicationState state) {
    switch (state) {
      case CommunicationState.joining:
        return _joiningSession();
      default:
        return Container();
    }
  }

  Widget _joiningSession() {
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textStyles;
    final themeColors = Theme.of(context).themeColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            t.joiningCircle,
            style: textStyles.displaySmall!
                .merge(TextStyle(color: themeColors.reversedText)),
          ),
          const SizedBox(
            height: 20,
          ),
          BusyIndicator(color: themeColors.reversedText),
        ],
      ),
    );
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
