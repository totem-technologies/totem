import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class TopicItem extends StatelessWidget {
  const TopicItem({Key? key, required this.topic, required this.onPressed}) : super(key: key);
  final Topic topic;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
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
                    color: themeColors.shadow, offset: const Offset(0, -8), blurRadius: 24),
              ],
              border: Border.all(
                  color: themeColors.itemBorder,
                  width: 1.0
              ),
              borderRadius: BorderRadius.all( Radius.circular(16.h))
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 24.w, child: SvgPicture.asset('assets/alert.svg')), // FIXME - this is some indicator icon
                    SizedBox(width: 4.w,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          Text(topic.title, style: textStyles.headline3),
                          SizedBox(height: 12.h),
                          Text(topic.description, style: textStyles.headline4,)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w,),
              SvgPicture.asset('assets/arrow_next.svg'),
            ],
          ),
        ),
      ),
    );
  }
}
