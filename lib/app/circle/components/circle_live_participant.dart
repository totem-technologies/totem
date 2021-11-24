import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleLiveParticipant extends StatelessWidget {
  const CircleLiveParticipant({Key? key, required this.participant})
      : super(key: key);
  final Participant participant;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;
    return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            if (!participant.userProfile.hasImage)
              Container(
                color: themeColors.primary.withAlpha(80),
              ),
            Positioned.fill(
              child: (participant.userProfile.hasImage)
                  ? _renderUserImage(context)
                  : _genericUserImage(context),
            ),
          ],
        ));
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
      size: 80,
      color: Theme.of(context).themeColors.primaryText,
    );
  }
}
