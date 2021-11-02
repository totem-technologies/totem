import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class CircleParticipant extends StatelessWidget {
  const CircleParticipant({Key? key, required this.userProfile, this.role = Roles.member}) : super(key: key);
  final UserProfile userProfile;
  final String role;

  @override
  Widget build(BuildContext context) {
    final t = Localized.of(context).t;
    final themeData = Theme.of(context);
    final textStyles = themeData.textTheme;
    final themeColors = themeData.themeColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Container(
            color: themeColors.primary,
          ),
          Positioned.fill(
              child: (userProfile.hasImage) ? _renderUserImage(context) : _genericUserImage(context),
          ),
          PositionedDirectional(
            child: Stack(
              children: [
                _gradientLayer(context),
                PositionedDirectional(
                  bottom: 0,
                  start: 0,
                  end: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                    child: Text(userProfile.name, style: textStyles.headline5),
                  ),
                ),
              ],
            ),
            bottom: 0,
            start: 0,
            end: 0,
          ),
          if (role == Roles.keeper) PositionedDirectional(top: 0, start: 0, end: 0, child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: themeColors.primaryText,
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(16)
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: themeColors.primary, size: 24),
                      const SizedBox(width: 4,),
                      Text(t(role), style: textStyles.headline5),
                    ],
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
          )
        ],
      )
    );
  }

  Widget _renderUserImage(BuildContext context) {
    if (userProfile.image!.toLowerCase().contains("assets/")) {
      return Image.asset(userProfile.image!, fit: BoxFit.cover,);
    }
    return CachedNetworkImage(
      imageUrl: userProfile.image!,
      imageBuilder: (context, imageProvider) =>
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
      errorWidget: (context, url, error) =>
          _genericUserImage(context),
    );
  }

  Widget _genericUserImage(BuildContext context) {
    return Icon(Icons.account_circle_rounded, size: 30, color: Theme.of(context).themeColors.primaryText,);
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