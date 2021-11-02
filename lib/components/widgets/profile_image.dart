import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class ProfileImage extends ConsumerWidget {
  const ProfileImage({Key? key, this.size = 100, this.fillColor, this.textColor, this.textSize = 30}) : super(key: key);
  final double size;
  final Color? fillColor;
  final Color? textColor;
  final double textSize;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final userProfileChanges = watch(TotemRepository.userProfileProvider);
    return SizedBox(
        width: size,
        height: size,
        child: userProfileChanges.when(
          data: (userProfile) => _component(context, userProfile),
          loading: () => _userInitials(context),
          error: (_, __) => _userInitials(context),
        ),
    );
  }

  Widget _component(BuildContext context, UserProfile? userProfile) {
    return SizedBox(
      width: size,
      height: size,
      child: userProfile != null ? (!userProfile.hasImage
          ? _userInitials(context, userProfile: userProfile)
          : CachedNetworkImage(
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
            _userInitials(context, userProfile: userProfile),
      )) : Container()
    );
  }

  Widget _userInitials(BuildContext context, {UserProfile? userProfile}) {
    final themeColors = Theme.of(context).themeColors;
    return CircleAvatar(
      backgroundColor: fillColor ?? themeColors.primary,
      child: Text(
        userProfile?.userInitials ?? "",
        style: TextStyle(color: textColor ?? themeColors.primaryText, fontSize: textSize, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        maxLines: 1,
      ),
    );
  }
}