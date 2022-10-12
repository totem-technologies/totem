import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:totem/components/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class ThemeItem extends StatelessWidget {
  const ThemeItem(
      {super.key,
      required this.theme,
      required this.onTap,
      this.selected = false});
  final CircleTheme theme;
  final Function(CircleTheme) onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return InkWell(
      onTap: () => onTap(theme),
      child: Row(
        children: [
          SizedBox(
              width: 30,
              child: selected
                  ? Icon(Icons.check_circle, color: themeColors.primaryText)
                  : null),
          const SizedBox(width: 10),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: themeColors.altBackground,
              shape: BoxShape.circle,
              border: Border.all(
                color: themeColors.divider,
                width: 1,
              ),
            ),
            child: CachedNetworkImage(
              imageUrl: theme.image,
              fit: BoxFit.cover,
              imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.contain,
                ),
              )),
              progressIndicatorBuilder: (context, _, __) => const Center(
                child: BusyIndicator(
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  theme.name,
                  style: Theme.of(context).textStyles.headline3,
                ),
                if (theme.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      theme.description,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
