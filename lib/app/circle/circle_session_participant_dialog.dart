import 'dart:ui';

import 'package:flutter/material.dart' hide ReorderableList;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class CircleSessionParticipantDialog extends ConsumerStatefulWidget {
  const CircleSessionParticipantDialog({
    Key? key,
    required this.participant,
  }) : super(key: key);
  final SessionParticipant participant;

  static Future<String?> showDialog(
    BuildContext context, {
    required SessionParticipant participant,
  }) async {
    return showModalBottomSheet<String>(
      enableDrag: false,
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).themeColors.blurBackground,
      builder: (_) => CircleSessionParticipantDialog(
        participant: participant,
      ),
    );
  }

  @override
  _CircleSessionParticipantDialogState createState() =>
      _CircleSessionParticipantDialogState();
}

class _CircleSessionParticipantDialogState
    extends ConsumerState<CircleSessionParticipantDialog> {
  late Future<UserProfile?> _userProfile;
  final timeFormat = DateFormat("MMMM, yyyy");
  SessionParticipant? me;

  @override
  void initState() {
    _userProfile = ref
        .read(repositoryProvider)
        .userProfileWithId(uid: widget.participant.uid, circlesCompleted: true);
    me = ref.read(activeSessionProvider).me();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 50,
          ),
          child: BottomTrayContainer(
            fullScreen: true,
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Container()),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.close,
                        color: themeColors.primaryText,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Theme.of(context).pageHorizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          widget.participant.name,
                          style: textStyles.headline2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 33),
                        Expanded(
                          child: FutureBuilder<UserProfile?>(
                            future: _userProfile,
                            builder: (BuildContext context,
                                AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: BusyIndicator(),
                                );
                              }
                              UserProfile? profile = snapshot.data;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (profile == null)
                                    Text(
                                      t.unableToReadProfile,
                                      textAlign: TextAlign.center,
                                    ),
                                  if (profile != null) ...[
                                    Center(
                                      child: ProfileImage(
                                        size: 100,
                                        shape: BoxShape.circle,
                                        profile: profile,
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            t.memberSince,
                                            style: textStyles.headline3,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(timeFormat
                                            .format(profile.createdOn))
                                      ],
                                    ),
                                    Divider(
                                      thickness: 1,
                                      height: 32,
                                      color: themeColors.divider,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            t.circlesDone,
                                            style: textStyles.headline3,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(profile.completedCircles
                                                ?.toString() ??
                                            "0"),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Expanded(child: Container()),
                                    if (me != null && me!.role == Role.keeper)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Container(),
                                      ),
                                  ]
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
