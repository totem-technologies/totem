import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleParticipantVideo extends ConsumerStatefulWidget {
  const CircleParticipantVideo(
      {Key? key,
      required this.name,
      required this.role,
      this.me = false,
      required this.uid,
      this.image})
      : super(key: key);
  final String name;
  final bool me;
  final Role role;
  final int uid;
  final String? image;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CircleParticipantVideoState();
}

class _CircleParticipantVideoState
    extends ConsumerState<CircleParticipantVideo> {
  bool videoEnabled = true; // used to toggle video

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textStyles = themeData.textTheme;
    return ClipRRect(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          if (widget.me && videoEnabled) rtc_local_view.SurfaceView(),
          if (!widget.me && videoEnabled)
            rtc_remote_view.SurfaceView(
              uid: widget.uid,
            ),
          if (!videoEnabled) _renderUserImage(context),
          PositionedDirectional(
            child: Stack(
              children: [
                _gradientLayer(context),
                PositionedDirectional(
                  bottom: 0,
                  start: 0,
                  end: 0,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                    child: Text(
                      widget.name,
                      style: textStyles.headline5,
                    ),
                  ),
                ),
              ],
            ),
            bottom: 0,
            start: 0,
            end: 0,
          ),
          if (widget.me) renderMe(context),
          if (widget.role == Role.keeper && !widget.me)
            renderKeeperLabel(context)
        ],
      ),
    );
  }

  Widget renderMe(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    return PositionedDirectional(
      top: 0,
      start: 0,
      end: 0,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: themeColors.primary,
              borderRadius:
                  const BorderRadius.only(bottomRight: Radius.circular(16)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(
                    t.me,
                    style: textStyles.headline5!.merge(
                      TextStyle(
                        color: themeColors.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }

  Widget renderKeeperLabel(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    return PositionedDirectional(
      top: 0,
      start: 0,
      end: 0,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: themeColors.primaryText,
              borderRadius:
                  const BorderRadius.only(bottomRight: Radius.circular(16)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.star, color: themeColors.primary, size: 24),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(t.keeper, style: textStyles.headline5),
                ],
              ),
            ),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }

  Widget _renderUserImage(BuildContext context) {
    if (widget.image!.toLowerCase().contains("assets/")) {
      return Image.asset(
        widget.image!,
        fit: BoxFit.cover,
      );
    }
    return CachedNetworkImage(
      imageUrl: widget.image!,
      errorWidget: (context, url, error) => _genericUserImage(context),
    );
  }

  Widget _genericUserImage(BuildContext context) {
    return Icon(
      Icons.account_circle_rounded,
      size: 80,
      color: Theme.of(context).themeColors.primaryText,
    );
  }

  Widget _gradientLayer(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return Container(
      height: 45,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: themeColors.profileGradient,
        ),
      ),
    );
  }
}
