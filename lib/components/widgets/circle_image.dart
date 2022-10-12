import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:totem/components/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleImage extends StatelessWidget {
  const CircleImage({super.key, required this.circle, this.size = 60});

  final Circle circle;
  final double size;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    if (circle.imageUrl != null && circle.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: circle.imageUrl!,
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
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: themeColors
            .circleColors[circle.colorIndex % themeColors.circleColors.length],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          circle.name.substring(0, 1).toUpperCase(),
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
