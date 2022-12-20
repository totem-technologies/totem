import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/components/circle_snap_session_content.dart';
import 'package:totem/theme/index.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/components/widgets/themed_control_button.dart';

class MuteButton extends ConsumerStatefulWidget {
  const MuteButton(
      {super.key,
      this.muted = false,
      this.onPressed,
      this.reverseLabel = true});
  final bool muted;
  final void Function()? onPressed;
  final bool reverseLabel;
  @override
  ConsumerState<MuteButton> createState() => _MuteButtonState();
}

class _MuteButtonState extends ConsumerState<MuteButton> {
  final numberOfLevels = 8;
  final maxSize = 40.0;
  var threshPercent = 0.15;
  var minLevel = 100.0;
  var maxLevel = 0.0;
  var currentSize = 0.0;

  @override
  Widget build(BuildContext context) {
    final muted = widget.muted;
    var audioLevel = 0.0;
    if (!muted) {
      final audioLevelEvent = ref.watch(audioLevelStream);
      if (audioLevelEvent.hasValue) {
        audioLevel = audioLevelEvent.value!.level;
        _setMaxMin(audioLevel);
      }
    }
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    var size = muted ? 0.0 : _mapRange(audioLevel).abs();
    if (size < maxSize * threshPercent) {
      // Below the threshold, set to zero
      size = 0.0;
    }
    var shrinking = size < currentSize;
    currentSize = size;
    return ThemedControlButton(
        label: muted ? t.unmute : t.mute,
        labelColor: widget.reverseLabel
            ? themeColors.reversedText
            : themeColors.primaryText,
        onPressed: widget.onPressed,
        child: Stack(children: [
          Center(
            child: AnimatedContainer(
              // Fast to grow, slow to fade.
              duration: Duration(milliseconds: shrinking ? 500 : 100),
              decoration: BoxDecoration(
                  color: themeColors.primaryButtonBackground,
                  borderRadius: BorderRadius.circular(50.0)),
              height: size,
              width: size,
            ),
          ),
          Center(
            child: Icon(muted ? LucideIcons.micOff : LucideIcons.mic,
                color: themeColors.primaryText),
          )
        ]));
  }

  void _setMaxMin(double level) {
    // Dynamically set the upper and lower bounds based on the values we've seen.
    if (minLevel > level) {
      setState(() {
        minLevel = level;
      });
    }
    if (maxLevel < level) {
      setState(() {
        maxLevel = level;
      });
    }
  }

  double _mapRange(double rawVal) {
    // Maps a double from [0, 1] to an int [0, numberOfLevels]
    var normal = (maxLevel - minLevel) == 0 ? 0.1 : maxLevel - minLevel;
    return (((rawVal - minLevel) * maxSize) / normal);
  }
}
