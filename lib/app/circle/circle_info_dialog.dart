import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/app/circle/components/circle_error_loading.dart';
import 'package:totem/app/circle/components/circle_loading.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';

import 'circle_session_page.dart';

class CircleInfoDialog extends ConsumerStatefulWidget {
  const CircleInfoDialog(
      {Key? key, required this.circleId, this.cropEnabled = false})
      : super(key: key);
  final String circleId;
  final bool cropEnabled;

  static Future<Circle?> showCircleInfo(BuildContext context,
      {required String circleId}) async {
    return DeviceType.isPhone()
        ? showModalBottomSheet<Circle?>(
            enableDrag: false,
            isScrollControlled: true,
            isDismissible: false,
            context: context,
            backgroundColor: Colors.transparent,
            barrierColor: Theme.of(context).themeColors.blurBackground,
            builder: (_) => CircleInfoDialog(
              circleId: circleId,
            ),
          )
        : showDialog<Circle?>(
            context: context,
            barrierColor: Theme.of(context).themeColors.blurBackground,
            barrierDismissible: false,
            builder: (BuildContext context) => CircleInfoDialog(
              circleId: circleId,
            ),
          );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CircleInfoDialogState();
}

class _CircleInfoDialogState extends ConsumerState<CircleInfoDialog> {
  @override
  void initState() {
    ref.read(analyticsProvider).showScreen('circle_info_dialog');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circleProviderData = ref.watch(circleProvider(widget.circleId));
    return Material(
      color: Colors.transparent,
      child: DeviceType.isPhone()
          ? BackdropFilter(
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
                    padding: EdgeInsets.zero,
                    child: _circleContent(
                        circleProvider: circleProviderData,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal:
                                Theme.of(context).pageHorizontalPadding)),
                  ),
                ),
              ),
            )
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
              child: Center(
                child: SingleChildScrollView(
                  child: DialogContainer(
                    padding: EdgeInsets.zero,
                    child: _circleContent(circleProvider: circleProviderData),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _circleHeader(Circle circle) {
    final themeColors = Theme.of(context).themeColors;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (circle.bannerImageUrl != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 100),
                child: CachedNetworkImage(
                  fit: BoxFit.fitWidth,
                  imageUrl: circle.bannerImageUrl!,
                  progressIndicatorBuilder: (context, _, __) => const Center(
                    child: BusyIndicator(
                      size: 30,
                    ),
                  ),
                ),
              ),
            if (circle.bannerImageUrl == null)
              Container(
                height: 100,
                color: themeColors.circleColors[
                    circle.colorIndex % themeColors.circleColors.length],
              ),
            const SizedBox(height: 20),
          ],
        ),
        Positioned(
          right: 10,
          top: 10,
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
              child: DecoratedIcon(
                LucideIcons.x,
                size: 24,
                color: themeColors.reversedText,
                shadows: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: Offset.zero,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _circleContent(
      {required AsyncValue<Circle?> circleProvider,
      EdgeInsetsGeometry contentPadding = EdgeInsets.zero}) {
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textStyles;
    final t = AppLocalizations.of(context)!;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 800,
      ),
      child: circleProvider.when(
        data: (Circle? circle) {
          if (circle != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _circleHeader(circle),
                Padding(
                  padding: contentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        circle.name,
                        style: textStyles.headline2,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: _joinStatus(circle),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: Theme.of(context).maxRenderWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _scheduleInfo(circle),
                              const SizedBox(height: 20),
                              if (circle.description != null) ...[
                                Text(
                                  circle.description!,
                                ),
                                const SizedBox(height: 20),
                              ],
                              _iconDataRow(
                                  circle.isPrivate
                                      ? LucideIcons.lock
                                      : LucideIcons.unlock,
                                  circle.isPrivate ? t.private : t.public),
                              _iconDataRow(LucideIcons.users,
                                  t.attendeeLimit(circle.maxParticipants))
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: themeColors.divider,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: Theme.of(context).maxRenderWidth),
                          child: _keeperInfo(circle),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const CircleErrorLoading();
        },
        error: (Object error, StackTrace? stackTrace) {
          return const CircleErrorLoading();
        },
        loading: () {
          return const CircleLoading();
        },
      ),
    );
  }

  Widget _iconDataRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 30,
        ),
        const SizedBox(width: 10),
        Text(
          label,
        ),
      ],
    );
  }

  Widget _scheduleInfo(Circle circle) {
    final t = AppLocalizations.of(context)!;
    final DateFormat timeFormat = DateFormat('hh:mm a');
    DateTime start = circle.createdOn;
    String? time;
    String sessionType = t.instantSession;
    String startTime = timeFormat.format(start);
    if (circle.nextSession != null) {
      start = circle.nextSession!;
      startTime = timeFormat.format(start);
      sessionType = t.scheduledSession;
      DateTime ends = start.add(Duration(minutes: circle.maxMinutes));
      String endTime = timeFormat.format(ends);
      time = t.circleTimeRange(startTime, endTime);
    } else {
      time = startTime;
    }
    if (circle.isComplete) {
      time = t.sessionsCompleted;
      startTime = "";
    }
    String repeatType = t.doesNotRepeat;
    if (circle.repeating != null) {
      sessionType = t.repeatingSession;
      repeatType = circle.repeating!.toLocalizedString(t);
    }
    return Center(
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(LucideIcons.calendarDays,
                    size: 40, color: Theme.of(context).themeColors.primaryText),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (startTime.isNotEmpty)
                        Text(
                          DateFormat.yMMMMEEEEd().format(start),
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (time.isNotEmpty) ...[
                        SizedBox(height: startTime.isNotEmpty ? 3 : 0),
                        Text(
                          time,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 30,
          ),
          Expanded(
            child: Row(
              children: [
                Icon(LucideIcons.rotateCw,
                    size: 40, color: Theme.of(context).themeColors.primaryText),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        sessionType,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        repeatType,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _keeperInfo(Circle circle) {
    final textStyles = Theme.of(context).textStyles;
    final t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.hostedBy, style: textStyles.headline4),
        const SizedBox(height: 10),
        Row(
          children: [
            ProfileImage(
              profile: circle.createdBy,
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text(circle.createdBy?.name ?? '',
                    style: textStyles.headline3)),
          ],
        )
      ],
    );
  }

  Widget _joinStatus(Circle circle) {
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textStyles;
    final authUser = ref.read(authStateChangesProvider).asData?.value;
    if (circle.bannedParticipants != null &&
        circle.bannedParticipants!.keys.contains(authUser!.uid)) {
      return Text(
        t.errorLoadingCircleBanned,
        style: textStyles.headline3,
      );
    }
    final List<SessionState> validStates = [
      SessionState.waiting,
      SessionState.starting,
      SessionState.live,
      SessionState.expiring,
    ];
    if (validStates.contains(circle.state)) {
      return ThemedRaisedButton(
        onPressed: () {
          _join(circle);
        },
        label: t.joinCircle,
      );
    }
    // if the user is the keeper of this circle, provide the option to restart
    // the circle if it is not a scheduled circle
    if (circle.createdBy?.uid == authUser?.uid && circle.nextSession == null) {
      return ThemedRaisedButton(
        onPressed: () {
          //_restart(circle);
        },
        label: t.restartCircle,
      );
    }
    return Text(
      t.circleNotInSession,
      style: textStyles.headline3,
    );
  }

  void _join(Circle circle) {
    Navigator.of(context).pop(circle);
  }
}
