import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';
import 'package:totem/app/home/components/index.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Localized.of(context).t;
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textTheme;
    return GradientBackground(
      gradient: themeColors.secondaryGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
          body: SafeArea(
            top: true,
            bottom: false,
            child: Stack(
              children: [
                SvgPicture.asset('assets/home_background.svg', fit: BoxFit.fill,),
                Positioned.fill(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: TotemHeader(text: t('home')),),
                              InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: SvgPicture.asset('assets/profile.svg'),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, '/settings');
                                },
                              )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 24.w, top: 8.h, bottom: 24.h),
                            child: Text(t('circles'), style: textStyles.headline2,),
                          ),
                          const Expanded(child: TopicsList()),
                        ],
                    ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomTrayContainer(
                    child: Center(
                      child: ThemedRaisedButton(
                        height: 52.h,
                        onPressed: () {
                          // build new circle
                        },
                        padding: EdgeInsets.symmetric(horizontal: 42.w),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              t('createCircle'),
                            ),
                            SizedBox(width: 12.w,),
                            Icon(Icons.add)
                          ],
                        )
                      )
                    )
                  )
                )
              ],
            )
          ),
      ),
    );
  }
}
