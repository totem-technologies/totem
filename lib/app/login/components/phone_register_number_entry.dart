import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:totem/app/login/components/phone_register_number_header.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/services/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/theme/index.dart';

class PhoneRegisterNumberEntry extends ConsumerStatefulWidget {
  const PhoneRegisterNumberEntry({Key? key}) : super(key: key);

  @override
  _PhoneRegisterNumberEntryState createState() =>
      _PhoneRegisterNumberEntryState();
}

class _PhoneRegisterNumberEntryState
    extends ConsumerState<PhoneRegisterNumberEntry> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  String initialCountry = 'US';
  PhoneNumber numberController = PhoneNumber(isoCode: 'US');
  bool _busy = false;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(left: 35, right: 35),
      child: Column(
        children: [
          const PhoneRegisterNumberHeader(),

          ///Country Picker and textField
          Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InternationalPhoneNumberInput(
                  autoFocus: true,
                  onInputChanged: (PhoneNumber number) {
                    debugPrint(number.phoneNumber);
                  },
                  onInputValidated: (bool value) {
                    debugPrint("$value");
                  },
                  selectorConfig: const SelectorConfig(
                    setSelectorButtonAsPrefixIcon: true,
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    showFlags: true,
                    trailingSpace: false,
                  ),
                  ignoreBlank: false,
                  initialValue: numberController,
                  textFieldController: _phoneNumberController,
                  //formatInput: true,
                  hintText: t.phoneNumber,
                  errorMessage: t.errorInvalidPhoneNumber,
                  inputDecoration: InputDecoration(
                    hintText: t.phoneNumber,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: themeColors.primaryText),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: themeColors.primaryText),
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: themeColors.primaryText),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  onSaved: (PhoneNumber number) {
                    debugPrint('On Saved: $number');
                    numberController = number;
                  },
                ),
                const SizedBox(height: 30),
                ThemedRaisedButton(
                  label: t.sendCode,
                  busy: _busy,
                  onPressed: onSubmit,
                  width: 294,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onSubmit() async {
    var auth = ref.read(authServiceProvider);
    // Validate returns true if the form is valid, or false otherwise.
    if (formKey.currentState!.validate()) {
      setState(() => _busy = true);
      var number =
          _phoneNumberController.text.replaceAll(RegExp(r'[^0-9]'), "");
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
      } on AuthException catch (e) {
        debugPrint(e.message ?? "unknown error");
        setState(() => _busy = false);
      }
    } else {
      setState(() => _busy = false);
    }
  }
}
