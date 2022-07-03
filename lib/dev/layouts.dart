import 'package:flutter/material.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/app_theme_styles.dart';

import '../app/circle/components/layouts.dart';

Widget getParticipant(int i, double d) {
  return Container(
    height: d,
    width: d,
    padding: const EdgeInsets.all(5),
    child: Stack(children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      Positioned(
          bottom: 5,
          left: 5,
          child: CircleNameLabel(
            name: "Participant ${i + 1}",
          )),
    ]),
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
