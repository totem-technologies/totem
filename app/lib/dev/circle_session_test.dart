import 'package:flutter/material.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/dev/layouts.dart';
import 'package:totem/dev/test_session_controls.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/app_theme_styles.dart';

import '../app/circle/components/layouts.dart';
import '../components/animation/reveal_animation_container.dart';
import '../services/utils/device_type.dart';

class ActiveSessionLayoutTest extends StatefulWidget {
  const ActiveSessionLayoutTest({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ActiveSessionLayoutTestState();
}

class ActiveSessionLayoutTestState extends State<ActiveSessionLayoutTest> {
  int participantCount = 7;
  bool waiting = true;
  bool waitingForTotem = true;
  bool totemUser = false;
  final String circleName = "This is a test circle with a pretty long name";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.indigo,
            child: Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                        value: waiting,
                        onChanged: (value) => setState(() => waiting = value!)),
                    const Text(
                      'Waiting',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                if (!waiting) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                          value: waitingForTotem,
                          onChanged: (value) =>
                              setState(() => waitingForTotem = value!)),
                      const Text(
                        'Waiting for Totem',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                          value: totemUser,
                          onChanged: (value) =>
                              setState(() => totemUser = value!)),
                      const Text(
                        'Totem User',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
                TextButton(
                    onPressed: () {
                      setState(() {
                        participantCount = participantCount + 1;
                      });
                    },
                    child: const Text('Add')),
                TextButton(
                    onPressed: () {
                      setState(() {
                        participantCount = participantCount - 1;
                      });
                    },
                    child: const Text('Remove')),
                TextButton(
                    onPressed: () {
                      setState(() {
                        participantCount = 0;
                      });
                    },
                    child: const Text('0')),
                TextButton(
                    onPressed: () {
                      setState(() {
                        participantCount = 10;
                      });
                    },
                    child: const Text('10')),
                TextButton(
                    onPressed: () {
                      setState(() {
                        participantCount = 20;
                      });
                    },
                    child: const Text('20')),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: waiting ? Colors.yellow.shade100 : Colors.black,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: waiting
                    ? Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: WaitingRoomListLayout(
                                  generate: getParticipant,
                                  count: participantCount),
                            ),
                          ),
                          TestSessionControls(
                            sessionState: SessionState.waiting,
                            role: Role.keeper,
                            circleName: circleName,
                          ),
                        ],
                      )
                    : LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          final themeData = Theme.of(context);
                          final themeColors = themeData.themeColors;
                          final textStyles = themeData.textStyles;
                          final isPhoneLayout = DeviceType.isPhone() ||
                              (constraints.maxWidth <=
                                  (Theme.of(context).portraitBreak));
                          debugPrint(
                              'Live Session width: ${constraints.maxWidth} > ${Theme.of(context).portraitBreak}');
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 10),
                                child: Text(
                                  circleName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textStyles.displayMedium!.merge(
                                    TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: themeColors.reversedText),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  child: ListenerUserLayout(
                                    constrainSpeaker: !totemUser,
                                    userList: ParticipantListLayout(
                                        maxAllowedDimension: 1,
                                        maxChildSize: isPhoneLayout ? 100 : 180,
                                        direction: isPhoneLayout
                                            ? Axis.horizontal
                                            : Axis.vertical,
                                        generate: getParticipant,
                                        count: participantCount),
                                    speaker: !waitingForTotem
                                        ? (!totemUser
                                            ? RevealAnimationContainer(
                                                revealAnimationStart: 0,
                                                revealInset: 0.9,
                                                child: Image.network(
                                                  'https://www.w3schools.com/howto/img_avatar.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Image.network(
                                                'https://www.w3schools.com/howto/img_avatar.png',
                                                fit: BoxFit.cover,
                                              ))
                                        : (totemUser
                                            ? const PendingTotemUser()
                                            : const WaitingForTotemUser()),
                                    isPhoneLayout: isPhoneLayout,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TestSessionControls(
                                sessionState: SessionState.live,
                                role: Role.keeper,
                                circleName: circleName,
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
