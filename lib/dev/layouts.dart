import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:totem/app/circle/components/layouts.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/app/profile/onboarding_profile_page.dart';
import 'package:totem/components/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/account_state/index.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/app_theme_styles.dart';

Widget getParticipant(int i, double d) {
  SessionParticipant participant = SessionParticipant.fromJson({
    "name": "Participant ${i + 1}",
    "role": i == 0 ? Role.keeper.name : Role.member.name,
  });
  participant.muted = true;
  participant.videoMuted = true;
  participant.networkUnstable = true;
  if (i == 0 || i == 3) {
    participant.sessionImage = "assets/testuser.png";
  }
  return Container(
    height: d,
    width: d,
    padding: const EdgeInsets.all(5),
    child: Stack(
      children: [
        CircleParticipantVideo(
          participant: participant,
          channelId: "",
          next: i == 0,
        ),
      ],
    ),
  );
}

class WaitingRoomDevLayout extends StatefulWidget {
  const WaitingRoomDevLayout({Key? key}) : super(key: key);

  @override
  State<WaitingRoomDevLayout> createState() => _WaitingRoomDevLayoutState();
}

class _WaitingRoomDevLayoutState extends State<WaitingRoomDevLayout> {
  var participantCount = 4;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: WaitingRoomListLayout(
              generate: getParticipant, count: participantCount),
        ),
        Container(
          color: Colors.indigo,
          child: Row(
            children: [
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
      ],
    );
  }
}

class ListenLiveLayoutTest extends StatefulWidget {
  const ListenLiveLayoutTest({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ListenLiveLayoutState();
}

class ListenLiveLayoutState extends State<ListenLiveLayoutTest> {
  int participantCount = 7;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final isPhoneLayout = DeviceType.isPhone() ||
            (constraints.maxWidth <= Theme.of(context).portraitBreak);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.indigo,
              child: Row(
                children: [
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                color: Colors.black,
                child: ListenerUserLayout(
                  userList: ParticipantListLayout(
                      maxAllowedDimension: 2,
                      maxChildSize: 150,
                      generate: getParticipant,
                      count: participantCount),
                  speaker: Container(
                    color: Colors.yellow,
                  ),
                  isPhoneLayout: isPhoneLayout,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class OnboardingDialogTest extends StatefulWidget {
  const OnboardingDialogTest({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => OnboardingDialogTestState();
}

class OnboardingDialogTestState extends State<OnboardingDialogTest>
    with AfterLayoutMixin<OnboardingDialogTest> {
  bool showing = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey,
      child: showing
          ? Container()
          : Center(
              child: ThemedRaisedButton(
                label: 'Show Onboarding',
                onPressed: () {
                  showOnboarding();
                },
              ),
            ),
    );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    showOnboarding();
  }

  Future<void> showOnboarding() async {
    if (!showing) {
      setState(() => showing = true);
    }
    await AccountStateDialog.showEvent(context,
        event: OnboardingCircleEvent(testOnly: true));
    setState(() => showing = false);
  }
}

class CircleUserProfileTest extends StatefulWidget {
  const CircleUserProfileTest({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CircleUserProfileTestState();
}

class CircleUserProfileTestState extends State<CircleUserProfileTest> {
  late SessionParticipant _testParticipant;

  @override
  void initState() {
    _testParticipant = _generateParticipant(Role.keeper);
    super.initState();
  }

  SessionParticipant _generateParticipant(Role role) {
    return SessionParticipant.fromJson({
      "name": "Test Participant",
      "uid": "cz7h6p4IeqMSc1ZahXTw26OMOxy1",
      "role": role.name,
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.indigo,
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _testParticipant = _generateParticipant(Role.keeper);
                      });
                    },
                    child: const Text('Keeper'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _testParticipant = _generateParticipant(Role.member);
                      });
                    },
                    child: const Text('Member'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  color: themeColors.screenBackground,
                  child: Center(
                    child: ThemedRaisedButton(
                      onPressed: () {
                        CircleSessionParticipantDialog.showParticipantDialog(
                          context,
                          participant: _testParticipant,
                          overrideMe: true,
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  )),
            ),
          ],
        );
      },
    );
  }
}

class OnboardingProfilePageTest extends StatefulWidget {
  const OnboardingProfilePageTest({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => OnboardingProfilePageTestState();
}

class OnboardingProfilePageTestState extends State<OnboardingProfilePageTest>
    with AfterLayoutMixin<OnboardingProfilePageTest> {
  bool showing = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey,
      child: showing
          ? OnboardingProfilePage(
              onProfileUpdated: (UserProfile profile) {
                setState(() => showing = false);
              },
            )
          : Center(
              child: ThemedRaisedButton(
                label: 'Show Onboarding Profile Page',
                onPressed: () {
                  showDialog();
                },
              ),
            ),
    );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    showDialog();
  }

  Future<void> showDialog() async {
    if (!showing) {
      setState(() => showing = true);
    }
  }
}
