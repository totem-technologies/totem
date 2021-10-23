import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem/components/constants.dart';
import 'package:totem/components/widgets/buttons.dart';
import 'package:totem/components/widgets/content_divider.dart';
import 'package:totem/components/widgets/gradient_background.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class GuidelineScreen extends StatelessWidget {
  const GuidelineScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Localized.of(context).t;
    final textStyles = Theme.of(context).textTheme;
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: 35.w, right: 35.w, top: 40.h, bottom: 150.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t('guidelinesHeader'),
                      style: textStyles.headline1,
                      textAlign: TextAlign.center,
                    ),
                    const Center(child: ContentDivider()),
                    SizedBox(height: 24.h),
                    Text('Last Time Updated: May 12,2021',
                           style: textStyles.bodyText1!.merge(const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Text( t('guidelines'),
                      style: textStyles.bodyText1,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                // Clip it cleanly.
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 150.h,
                    padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.w),
                            topRight: Radius.circular(30.w))),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        TotemButton(
                          buttonText: 'Accept Guidelines',
                          onButtonPressed: (stop) {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/home', (route) => false);
                          },
                        ),
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  size: 30.w,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 9.w,
                                ),
                                Text(
                                  'Back',
                                  style: white16BoldTextStyle,
                                )
                              ],
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      ),
    );
  }
}
