import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem/app/login/components/phone_register_number_header.dart';
import 'package:totem/components/widgets/themed_raised_button.dart';
import 'package:totem/services/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/providers.dart';
import 'package:totem/theme/index.dart';

class PhoneRegisterNumberError extends StatelessWidget {
  const PhoneRegisterNumberError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.read(authServiceProvider);
    final textTheme = Theme.of(context).textTheme;
    final themeColors = Theme.of(context).themeColors;
    final t = Localized.of(context).t;
    return Padding(
      padding: EdgeInsets.only(left: 35.w, right: 35.w),
      child: Column(
        children: [
          const PhoneRegisterNumberHeader(),
          Text(t('errorRegister'), style: textTheme.bodyText1!.merge(TextStyle(color: themeColors.error, fontWeight: FontWeight.bold))),
          SizedBox(height: 10.h,),
          Text(auth.lastRegisterError ?? t('errorRegisterUnknown')),
          SizedBox(height: 30.h,),
          ThemedRaisedButton(
            label: t('retrySignin'),
            onPressed: () {
              auth.resetAuthError();
            },
            width: 294.w,
          ),
        ],
      ),
    );
  }
}