import 'package:flutter/material.dart';
import 'package:totem/dev/layouts.dart';
import 'package:totem/dev/test_session_controls.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/app_theme_styles.dart';

import '../app/circle/components/layouts.dart';
import '../app/circle/components/listener_user_layout.dart';
import '../services/utils/device_type.dart';

class ActiveSessionLayoutTest extends StatefulWidget {
  const ActiveSessionLayoutTest({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ActiveSessionLayoutTestState();
}

class ActiveSessionLayoutTestState extends State<ActiveSessionLayoutTest> {
  int participantCount = 7;
  bool waiting = true;
  final String circleName = "This is a test circle with a pretty long name";
  @override
  Widget build(BuildContext context) {
    return Column(
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
                                maxChildSize: 300,
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
                            if (isPhoneLayout) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  circleName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textStyles.headline2!.merge(
                                    TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: themeColors.reversedText),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                            ],
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                                child: ListenerUserLayout(
                                  userList: ParticipantListLayout(
                                      maxAllowedDimension: 2,
                                      maxChildSize: isPhoneLayout ? 100 : 180,
                                      generate: getParticipant,
                                      count: participantCount),
                                  speaker: Container(
                                    color: Colors.yellow,
                                  ),
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
    );
  }
}
