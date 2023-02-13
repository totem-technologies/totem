import 'dart:async';

// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:phone_form_field/phone_form_field.dart';
// import 'package:shared_preferences/shared_preferences.dart';
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
  final phoneKey = GlobalKey<FormFieldState<PhoneNumber>>();
  final TextEditingController _phoneNumberController = TextEditingController();
  PhoneController numberController = PhoneController(null);
  bool _busy = false;
  CountrySelectorNavigator selectorNavigator =
      const CountrySelectorNavigator.bottomSheet();

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
                  AutofillGroup(
                    child: PhoneFormField(
                      key: phoneKey,
                      controller: numberController,
                      shouldFormat: true,
                      autofocus: true,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      countrySelectorNavigator: selectorNavigator,
                      defaultCountry: IsoCode.US,
                      decoration: InputDecoration(
                        label: Text(t.phoneNumber),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: themeColors.primaryText),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: themeColors.primaryText),
                        ),
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: themeColors.primaryText),
                        ),
                        hintText: t.phoneNumber,
                      ),
                      enabled: true,
                      showFlagInInput: true,
                      // validator: _getValidator(),
                      autovalidateMode: AutovalidateMode.disabled,
                      cursorColor: Theme.of(context).colorScheme.primary,
                      onSaved: (p) => debugPrint('saved $p'),
                      onChanged: (p) => debugPrint('changed $p'),
                      isCountryChipPersistent: true,
                      onSubmitted: (p) => onSubmit(),
                    ),
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
    // try {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   String? number = ref.read(authServiceProvider).authRequestNumber;
    //   // if there is a cached previously used value for ISO, use that
    //   String? initialCountry = prefs.getString('lastIso');
    //   if (initialCountry != null) {
    //     setState(() {
    //       numberController =
    //           PhoneNumber(isoCode: initialCountry, phoneNumber: number);
    //     });
    //   } else {
    //     // try reading from sim card
    //     if (!kIsWeb) {
    //       String? platformVersion = await FlutterSimCountryCode.simCountryCode;
    //       if (platformVersion != null && platformVersion.isNotEmpty) {
    //         setState(() {
    //           numberController = PhoneNumber(
    //               isoCode: platformVersion.toUpperCase(), phoneNumber: number);
    //         });
    //       }
    //     }
    //   }
    // } on PlatformException catch (e) {
    //   debugPrint('Error loading iso code: ${e.toString()}');
    // }
  }

  void onSubmit() async {
    var auth = ref.read(authServiceProvider);
    // Validate returns true if the form is valid, or false otherwise.
    if (phoneKey.currentState != null && phoneKey.currentState!.validate()) {
      Timer(const Duration(seconds: 5), () {
        setState(() => _busy = false);
      });
      setState(() => _busy = true);
      phoneKey.currentState!.save();

      // Number will have been validated by this point
      // and the phoneNumber member formats with iso code
      String number = numberController.value!.international;
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
