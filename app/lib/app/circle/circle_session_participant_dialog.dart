import 'dart:ui';

import 'package:flutter/material.dart' hide ReorderableList;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class CircleSessionParticipantDialog extends ConsumerStatefulWidget {
  const CircleSessionParticipantDialog({
    super.key,
    required this.participant,
    this.overrideMe = false,
  });
  final SessionParticipant participant;
  final bool overrideMe;

  static Future<String?> showParticipantDialog(
    BuildContext context, {
    required SessionParticipant participant,
    bool overrideMe = false,
  }) async {
    return showModalBottomSheet<String>(
      enableDrag: true,
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).themeColors.blurBackground,
      builder: (_) => CircleSessionParticipantDialog(
        participant: participant,
        overrideMe: overrideMe,
      ),
    );
  }

  @override
  CircleSessionParticipantDialogState createState() =>
      CircleSessionParticipantDialogState();
}

class CircleSessionParticipantDialogState
    extends ConsumerState<CircleSessionParticipantDialog> {
  late Future<UserProfile?> _userProfile;
  final timeFormat = DateFormat("MMMM, yyyy");
  SessionParticipant? me;

  @override
  void initState() {
    _userProfile = ref
        .read(repositoryProvider)
        .userProfileWithId(uid: widget.participant.uid, circlesCompleted: true);
    me = !widget.overrideMe
        ? ref.read(activeSessionProvider).me()
        : widget.participant;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 50,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: Theme.of(context).maxRenderWidth),
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
                            LucideIcons.x,
                            color: themeColors.primaryText,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                Theme.of(context).pageHorizontalPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              widget.participant.name,
                              style: textStyles.displayMedium,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
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
                                            shape: BoxShape.rectangle,
                                            profile: profile,
                                            borderRadius: 8,
                                          ),
                                        ),
                                        const SizedBox(height: 40),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                t.memberSince,
                                                style: textStyles.displaySmall,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                                timeFormat
                                                    .format(profile.createdOn),
                                                style: textStyles.bodyLarge)
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
                                                style: textStyles.displaySmall,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              profile.completedCircles
                                                      ?.toString() ??
                                                  "0",
                                              style: textStyles.bodyLarge,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        Expanded(child: Container()),
                                        if (!widget.participant.me &&
                                            me != null &&
                                            me!.role == Role.keeper)
                                          ..._removeButton(context),
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
        ),
      ),
    );
  }

  List<Widget> _removeButton(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textStyles;
    return [
      Divider(
        thickness: 1,
        height: 32,
        color: themeColors.divider,
      ),
      InkWell(
        onTap: () {
          _promptRemoveUser(context);
        },
        child: Row(
          children: [
            Icon(LucideIcons.trash, color: themeColors.primaryText),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context)!.removeFromCircle,
                style: textStyles.labelLarge),
          ],
        ),
      ),
      Divider(
        thickness: 1,
        height: 32,
        color: themeColors.divider,
      ),
    ];
  }

  Future<void> _promptRemoveUser(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Theme.of(context).themeColors.blurBackground,
      builder: (_) => AlertDialog(
        title: Text(t.removeFromCircle),
        content: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: Theme.of(context).maxRenderWidth),
          child: Text(t.removeFromCirclePrompt(widget.participant.name)),
        ),
        actions: [
          TextButton(
            child: Text(t.no),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text(t.yes),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
    if (result != null && result == true) {
      //await _removeUser();
      bool result =
          await ref.read(communicationsProvider).removeUserFromSession(
                sessionUserId: widget.participant.sessionUserId!,
              );
      if (!context.mounted) {
        return;
      }
      if (result) {
        Navigator.of(context).pop();
      } else {
        await showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Theme.of(context).themeColors.blurBackground,
          builder: (_) => AlertDialog(
            title: Text(t.unableToRemoveUser),
            content: Text(t.unableToRemoveUserMessage(widget.participant.name)),
            actions: [
              TextButton(
                child: Text(t.ok),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }
  }
}
