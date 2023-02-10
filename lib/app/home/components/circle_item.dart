import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/error_report.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class CircleItem extends ConsumerWidget {
  static const double maxFullInfoWidth = 250;
  const CircleItem({
    Key? key,
    required this.circle,
    required this.onPressed,
  }) : super(key: key);
  final Circle circle;
  final Function onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final themeColor = Theme.of(context).themeColors;
    final textStyles = themeData.textTheme;

    AuthUser? user = ref.read(authServiceProvider).currentUser();
    bool canCancel = user != null &&
        circle.isPending &&
        (user.hasRole(Role.admin) ||
            circle.participantRole(user.uid) == Role.keeper);

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 8.0, horizontal: themeData.pageHorizontalPadding),
      child: InkWell(
        hoverColor: Colors.transparent,
        onTap: () {
          onPressed(circle);
        },
        child: Stack(children: [
          ListItemContainer(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: circle.description != null &&
                                circle.description!.isNotEmpty
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: CircleImage(
                              circle: circle,
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text(
                                  circle.name,
                                  style: textStyles.displaySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                if (circle.description != null &&
                                    circle.description!.isNotEmpty) ...[
                                  Text(
                                    circle.description!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                ],
                                if (circle.createdBy != null) ...[
                                  Text(
                                    t.createdBy(circle.createdBy!.name),
                                    style: TextStyle(
                                        color: themeColor.primaryText,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (circle.state == SessionState.waiting)
                        _sessionInfo(context),
                      if (circle.state == SessionState.scheduled)
                        _scheduledSessionInfo(context)
                    ],
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Icon(LucideIcons.arrowRight,
                    size: 24, color: themeData.themeColors.iconNext),
              ],
            ),
          ),
          if (canCancel)
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                icon: Icon(
                  LucideIcons.trash,
                  size: 12,
                  color: themeData.themeColors.error,
                ),
                onPressed: () {
                  _promptCancel(context, ref);
                },
              ),
            ),
        ]),
      ),
    );
  }

  Widget _sessionInfo(BuildContext context) {
    //final timeFormat = DateFormat.Hm();
    final t = AppLocalizations.of(context)!;
    String status = "";
    switch (circle.state) {
      case SessionState.live:
        status = t.sessionInProgress;
        break;
      case SessionState.waiting:
        status = t.sessionWaiting;
        break;
      default:
        break;
    }
    final themeColor = Theme.of(context).themeColors;
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(
            height: 5,
            thickness: 1,
            color: themeColor.divider,
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Text(
                t.participantCount(circle.participantCount),
              ),
              Expanded(
                child: constraints.maxWidth > maxFullInfoWidth
                    ? Text(
                        status,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.end,
                      )
                    : Container(),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _scheduledSessionInfo(BuildContext context) {
    final DateFormat timeFormat = DateFormat('hh:mm a');
    final t = AppLocalizations.of(context)!;
    final themeColor = Theme.of(context).themeColors;
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(
            height: 5,
            thickness: 1,
            color: themeColor.divider,
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (circle.nextSession != null)
                Text(
                    '${DateFormat.yMMMMEEEEd().format(circle.nextSession!)} @ ${timeFormat.format(circle.nextSession!)}'),
              if (circle.repeating != null &&
                  ((circle.repeating!.count ?? 0) > 1))
                Text(
                  t.repeats,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.end,
                ),
            ],
          ),
        ],
      );
    });
  }

  void _promptCancel(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    // set up the AlertDialog
    final actions = [
      TextButton(
        child: Text(t.endSession),
        onPressed: () {
          Navigator.of(context).pop("leave");
        },
      ),
      TextButton(
        child: Text(t.cancel),
        onPressed: () {
          Navigator.of(context).pop("cancel");
        },
      ),
    ];

    AlertDialog alert = AlertDialog(
      title: Text(t.endSessionPrompt),
      content: Text(t.endSessionPromptMessage),
      actions: actions,
    );
    // show the dialog
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
    if (result != "cancel") {
      return _cancelCircle(ref);
    }
  }

  void _cancelCircle(WidgetRef ref) async {
    var repo = ref.read(repositoryProvider);
    try {
      await repo.cancelPendingSession(circle: circle);
    } on ServiceException catch (ex, stack) {
      debugPrint('Error creating circle: $ex');
      await reportError(ex, stack);
    }
  }
}
