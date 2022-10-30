import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/components/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class ProfileImage extends ConsumerWidget {
  const ProfileImage({
    Key? key,
    this.size = 64,
    this.fillColor,
    this.textColor,
    this.textSize = 30,
    this.useIcon = true,
    this.localImageFile,
    this.localImagePath,
    this.shape = BoxShape.rectangle,
    this.profile,
    this.borderRadius,
  }) : super(key: key);
  final double size;
  final Color? fillColor;
  final Color? textColor;
  final double textSize;
  final bool useIcon;
  final File? localImageFile;
  final String? localImagePath;
  final BoxShape shape;
  final UserProfile? profile;
  final double? borderRadius;

  bool get hasLocalImage {
    return localImagePath != null || localImageFile != null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (profile == null) {
      final userProfileChanges = ref.watch(TotemRepository.userProfileProvider);
      return SizedBox(
        width: size,
        height: size,
        child: userProfileChanges.when(
          data: (userProfile) => (hasLocalImage)
              ? _localProfileImage(context)
              : _component(context, userProfile),
          loading: () => _userPlaceholder(context),
          error: (_, __) => _userPlaceholder(context),
        ),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: _component(context, profile),
    );
  }

  Widget _container(BuildContext context,
      {ImageProvider? imageProvider, Widget? child}) {
    final themeColors = Theme.of(context).themeColors;
    if (shape == BoxShape.rectangle) {
      return Container(
        decoration: imageProvider != null
            ? BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(borderRadius ?? size / 4)),
                image: DecorationImage(
                  image: ResizeImage(imageProvider, width: 168),
                  fit: BoxFit.contain,
                ),
              )
            : BoxDecoration(
                color: fillColor ?? themeColors.profileBackground,
                borderRadius:
                    BorderRadius.all(Radius.circular(borderRadius ?? size / 4)),
              ),
        child: child,
      );
    }
    return Container(
      decoration: imageProvider != null
          ? BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.contain,
              ),
            )
          : BoxDecoration(
              color: fillColor ?? themeColors.profileBackground,
              shape: shape,
            ),
      child: child,
    );
  }

  Widget _localProfileImage(BuildContext context) {
    if (localImageFile != null) {
      return _container(context, imageProvider: FileImage(localImageFile!));
    }
    return _container(context, imageProvider: NetworkImage(localImagePath!));
  }

  Widget _component(BuildContext context, UserProfile? userProfile) {
    return SizedBox(
        width: size,
        height: size,
        child: userProfile != null
            ? (!userProfile.hasImage
                ? _userPlaceholder(context, userProfile: userProfile)
                : CachedNetworkImage(
                    imageUrl: userProfile.image!,
                    imageBuilder: (context, imageProvider) =>
                        _container(context, imageProvider: imageProvider),
                    errorWidget: (context, url, error) =>
                        _userPlaceholder(context, userProfile: userProfile),
                    progressIndicatorBuilder: (context, _, __) => const Center(
                      child: BusyIndicator(
                        size: 30,
                      ),
                    ),
                  ))
            : null);
  }

  Widget _userPlaceholder(BuildContext context, {UserProfile? userProfile}) {
    final themeColors = Theme.of(context).themeColors;
    return _container(
      context,
      child: useIcon
          ? Center(
              child: Icon(LucideIcons.user,
                  size: 24, color: themeColors.primaryText),
            )
          : Text(
              userProfile?.userInitials ?? "",
              style: TextStyle(
                  color: textColor ?? themeColors.primaryText,
                  fontSize: textSize,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
    );
  }
}
