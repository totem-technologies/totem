import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class ParticipantRoundedRectImage extends StatelessWidget {
  const ParticipantRoundedRectImage({
    Key? key,
    this.userProfile,
    required this.participant,
    this.size = 64,
    this.borderRadius = 12,
  }) : super(key: key);
  final UserProfile? userProfile;
  final SessionParticipant participant;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      child: (userProfile == null || !userProfile!.hasImage)
          ? Container(
              color: participant.me
                  ? themeColors.primary.withAlpha(80)
                  : themeColors.profileBackground,
              child: _genericUserImage(context),
            )
          : _renderUserImage(context),
    );
  }

  Widget _renderUserImage(BuildContext context) {
    if (userProfile!.image!.toLowerCase().contains("assets/")) {
      return Image.asset(
        participant.sessionImage!,
        fit: BoxFit.cover,
      );
    }
    return CachedNetworkImage(
      imageUrl: userProfile!.image!,
      errorWidget: (context, url, error) => _genericUserImage(context),
    );
  }

  Widget _genericUserImage(BuildContext context) {
    return const Center(
      child: Icon(Icons.person_outline, size: 24),
    );
  }
}
