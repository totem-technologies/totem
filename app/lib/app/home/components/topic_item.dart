import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class TopicItem extends StatelessWidget {
  const TopicItem({super.key, required this.topic, required this.onPressed});
  final Topic topic;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;
    final textStyles = themeData.textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 8.0, horizontal: themeData.pageHorizontalPadding),
      child: InkWell(
        onTap: () {
          onPressed(topic);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
          decoration: BoxDecoration(
              color: themeColors.itemBackground,
              boxShadow: [
                BoxShadow(
                    color: themeColors.shadow,
                    offset: const Offset(0, -8),
                    blurRadius: 24),
              ],
              border: Border.all(color: themeColors.itemBorder, width: 1.0),
              borderRadius: const BorderRadius.all(Radius.circular(16))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.alertCircle,
                      size: 24,
                      color: themeColors.error,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(topic.title, style: textStyles.displaySmall),
                          const SizedBox(height: 12),
                          Text(
                            topic.description,
                            style: textStyles.headlineMedium,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Icon(LucideIcons.arrowRight,
                  size: 24, color: themeData.themeColors.iconNext),
            ],
          ),
        ),
      ),
    );
  }
}
