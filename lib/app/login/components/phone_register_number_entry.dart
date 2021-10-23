import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/services/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/providers.dart';

class PhoneRegisterNumberEntry extends StatefulWidget {
  const PhoneRegisterNumberEntry({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PhoneRegisterNumberEntryState();
}

class _PhoneRegisterNumberEntryState extends State<PhoneRegisterNumberEntry> {

  final formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  String initialCountry = 'US';
  PhoneNumber numberController = PhoneNumber(isoCode: 'US');
  String error = '';

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final t = Localized.of(context).t;
    return Padding(
      padding: EdgeInsets.only(left: 35.w, right: 35.w),
      child: Column(
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
          ///Country Picker and textField
          Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    debugPrint(number.phoneNumber);
                  },
                  onInputValidated: (bool value) {
                    debugPrint("$value");
                  },
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    showFlags: true,
                    trailingSpace: false,
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  //selectorTextStyle: white16NormalTextStyle,
                  initialValue: numberController,
                  textFieldController: _phoneNumberController,
                  formatInput: false,
                  //textStyle: white16NormalTextStyle,
                  hintText: 'Phone Number',
                  //cursorColor: themeColors.,
                  inputDecoration: InputDecoration(
                    //hintStyle: white16NormalTextStyle,
                    hintText: t('phoneNumber'),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  onSaved: (PhoneNumber number) {
                    debugPrint('On Saved: $number');
                    numberController = number;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red),
                    maxLines: 2,
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                TotemContinueButton(
                  onButtonPressed: onSubmit,
                  buttonText: 'Submit',
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onSubmit(Function stop) async {
    var auth = context.read(authServiceProvider);
    setState(() => error = '');
    // Validate returns true if the form is valid, or false otherwise.
    if (formKey.currentState!.validate()) {
      var number = _phoneNumberController.text;
      if (!number.startsWith('+')) {
        if (number.length == 10) {
          // US user only input 10 digits
          number = '1' + number;
        }
        number = '+' + number;
      }
      debugPrint(number);
      try {
        await auth.signInWithPhoneNumber(number);
        stop();
/*        if (result == AuthRequestState.complete) {
          // trigger done, navigate to
          debugPrint('Auth completed successfully');
          await Navigator.pushNamedAndRemoveUntil(
              context, '/login/guideline', (Route<dynamic> route) => false);
        } else if (result == AuthRequestState.pending) {
          // switch to the display of the code
          // FIXME - this should change to be a state in this view rather
          // than another route
          Navigator.pushNamed(context, '/login/phone/code');
        } */
      } on AuthException catch (e) {
        stop();
        debugPrint(e.message?? "unknown error");
        setState(() => error = e.message ?? '');
      }
    } else {
      stop();
    }
  }

}