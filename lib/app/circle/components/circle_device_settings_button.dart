import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/theme/index.dart';

class CircleDeviceSettingsButton extends ConsumerStatefulWidget {
  const CircleDeviceSettingsButton({Key? key}) : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CircleDeviceSettingsButtonState();
}

class CircleDeviceSettingsButtonState
    extends ConsumerState<CircleDeviceSettingsButton> {
  bool _audioVideo = true;
  @override
  void initState() {
    _audioVideo = ref.read(communicationsProvider).audioDeviceConfigurable;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(width: 1, color: themeColors.primaryText),
      ),
      onPressed: () {
        _showDeviceSelector();
      },
      clipBehavior: Clip.hardEdge,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.settings, size: 24, color: themeColors.primaryText),
          const SizedBox(
            width: 6,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _audioVideo ? t.audioVideoSettings : t.videoSettings,
              style: TextStyle(color: themeColors.primaryText),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeviceSelector() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const CircleDeviceSelector();
      },
    );
  }
}
