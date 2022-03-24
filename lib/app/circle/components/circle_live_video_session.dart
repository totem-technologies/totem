import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleLiveVideoSession extends ConsumerStatefulWidget {
  const CircleLiveVideoSession({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CircleLiveVideoSessionState();
}

class _CircleLiveVideoSessionState
    extends ConsumerState<CircleLiveVideoSession> {
  @override
  Widget build(BuildContext context) {
    final activeSession = ref.watch(activeSessionProvider);
    final participants = activeSession.activeParticipants;
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textStyles;
    if (participants.isNotEmpty) {
      final totemParticipant = activeSession.totemParticipant;
      return Stack(
        children: [
          AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child:
                  activeSession.totemReceived && (totemParticipant?.me ?? false)
                      ? _speakerUserView(
                          context,
                          activeSession: activeSession,
                          participants: participants,
                        )
                      : _speakerVideoBackground(context, activeSession)),
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: !(totemParticipant?.me ?? false)
                        ? _listenerView(
                            context,
                            participants: participants,
                            activeSession: activeSession,
                          )
                        : _speakerControlsView(
                            context,
                            participants: participants,
                            activeSession: activeSession,
                          ),
                  ),
                ),
                // totem participant controls
                CircleSessionControls(
                  session: activeSession.session,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: themeColors.titleBarGradient,
                ),
              ),
              child: SafeArea(
                top: true,
                bottom: false,
                child: Padding(
                  child: Text(
                    activeSession.session.circle.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyles.headline2!.merge(
                      TextStyle(
                          fontWeight: FontWeight.w900,
                          color: themeColors.reversedText),
                    ),
                  ),
                  padding: EdgeInsets.only(
                      bottom: 50,
                      top: 0,
                      left: Theme.of(context).pageHorizontalPadding,
                      right: Theme.of(context).pageHorizontalPadding),
                ),
              ),
            ),
          )
        ],
      );
    }
    // no participants
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    return Center(
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: themeData.pageHorizontalPadding),
        child: Text(
          t.noParticipantsActiveSession,
          style: textStyles.headline3,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _speakerVideoBackground(
      BuildContext context, ActiveSession activeSession) {
    SessionParticipant? totemParticipant = activeSession.totemParticipant;
    if (totemParticipant != null &&
        (!activeSession.totemReceived || !(totemParticipant.me))) {
      return CircleLiveSessionVideo(participant: totemParticipant);
    }
    return Container(
      color: Colors.black,
    );
  }

  Widget _speakerUserView(
    BuildContext context, {
    required List<SessionParticipant> participants,
    required ActiveSession activeSession,
  }) {
    final filteredParticipants =
        participants.where((element) => !element.me).toList(growable: false);
    //final width = MediaQuery.of(context).size.width;
    int crossAxisCount = filteredParticipants.length < 9 ? 2 : 3;
    return Container(
      color: Colors.black,
      child: Center(
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.0,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            SessionParticipant participant = filteredParticipants[index];
            return CircleParticipantVideo(
              participant: participant,
            );
          },
          itemCount: filteredParticipants.length,
        ),
      ),
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
          height: 90,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _sessionControl(context, activeSession),
          ),
        ),
        const SizedBox(height: 10),
        if (!activeSession.totemReceived)
          _participantHorizontalList(context,
              participants: participants, activeSession: activeSession),
      ],
    );
  }

  Widget _listenerView(
    BuildContext context, {
    required List<SessionParticipant> participants,
    required ActiveSession activeSession,
  }) {
    return Column(
      children: [
        Expanded(child: Container()),
        const SizedBox(height: 30),
        _participantHorizontalList(context,
            participants: participants, activeSession: activeSession),
      ],
    );
  }

  Widget _participantHorizontalList(
    BuildContext context, {
    required List<SessionParticipant> participants,
    required ActiveSession activeSession,
  }) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
            horizontal: Theme.of(context).pageHorizontalPadding),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return CircleLiveSessionParticipant(
            participantId: participants[index].uid,
            hasTotem:
                activeSession.totemUser == participants[index].sessionUserId,
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            width: 10,
          );
        },
        itemCount: participants.length,
      ),
    );
  }

  Widget? _sessionControl(BuildContext context, ActiveSession activeSession) {
    final participant = activeSession.totemParticipant;
    if (participant != null && participant.me) {
      final themeColors = Theme.of(context).themeColors;
      final textStyles = Theme.of(context).textStyles;
      final t = AppLocalizations.of(context)!;
      {
        return Center(
          child: Column(
            children: [
              (activeSession.totemReceived)
                  ? InkWell(
                      onTap: () {
                        _endTurn(context, participant);
                      },
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: themeColors.primary,
                        ),
                        child: Center(
                          child: SvgPicture.asset('assets/circle_check.svg'),
                        ),
                      ),
                    )
                  : SizedBox(
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
                          submittedIcon:
                              SvgPicture.asset('assets/circle_check.svg'),
                          onSubmit: () {
                            // delay to allow for animation to complete
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              _receiveTurn(context, participant);
                            });
                          },
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
              const SizedBox(
                height: 6,
              ),
              Opacity(
                opacity: (activeSession.totemReceived) ? 1.0 : 0,
                child: Text(
                  t.pass,
                  style: textStyles.headline3,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }
    }
    return null;
  }

  Future<void> _receiveTurn(
      BuildContext context, SessionParticipant participant) async {
    final commProvider = ref.read(communicationsProvider);
    await commProvider.receiveActiveSessionTotem(
        sessionUserId: participant.sessionUserId!);
  }

  Future<void> _endTurn(
    BuildContext context,
    SessionParticipant participant,
  ) async {
    final commProvider = ref.read(communicationsProvider);
    await commProvider.doneActiveSessionTotem(
        sessionUserId: participant.sessionUserId!);
  }
}
