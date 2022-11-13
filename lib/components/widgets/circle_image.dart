import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/components/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleImage extends StatelessWidget {
  const CircleImage({super.key, this.circle, this.size = 60});

  final CircleTemplate? circle;
  final double size;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    if (circle?.imageUrl != null && circle!.imageUrl!.isNotEmpty) {
      return SizedBox(
        height: size,
        width: size,
        child: CachedNetworkImage(
          imageUrl: circle!.imageUrl!,
          imageBuilder: (context, imageProvider) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          progressIndicatorBuilder: (context, _, __) => SizedBox(
            width: size,
            child: Center(
              child: BusyIndicator(
                size: size / 2,
              ),
            ),
          ),
        ),
      );
    }
    final t = AppLocalizations.of(context)!;
    final CircleTemplate template = circle ??
        CircleTemplate.fromJson({'name': t.newCircleTemplate}, id: "");
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: themeColors.circleColors[
            template.colorIndex % themeColors.circleColors.length],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          template.name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: themeColors.reversedText,
            fontSize: size / 2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
