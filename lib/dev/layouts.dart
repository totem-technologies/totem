import 'package:flutter/material.dart';

import '../app/circle/components/circle_live_session_users.dart';

Widget getParticipant(int i, double d) {
  return Container(
    padding: const EdgeInsets.all(5),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      height: d,
      width: d,
    ),
  );
}

class CircleUserLayout extends StatefulWidget {
  const CircleUserLayout({Key? key}) : super(key: key);

  @override
  State<CircleUserLayout> createState() => _CircleUserLayoutState();
}

class _CircleUserLayoutState extends State<CircleUserLayout> {
  var participantCount = 4;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: CircleLiveSessionUsersLayout(
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
