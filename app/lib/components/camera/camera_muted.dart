import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/theme/index.dart';

class CameraMuted extends StatelessWidget {
  const CameraMuted({Key? key, this.userImage, this.imageSize = 40, this.color})
      : super(key: key);
  final String? userImage;
  final double imageSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: themeColors.cameraBorder, width: 1),
            color: const Color(0xff959595),
          ),
          child: (userImage != null && userImage!.isNotEmpty)
              ? Stack(children: [
                  (userImage!.contains('http')
                      ? Image.network(
                          userImage!,
                          fit: BoxFit.cover,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                        )
                      : Image.asset(
                          userImage!,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          fit: BoxFit.cover,
                        )),
                  Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    color: Colors.black26,
                  ),
                ])
              : Align(
                  alignment: Alignment.center,
                  child: Icon(LucideIcons.user,
                      size: imageSize, color: color ?? themeColors.primaryText),
                ),
        );
      },
    );
  }
}
