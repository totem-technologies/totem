import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/index.dart';

class CircleSessionContent extends ConsumerWidget {
  const CircleSessionContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Stack(
      children: [
        CirclePendingSessionUsers(),
        /*Align(
            alignment: Alignment.bottomCenter,
            child: CircleMutedIndicator(
              live: false,
            ),), */
      ],
    );
  }
}
