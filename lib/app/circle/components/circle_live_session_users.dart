import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/app/circle/components/circle_live_session_participant.dart';
import 'package:totem/theme/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'circle_live_session_participant.dart';

class CircleLiveSessionUsers extends ConsumerWidget {
  const CircleLiveSessionUsers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participants = ref.watch(activeSessionProvider).activeParticipants;
    if (participants.isNotEmpty) {
      final List<Widget> userItems = <Widget>[];
      for (int i = 0; i < participants.length; i++) {
        userItems.add(
          LayoutId(
            id: 'item$i',
            child: CircleLiveSessionParticipant(
                participantId: participants[i].userProfile.uid),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: Container()),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                  horizontal: Theme.of(context).pageHorizontalPadding),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return CircleLiveSessionParticipant(
                    participantId: participants[index].userProfile.uid);
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
}
