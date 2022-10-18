import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';

final circleProvider =
    StreamProvider.autoDispose.family<SnapCircle?, String>((ref, circleId) {
  final repo = ref.read(repositoryProvider);
  return repo.snapCircleStream(circleId);
});

class CircleInfoDialog extends ConsumerStatefulWidget {
  const CircleInfoDialog(
      {Key? key, required this.circleId, this.cropEnabled = false})
      : super(key: key);
  final String circleId;
  final bool cropEnabled;

  static Future<SnapCircle?> showCircleInfo(BuildContext context,
      {required String circleId}) async {
    return DeviceType.isPhone()
        ? showModalBottomSheet<SnapCircle?>(
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
        : showDialog<SnapCircle?>(
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
    if (circle.bannerImageUrl != null) {
      return Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                  Icons.close,
                  size: 24,
                  color: themeColors.reversedText,
                  shadows: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 10,
                      spreadRadius: 5,
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
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        right: 20,
        left: 20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
              child: Icon(
                Icons.close,
                size: 24,
                color: themeColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleContent(
      {required AsyncValue<SnapCircle?> circleProvider,
      EdgeInsetsGeometry contentPadding = EdgeInsets.zero}) {
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textStyles;
    final t = AppLocalizations.of(context)!;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 800,
      ),
      child: circleProvider.when(
        data: (SnapCircle? circle) {
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
                                      ? Icons.lock_rounded
                                      : Icons.lock_open_rounded,
                                  circle.isPrivate ? t.private : t.public),
                              _iconDataRow(Icons.people_rounded,
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
          return _errorCircle();
        },
        error: (Object error, StackTrace? stackTrace) {
          return _errorCircle();
        },
        loading: () {
          return ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 250),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  AppLocalizations.of(context)!.loadingCircle,
                  style: Theme.of(context).textTheme.headline3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30,
                ),
                const BusyIndicator(),
                const SizedBox(height: 40),
              ],
            ),
          );
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

  Widget _scheduleInfo(SnapCircle circle) {
    final t = AppLocalizations.of(context)!;
    return Center(
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded,
                    size: 40, color: Theme.of(context).themeColors.primaryText),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        DateFormat.yMMMMEEEEd().format(circle.createdOn),
                        overflow: TextOverflow.ellipsis,
                      ),
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
                Icon(Icons.refresh_rounded,
                    size: 40, color: Theme.of(context).themeColors.primaryText),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.instantSession,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        t.doesNotRepeat,
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

  Widget _keeperInfo(SnapCircle circle) {
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

  Widget _joinStatus(SnapCircle circle) {
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
      SessionState.live
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

  void _join(SnapCircle circle) {
    Navigator.of(context).pop(circle);
  }

  Widget _errorCircle() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 250),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.error,
                size: 40, color: Theme.of(context).themeColors.error),
            const SizedBox(
              height: 20,
            ),
            Text(
              AppLocalizations.of(context)!.errorLoadingCircle,
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ThemedRaisedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              label: AppLocalizations.of(context)!.ok,
            ),
          ],
        ),
      ),
    );
  }
}
