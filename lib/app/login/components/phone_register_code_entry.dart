import 'package:flutter/material.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/theme/index.dart';
import 'package:totem/app/providers.dart';
import 'package:totem/app/login/components/pin_code_widget.dart';
import 'package:totem/services/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhoneRegisterCodeEntry extends StatefulWidget {
  const PhoneRegisterCodeEntry({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PhoneRegisterCodeEntryState();
}

final errors = {'invalid-verification-code': 'Invalid code. Please try again.'};

class _PhoneRegisterCodeEntryState extends State<PhoneRegisterCodeEntry> {
  final _formKey = GlobalKey<FormState>();
  final AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  String pinValue = '';
  String error = '';
  bool _busy = false;

  ///Validates OTP code
  void signInWithPhoneNumber() async {
    setState(() => _busy = true);
    try {
      await context.read(authServiceProvider).verifyCode(pinValue);
      setState(() => _busy = false);
      await Navigator.pushReplacementNamed(context, '/login/guideline',);
    } on AuthException catch (e) {
      setState(() {
        error = e.message!;
        _busy = false;
      });
      debugPrint('Error:$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Localized.of(context).t;
    final textStyles = Theme.of(context).textTheme;
    final themeColors = Theme.of(context).themeColors;
    return Padding(
      padding: EdgeInsets.only(left: 35.w, right: 35.w),
      child: Column(
        children: [
          SizedBox(
            height: 40.h,
          ),
          Text(t('signup'), style: textStyles.headline1),
          const ContentDivider(),
          SizedBox(
            height: 20.h,
          ),
          Text(
            t('enterCode'),
            style: textStyles.bodyText1!.merge(const TextStyle(fontWeight: FontWeight.w600)),
          ),
          SizedBox( height: 8.h),
          Text(
            t('enterTheCodeDetail'),
            style: textStyles.bodyText1!,
          ),
          SizedBox(
            height: 90.h,
          ),

          ///OTP textFields
          Form(
            key: _formKey,
            autovalidateMode: _autoValidate,
            child: PinCodeWidget(
              onChanged: (v) {
                setState(() => error = '');
                pinValue = v;
              },
              onComplete: (v) {
                pinValue = v;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              error,
              style: TextStyle(color: themeColors.error),
              maxLines: 2,
            ),
          ),
          SizedBox(
            height: 80.h,
          ),
          ThemedRaisedButton(
            label: t('getStarted'),
            busy: _busy,
            width: 294.w,
            onPressed: pinValue.length == 6 && int.tryParse(pinValue) != null ? () {
              signInWithPhoneNumber();
            } : null,
          ),
        ],
      ),
    );
  }
}
