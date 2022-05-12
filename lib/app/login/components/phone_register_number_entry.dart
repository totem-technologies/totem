import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totem/app/login/components/phone_register_number_header.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class PhoneRegisterNumberEntry extends ConsumerStatefulWidget {
  const PhoneRegisterNumberEntry({Key? key}) : super(key: key);

  @override
  PhoneRegisterNumberEntryState createState() =>
      PhoneRegisterNumberEntryState();
}

class PhoneRegisterNumberEntryState
    extends ConsumerState<PhoneRegisterNumberEntry> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  PhoneNumber numberController = PhoneNumber(isoCode: 'US');
  bool _busy = false;

  @override
  void initState() {
    _initISOCode();
    super.initState();
  }

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
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: Theme.of(context).maxRenderWidth),
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
                    autofillHints: const [
                      AutofillHints.telephoneNumberNational
                    ],
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
                    keyboardType: TextInputType.phone,
                    onSaved: (PhoneNumber number) {
                      debugPrint('On Saved: $number');
                      numberController = number;
                    },
                    onFieldSubmitted: (value) {
                      onSubmit();
                    },
                  ),
                  const SizedBox(height: 30),
                  ThemedRaisedButton(
                    label: t.sendCode,
                    busy: _busy,
                    onPressed: onSubmit,
                    width: Theme.of(context).standardButtonWidth,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initISOCode() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? number = ref.read(authServiceProvider).authRequestNumber;
      // if there is a cached previously used value for ISO, use that
      String? initialCountry = prefs.getString('lastIso');
      if (initialCountry != null) {
        setState(() {
          numberController =
              PhoneNumber(isoCode: initialCountry, phoneNumber: number);
        });
      } else {
        // try reading from sim card
        if (!kIsWeb) {
          String? platformVersion = await FlutterSimCountryCode.simCountryCode;
          if (platformVersion != null && platformVersion.isNotEmpty) {
            setState(() {
              numberController = PhoneNumber(
                  isoCode: platformVersion.toUpperCase(), phoneNumber: number);
            });
          }
        }
      }
    } on PlatformException catch (e) {
      debugPrint('Error loading iso code: ${e.toString()}');
    }
  }

  void onSubmit() async {
    var auth = ref.read(authServiceProvider);
    // Validate returns true if the form is valid, or false otherwise.
    if (formKey.currentState!.validate()) {
      setState(() => _busy = true);
      formKey.currentState!.save();

      // Number will have been validated by this point
      // and the phoneNumber member formats with iso code
      String number = numberController.phoneNumber!;
      // Stash isoCode in local storage so that its remembered if the user
      // chooses a different one than the default
      String isoCode = numberController.isoCode!;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('lastIso', isoCode);

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
