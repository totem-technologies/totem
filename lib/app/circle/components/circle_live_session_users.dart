import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleLiveSessionUsers extends ConsumerWidget {
  const CircleLiveSessionUsers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    final participants = activeSession.activeParticipants;
    if (participants.isNotEmpty) {
      final List<Widget> userItems = <Widget>[];
      for (int i = 0; i < participants.length; i++) {
        userItems.add(
          LayoutId(
            id: 'item$i',
            child: CircleLiveSessionParticipant(
                participantId: participants[i].uid),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(child: CircleLiveTotemParticipant()),
          SizedBox(
            height: 90,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _sessionControl(context, activeSession, ref),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 80,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                  horizontal: Theme.of(context).pageHorizontalPadding),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return CircleLiveSessionParticipant(
                  participantId: participants[index].uid,
                  hasTotem: activeSession.totemUser ==
                      participants[index].sessionUserId,
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  width: 10,
                );
              },
              itemCount: participants.length,
            ),
          ),
        ],
      );
    }
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final textStyles = themeData.textTheme;
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

  Widget? _sessionControl(
      BuildContext context, ActiveSession activeSession, WidgetRef ref) {
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
                        _endTurn(context, participant, ref);
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
                      child: SlideAction(
                        borderRadius: 30,
                        elevation: 0,
                        height: 60,
                        innerColor: themeColors.profileBackground,
                        outerColor: themeColors.primary,
                        sliderButtonIconPadding: 0,
                        sliderButtonIcon: const SizedBox(height: 48, width: 48),
                        submittedIcon:
                            SvgPicture.asset('assets/circle_check.svg'),
                        onSubmit: () {
                          // delay to allow for animation to complete
                          Future.delayed(const Duration(milliseconds: 300), () {
                            _receiveTurn(context, participant, ref);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: Container(
                            decoration: BoxDecoration(
                                color: themeColors.sliderBackground,
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

  Future<void> _receiveTurn(BuildContext context,
      SessionParticipant participant, WidgetRef ref) async {
    final commProvider = ref.read(communicationsProvider);
    await commProvider.receiveActiveSessionTotem(
        sessionUserId: participant.sessionUserId!);
  }

  Future<void> _endTurn(BuildContext context, SessionParticipant participant,
      WidgetRef ref) async {
    final commProvider = ref.read(communicationsProvider);
    await commProvider.doneActiveSessionTotem(
        sessionUserId: participant.sessionUserId!);
  }
}
