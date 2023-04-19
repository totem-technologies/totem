import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/components/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class CircleSessionTimer extends ConsumerWidget {
  const CircleSessionTimer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;
    SessionParticipant? participant = activeSession.me();
    late DateTime startTime;
    if (activeSession.circle.nextSession != null) {
      // This is a scheduled session so count from the earliest of either the
      // scheduled start time or the actual start time.
      startTime =
          activeSession.circle.nextSession!.isBefore(activeSession.startedOn!)
              ? activeSession.circle.nextSession!
              : activeSession.startedOn!;
    } else {
      // This is an instant session so count from creation
      startTime = activeSession.circle.createdOn;
    }

    if (activeSession.expiresOn != null && participant != null) {
      return Row(
        children: [
          CountdownTimer(
            startTime: startTime,
            endTime: activeSession.expiresOn!,
            defaultState: CountdownState(
              displayValue: participant.role == Role.keeper,
              displayFormat: CountdownDisplayFormat.hoursAndMinutes,
              color: themeColors.primary,
              backgroundColor: themeColors.secondaryText,
              valueLabel: t.remaining,
            ),
            stateTransitions: [
              CountdownState(
                minutesRemaining: 5,
                displayValue: true,
                displayFormat: CountdownDisplayFormat.minutes,
                color: themeColors.reversedText,
                valueLabel: t.endsIn,
              ),
              CountdownState(
                minutesRemaining: 0,
                displayValue: true,
                displayFormat: CountdownDisplayFormat.override,
                color: themeColors.alertBackground,
                backgroundColor: themeColors.alertBackground,
                valueLabel: t.ending,
                valueOverride: t.now,
              ),
              CountdownState(
                minutesRemaining: -1,
                displayValue: true,
                displayFormat: CountdownDisplayFormat.hoursAndMinutes,
                color: themeColors.alertBackground,
                valueLabel: t.overtime,
              ),
            ],
          ),
          if (participant.role == Role.keeper) ...[
            PopupMenuButton(
              child: Icon(
                LucideIcons.moreVertical,
                color: themeColors.iconNext,
              ),
              itemBuilder: (context) => [
                if (DateTime.now().compareTo(activeSession.expiresOn!) <= 0)
                  PopupMenuItem(
                    value: 1,
                    child: Text(t.modifyTime),
                  ),
                PopupMenuItem(
                  value: 2,
                  child: Text(t.endNow),
                ),
              ],
              onSelected: (value) {
                if (value == 1) {
                  Duration remainingTime =
                      activeSession.expiresOn!.difference(DateTime.now());
                  _modifyTimeDialog(context, remainingTime.inMinutes,
                      activeSession.circle.maxMinutes);
                } else if (value == 2) {
                  _endSessionPrompt(context, ref);
                }
              },
            ),
          ]
        ],
      );
    } else {
      return Container();
    }
  }

  void _endSessionPrompt(BuildContext context, WidgetRef ref) async {
    FocusScope.of(context).unfocus();
    final t = AppLocalizations.of(context)!;
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(t.endSessionPrompt),
      content: Text(t.endSessionPromptMessage),
      actions: [
        TextButton(
          child: Text(t.endSession),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        TextButton(
          child: Text(t.cancel),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
    // show the dialog
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
    if (result) {
      final commProvider = ref.read(communicationsProvider);
      await commProvider.endSession();
    }
  }

  void _modifyTimeDialog(
      BuildContext context, int remainingMinutes, int maxMinutes) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      barrierColor: Theme.of(context).themeColors.blurBackground,
      builder: (_) => Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
          child: Center(
            child: SingleChildScrollView(
              child: DialogContainer(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: Theme.of(context).maxRenderWidth),
                  child: AddTimeDialog(
                    min: -1 * remainingMinutes.toDouble(),
                    max: maxMinutes.toDouble(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddTimeDialog extends ConsumerStatefulWidget {
  const AddTimeDialog({Key? key, required this.min, required this.max})
      : super(key: key);
  final double min, max;

  @override
  AddTimeDialogState createState() => AddTimeDialogState();
}

class AddTimeDialogState extends ConsumerState<AddTimeDialog> {
  late double _minutes;

  @override
  void initState() {
    super.initState();
    _minutes = 0;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;
    final textStyles = themeData.textStyles;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: themeData.pageHorizontalPadding),
            Expanded(
              child: Text(
                t.addMoreTime,
                style: textStyles.displayMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
        const SizedBox(height: 20),
        SizedBox(
          width: 150,
          child: SpinBox(
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            min: widget.min,
            max: widget.max,
            value: _minutes,
            onChanged: (value) {
              setState(() {
                _minutes = value;
              });
            },
          ),
        ),
        const SizedBox(height: 40),
        ThemedRaisedButton(
            label: t.done,
            onPressed: () {
              _modifySession();
              Navigator.of(context).pop();
            }),
      ],
    );
  }

  void _modifySession() async {
    var repo = ref.read(repositoryProvider);
    int minutes = _minutes.floor();
    if (minutes != 0) {
      await repo.addTimeToActiveSession(minutes: minutes);
    }
  }
}
