import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/components/circle_snap_session_content.dart';

class CircleMutedIndicator extends ConsumerStatefulWidget {
  const CircleMutedIndicator({super.key});

  @override
  ConsumerState<CircleMutedIndicator> createState() =>
      _CircleMutedIndicatorState();
}

class _CircleMutedIndicatorState extends ConsumerState<CircleMutedIndicator> {
  final numberOfLevels = 8;
  var minLevel = 100.0;
  var maxLevel = 0.0;
  @override
  Widget build(BuildContext context) {
    final audioLevel = ref.watch(audioLevelStream);
    return audioLevel.when(
      data: (data) {
        final rawLevel = data.level;
        if (minLevel > rawLevel) {
          setState(() {
            minLevel = rawLevel;
          });
        }
        if (maxLevel < rawLevel) {
          setState(() {
            maxLevel = rawLevel;
          });
        }
        final intLevel = _mapRange(rawLevel);
        final bars = List.generate(numberOfLevels, (i) {
          final active = intLevel >= (i + 1) ? true : false;
          return _VolumeBar(
            active: active,
          );
        });
        return Container(
            color: Colors.redAccent.withOpacity(0), child: Row(children: bars));
      },
      error: (error, stackTrace) => Container(),
      loading: () => Container(),
    );
  }

  int _mapRange(double rawVal) {
    // Maps a double from [0, 1] to an int [0, numberOfLevels]
    var normal = (maxLevel - minLevel) == 0 ? 0.1 : maxLevel - minLevel;
    return (((rawVal - minLevel) * (numberOfLevels + 1)) / normal).floor();
  }
}

class _VolumeBar extends StatelessWidget {
  const _VolumeBar({this.active = false});
  final bool active;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: active ? Colors.blue : Colors.grey,
      ),
      height: 20,
      width: 10,
    );
  }
}
