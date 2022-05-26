import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/app/circle/components/circle_snap_session_content.dart';
import 'package:totem/services/audio_level/audio_level.dart';
import 'package:totem/theme/index.dart';

class CircleMutedIndicator extends ConsumerWidget {
  const CircleMutedIndicator({Key? key, required this.live}) : super(key: key);
  final bool live;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioLevel = ref.watch(audioLevelStream);
    final communications = ref.watch(communicationsProvider);
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    return audioLevel.when(
        loading: () => Container(),
        error: (Object error, StackTrace? stackTrace) => Container(),
        data: (AudioLevelData auidoData) {
          if (auidoData.speaking && communications.muted) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: live ? Colors.white : Colors.black,
                boxShadow: [
                  BoxShadow(
                      color: themeColors.shadow,
                      offset: const Offset(0, 2),
                      blurRadius: 8),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: Text(
                t.speakingMuted,
                style: TextStyle(
                    color: live
                        ? themeColors.primaryText
                        : themeColors.reversedText),
              ),
            );
          }
          return Container();
        });
  }
}
