import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleLiveParticipant extends StatelessWidget {
  const CircleLiveParticipant({Key? key, required this.participant})
      : super(key: key);
  final SessionParticipant participant;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;
    return Column(
      children: [
        if (!participant.totem) const SizedBox(height: 8),
        SizedBox(
          height: participant.totem ? 72 : 64,
          width: participant.totem ? 72 : 64,
          child: Container(
            decoration: BoxDecoration(
              color: themeColors.trayBackground,
              boxShadow: [
                BoxShadow(
                    color: themeColors.shadow,
                    offset: Offset(0, participant.totem ? 4 : 2),
                    blurRadius: 4),
              ],
              border: Border.all(
                  color: themeColors.primary,
                  width: participant.totem ? 2.0 : 0),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: (!participant.userProfile.hasImage)
                ? Container(
                    color: themeColors.primary.withAlpha(80),
                    child: _genericUserImage(context),
                  )
                : Positioned.fill(
                    child: _renderUserImage(context),
                  ),
          ),
        )
      ],
    );
  }

  Widget _renderUserImage(BuildContext context) {
    if (participant.userProfile.image!.toLowerCase().contains("assets/")) {
      return Image.asset(
        participant.userProfile.image!,
        fit: BoxFit.cover,
      );
    }
    return CachedNetworkImage(
      imageUrl: participant.userProfile.image!,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      errorWidget: (context, url, error) => _genericUserImage(context),
    );
  }

  Widget _genericUserImage(BuildContext context) {
    return Icon(
      Icons.account_circle_rounded,
      size: participant.totem ? 60 : 50,
      color: Theme.of(context).themeColors.primaryText,
    );
  }
}
