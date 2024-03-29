import 'dart:ui';

import 'package:diffutil_dart/diffutil.dart' as diff_util;
import 'package:flutter/material.dart' hide ReorderableList;
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/app/circle/components/circle_session_participant_list_item.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class CircleSessionInfoPage extends ConsumerStatefulWidget {
  const CircleSessionInfoPage({super.key});

  static Future<String?> showDialog(BuildContext context) async {
    return showModalBottomSheet<String>(
      enableDrag: false,
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).themeColors.blurBackground,
      builder: (_) => const CircleSessionInfoPage(),
    );
  }

  @override
  CircleSessionInfoPageState createState() => CircleSessionInfoPageState();
}

class CircleSessionInfoPageState extends ConsumerState<CircleSessionInfoPage> {
  SessionParticipant? me;
  late List<SessionParticipant> _participants;
  late ActiveSession _activeSession;
  late SessionState _sessionState;
  @override
  void initState() {
    _activeSession = ref.read(activeSessionProvider);
    _sessionState = _activeSession.state;
    _participants =
        List<SessionParticipant>.from(_activeSession.speakOrderParticipants);
    me = _activeSession.me();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    ref.listen(activeSessionProvider,
        (ActiveSession? previous, ActiveSession next) {
      bool updated = false;
      final result = diff_util
          .calculateListDiff(_participants, next.speakOrderParticipants)
          .getUpdatesWithData();
      for (var change in result) {
        change.when(insert: (pos, data) {
          updated = true;
          _participants.add(data);
          return true;
        }, remove: (pos, data) {
          updated = true;
          _participants.removeAt(pos);
          return true;
        }, change: (pos, oldData, newData) {
          // skipping changes
          return true;
        }, move: (from, to, data) {
          // skipping move as the list may be reordered
          return true;
        });
      }
      if (updated) {
        setState(() {});
      }
    });

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
                        LucideIcons.x,
                        color: themeColors.primaryText,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                        left: Theme.of(context).pageHorizontalPadding,
                        right: Theme.of(context).pageHorizontalPadding,
                        bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _activeSession.circle.name,
                                style: textStyles.dialogTitle,
                              ),
                            ),
                            if (_activeSession.circle.link != null) ...[
                              const SizedBox(
                                width: 10,
                              ),
                              TextButton(
                                onPressed: () {
                                  _handleShare();
                                },
                                child: Text(t.share),
                              ),
                            ],
                          ],
                        ),
                        if (_activeSession.topic.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            t.circleWeeksSession,
                            style: textStyles.displaySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(_activeSession.topic),
                        ],
                        if (_activeSession.circle.description != null &&
                            _activeSession.circle.description!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            t.circleDescription,
                            style: textStyles.displaySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(_activeSession.circle.description!),
                        ],
                        const SizedBox(height: 24),
                        Divider(
                          thickness: 1,
                          height: 1,
                          color: themeColors.divider,
                        ),
                        const SizedBox(height: 24),
                        (me == null || me!.role != Role.keeper)
                            ? _contentList(context, _participants)
                            : _keeperContentList(context, _participants),
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

  Widget _contentList(
      BuildContext context, List<SessionParticipant> participants) {
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return CircleSessionParticipantListItem(
              horizontalPadding: 0, participant: participants[index]);
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 12,
          );
        },
        itemCount: participants.length);
  }

  Widget _keeperContentList(
      BuildContext context, List<SessionParticipant> participants) {
    return ReorderableList(
      onReorder: (Key item, Key newPosition) {
        int draggingIndex = participants.indexWhere(
            (element) => element.sessionUserId == (item as ValueKey).value);
        int newPositionIndex = participants.indexWhere((element) =>
            element.sessionUserId == (newPosition as ValueKey).value);

        final draggedItem = participants[draggingIndex];
        participants.removeAt(draggingIndex);
        participants.insert(newPositionIndex, draggedItem);
        setState(() {});
        /*setState(() {
        assignments.reorderAssignment(
            draggingIndex, newPositionIndex, draggedItem);
      }); */
        debugPrint(
            'item: ${(item as ValueKey).value} new_pos: $newPositionIndex Index: $draggingIndex');
        return true;
      },
      onReorderDone: (Key item) async {
        // sorted, save
        // update the list of users
        final repo = ref.read(repositoryProvider);
        await repo.updateActiveSession(repo.activeSession!.reorderParticipants(
            _participants
                .map((element) => element.sessionUserId!)
                .toList(growable: false)));
      },
      child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            SessionParticipant participant = participants[index];
            if ((_sessionState == SessionState.live ||
                    _sessionState == SessionState.expiring) &&
                index == 0) {
              // for a live session, the first user in the list is the current
              // totem user. Don't allow them to be reordered for this case
              return CircleSessionParticipantListItem(
                horizontalPadding: 0,
                participant: participants[index],
                onRemove: (participant) {
                  _promptRemoveUser(context, participant);
                },
              );
            }
            return ReorderableItem(
              key: ValueKey(participant.sessionUserId!),
              childBuilder: (BuildContext context, ReorderableItemState state) {
                return CircleSessionParticipantListItem(
                  participant: participants[index],
                  reorder: true,
                  horizontalPadding: 0,
                  onRemove: (participant) {
                    _promptRemoveUser(context, participant);
                  },
                );
              },
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 12,
            );
          },
          itemCount: participants.length),
    );
  }

  Future<void> _handleShare() async {
    if (_activeSession.circle.link != null) {
      try {
        await Clipboard.setData(
            ClipboardData(text: _activeSession.circle.link!));
        if (!mounted) return;
        final t = AppLocalizations.of(context)!;
        // show the dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(t.copiedToClipboard),
              actions: [
                TextButton(
                  child: Text(t.ok),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      } catch (ex) {
        debugPrint(
            'ERROR copying ${_activeSession.circle.link} to clipboard: ${ex.toString()}');
      }
    }
  }

  Future<void> _promptRemoveUser(
      BuildContext context, SessionParticipant participant) async {
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
          child: Text(t.removeFromCirclePrompt(participant.name)),
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
                sessionUserId: participant.sessionUserId!,
              );
      if (!context.mounted) return;
      if (!result) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Theme.of(context).themeColors.blurBackground,
          builder: (_) => AlertDialog(
            title: Text(t.unableToRemoveUser),
            content: Text(t.unableToRemoveUserMessage(participant.name)),
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
