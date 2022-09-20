import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:totem/app/circle/components/index.dart';
import 'package:totem/models/user_profile.dart';
import 'package:totem/services/providers.dart';
import 'package:totem/theme/app_theme_styles.dart';

class PendingTotemUser extends ConsumerStatefulWidget {
  const PendingTotemUser(
      {Key? key, this.userVideo, this.onPass, this.onReceive, this.onSettings})
      : super(key: key);
  final Widget? userVideo;
  final Function()? onReceive;
  final Function()? onPass;
  final Function()? onSettings;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      PendingTotemUserState();
}

class PendingTotemUserState extends ConsumerState<PendingTotemUser> {
  static const double buttonSize = 330;
  static const double buttonSizeVertical = 220;
  static const double labelFontSize = 20;
  static const double standardFontSize = 15;
  static const double iconSize = 30;
  late Future<UserProfile?> _userProfileFetch;
  int? _completedCircles;

  @override
  void initState() {
    final repo = ref.read(repositoryProvider);
    _userProfileFetch = repo.userProfile(circlesCompleted: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _userProfileFetch,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasData && _completedCircles == null) {
          _completedCircles = asyncSnapshot.data!.completedCircles;
        }
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth < 500) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _receiveTotem(context, vertical: true),
                    const SizedBox(
                      height: 15,
                    ),
                    _settingsVideo(context, vertical: true),
                  ],
                ),
              );
            }
            final themeColors = Theme.of(context).themeColors;
            return Stack(children: [
              Positioned.fill(
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  final sizeOfVideo =
                      min(constraints.maxWidth, constraints.maxHeight);
                  return Center(
                    child: SizedBox(
                      width: sizeOfVideo,
                      height: sizeOfVideo,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              width: 1,
                              color: themeColors.controlButtonBackground),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                          child: widget.userVideo,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child: Row(
                  children: [
                    Expanded(child: Container()),
                    _receiveTotem(context),
                    Expanded(child: Container()),
                    /*const SizedBox(
                width: 15,
              ),
              Expanded(child: _settingsVideo(context)), */
                  ],
                ),
              ),
            ]);
          },
        );
      },
    );
  }

  Widget _receiveTotem(BuildContext context, {bool vertical = false}) {
    final t = AppLocalizations.of(context)!;
    return TotemActionButton(
      image: FaIcon(FontAwesomeIcons.wandMagicSparkles,
          size: iconSize, color: Theme.of(context).themeColors.primaryText),
      label: t.receive,
      message: t.circleTotemReceive,
      toolTips: [
        _lineItem(context, t.circleTotemReceiveLine1),
        _lineItem(context, t.circleTotemReceiveLine2),
      ],
      showToolTips: _completedCircles != null && _completedCircles! < 3,
      vertical: vertical,
      onPressed: widget.onReceive,
    );
  }

  Widget _settingsVideo(BuildContext context, {bool vertical = false}) {
    final t = AppLocalizations.of(context)!;
    final themeColors = Theme.of(context).themeColors;
    final style =
        TextStyle(color: themeColors.reversedText, fontSize: standardFontSize);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double size = min(constraints.maxWidth, 360);
        return SizedBox(
          height: !vertical ? buttonSize : buttonSizeVertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      width: 1, color: themeColors.controlButtonBackground),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: Container(
                      width: vertical ? 110 : size,
                      height: vertical ? 110 : size,
                      color: Colors.black,
                      child: widget.userVideo),
                ),
              ),
              Text(
                t.preview,
                style: style.merge(const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: labelFontSize)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _lineItem(BuildContext context, String text) {
    final themeColors = Theme.of(context).themeColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, color: themeColors.primaryText, size: 12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  color: themeColors.primaryText, fontSize: standardFontSize),
            ),
          ),
        ],
      ),
    );
  }
}
