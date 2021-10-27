import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/services/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/providers.dart';
import 'package:totem/theme/index.dart';

class PhoneRegisterNumberHeader extends StatelessWidget {
  const PhoneRegisterNumberHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final themeColors = Theme.of(context).themeColors;
    final t = Localized.of(context).t;
    return Column(
      children: [
        SizedBox(
          height: 40.h,
        ),
        Text(
          'Signup',
          style: textTheme.headline1,
        ),
        SizedBox(height: 8.h),
        const Center(
          child: ContentDivider(),
        ),
        SizedBox(height: 20.h,),
        Text(
            t('enterPhonePrompt'),
            style: textTheme.bodyText1!.merge(const TextStyle(fontWeight: FontWeight.w600))
        ),
        SizedBox(
          height: 10.h,
        ),
        Text(t('enterPhonePromptDetail'),),
        SizedBox(
          height: 90.h,
        ),
      ],
    );
  }
}