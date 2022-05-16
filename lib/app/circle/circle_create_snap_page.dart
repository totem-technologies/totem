import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class CircleCreateSnapPage extends ConsumerStatefulWidget {
  const CircleCreateSnapPage({Key? key}) : super(key: key);

  @override
  CircleCreateSnapPageState createState() => CircleCreateSnapPageState();
}

class CircleCreateSnapPageState extends ConsumerState<CircleCreateSnapPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _busy = false;
  final _focusNodeDescription = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    final t = AppLocalizations.of(context)!;
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // call this method here to hide soft keyboard
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              SafeArea(
                top: true,
                bottom: false,
                child: Column(
                  children: [
                    SubPageHeader(title: t.createNewCircle),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: themeData.pageHorizontalPadding),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(
                                  height: 46,
                                ),
                                Text(t.circleName, style: textStyles.headline3),
                                ThemedTextFormField(
                                  controller: _nameController,
                                  autofocus: true,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  textInputAction: TextInputAction.next,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return t.errorEnterName;
                                    }
                                    return null;
                                  },
                                  maxLines: 1,
                                  maxLength: 50,
                                ),
                                const SizedBox(height: 32),
                                Text(t.description,
                                    style: textStyles.headline3),
                                ThemedTextFormField(
                                  focusNode: _focusNodeDescription,
                                  controller: _descriptionController,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  maxLines: 0,
                                  textInputAction: TextInputAction.newline,
                                  maxLength: 1500,
                                ),
                                const SizedBox(height: 30),
                                Center(
                                  child: ThemedRaisedButton(
                                    label: t.createCircle,
                                    onPressed: !_busy
                                        ? () {
                                            _saveCircle();
                                          }
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 50)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_busy)
                const Center(
                  child: BusyIndicator(),
                )
            ],
          ),
        ),
      ),
    );
  }

  void _saveCircle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    _formKey.currentState!.save();
    var repo = ref.read(repositoryProvider);
    try {
      final circle = await repo.createSnapCircle(
          name: _nameController.text, description: _descriptionController.text);
      if (circle != null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.circle, arguments: {
          'session': circle.snapSession,
        });
/* REMOVE        Map<String, bool>? state =
            await CircleJoinDialog.showDialog(context, circle: circle);
        if (state != null) {
          // Setup foreground service provider with notification values
          if (!mounted) return;
          final t = AppLocalizations.of(context)!;
          SessionForeground.instance.notificationTitle = t.circleInProgress;
          SessionForeground.instance.notificationMessage = t.circleReturnToApp;
          // Create the active session
          await repo.createActiveSession(circle: circle);
          // prompt user for image
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, AppRoutes.circle, arguments: {
            'session': circle.snapSession,
            'state': state,
          }); */
      }
/* REMOVE          return;
        } else {
          // leave session in place or cancel?
          await repo.removeSnapCircle(circle: circle);
          if (!mounted) return;
          Navigator.pop(context);
          return;
        }
      }*/
    } on ServiceException catch (ex) {
      debugPrint('Error creating circle: $ex');
      _showCreateError(ex);
    }
    setState(() => _busy = false);
  }

  Future<void> _showCreateError(ServiceException exception) async {
    final t = AppLocalizations.of(context)!;
    AlertDialog alert = AlertDialog(
      title: Text(t.errorCreateSnapCircle),
      content: Text(exception.toString()),
      actions: [
        TextButton(
          child: Text(t.ok),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
    // show the dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
