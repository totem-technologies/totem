import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CirclePage extends StatelessWidget {
  const CirclePage({Key? key, required this.topic}) : super(key: key);
  final Topic topic;

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final themeColors = Theme.of(context).themeColors;
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 24.w,),
                  Expanded(
                    child: Text(topic.title, style: textStyles.headline2),
                  ),
                  IconButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.close, color: themeColors.primaryText,),
                  ),
                  SizedBox(width: 8.w,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}