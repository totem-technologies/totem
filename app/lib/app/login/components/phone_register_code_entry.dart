import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:totem/app/login/components/pin_code_widget.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class PhoneRegisterCodeEntry extends ConsumerStatefulWidget {
  const PhoneRegisterCodeEntry({super.key});

  @override
  PhoneRegisterCodeEntryState createState() => PhoneRegisterCodeEntryState();
}

final errors = {'invalid-verification-code': 'Invalid code. Please try again.'};

class PhoneRegisterCodeEntryState
    extends ConsumerState<PhoneRegisterCodeEntry> {
  final _formKey = GlobalKey<FormState>();
  final AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  String pinValue = '';
  String error = '';
  bool _busy = false;

  ///Validates OTP code
  void signInWithPhoneNumber() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authServiceProvider).verifyCode(pinValue);
      setState(() => _busy = false);
/*    RESTORE THIS WHEN LOGIN GUIDELINES HAVE TO BE ACCEPTED FIRST
      if (!mounted) return;
      final authSvc = ref.read(authServiceProvider);
      final AuthUser? authUser = authSvc.currentUser();
      if (authUser != null && authUser.isNewUser) {
        context.pushReplacementNamed(AppRoutes.loginGuideline);
      }
       */
    } on AuthException catch (e) {
      setState(() {
        error = e.message!;
        _busy = false;
      });
      debugPrint('Error:$e');
    }
  }

  String _formatPhoneNumber(String phoneNumber) {
    return PhoneNumber.parse(phoneNumber).getFormattedNsn();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textTheme;
    final themeColors = Theme.of(context).themeColors;
    final authService = ref.watch(authServiceProvider);
    return Padding(
      padding: const EdgeInsets.only(left: 35, right: 35),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: Theme.of(context).maxRenderWidth),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(t.signup, style: textStyles.displayLarge),
            const ContentDivider(),
            const SizedBox(height: 20),
            Text(
              t.textSentTo(
                  _formatPhoneNumber(authService.authRequestNumber ?? "")),
              style: textStyles.bodyLarge!
                  .merge(const TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            Text(
              t.enterTheCodeDetail,
              style: textStyles.bodyLarge!,
            ),
            const SizedBox(
              height: 50,
            ),
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
                  if (int.tryParse(pinValue) != null) {
                    signInWithPhoneNumber();
                  }
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
            const SizedBox(
              height: 20,
            ),
            ThemedRaisedButton(
              label: t.getStarted,
              busy: _busy,
              width: 294,
              onPressed: pinValue.length == 6 && int.tryParse(pinValue) != null
                  ? () {
                      signInWithPhoneNumber();
                    }
                  : null,
            ),
            const SizedBox(height: 20),
            TextButton(
                onPressed: _backToNumber,
                child: Text(
                  t.retryPhone,
                  textAlign: TextAlign.center,
                ))
          ],
        ),
      ),
    );
  }

  void _backToNumber() {
    ref.read(authServiceProvider).cancelPendingCode();
  }
}
