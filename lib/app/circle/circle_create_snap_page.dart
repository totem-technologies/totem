import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/components/fade_route.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/components/widgets/sub_page_header.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'circle_session_page.dart';

class CircleCreateSnapPage extends ConsumerStatefulWidget {
  const CircleCreateSnapPage({Key? key}) : super(key: key);

  @override
  _CircleCreatePageState createState() => _CircleCreatePageState();
}

class _CircleCreatePageState extends ConsumerState<CircleCreateSnapPage> {
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
                    SubPageHeader(title: t.createCircle),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: themeData.pageHorizontalPadding),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                ThemedTextFormField(
                                  labelText: t.name,
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
                                ),
                                const SizedBox(height: 20),
                                ThemedTextFormField(
                                  focusNode: _focusNodeDescription,
                                  controller: _descriptionController,
                                  labelText: t.description,
                                  maxLines: 0,
                                  textInputAction: TextInputAction.done,
                                ),
                                const SizedBox(height: 30),
                                ThemedRaisedButton(
                                  label: t.createCircle,
                                  onPressed: !_busy
                                      ? () {
                                          _saveCircle();
                                        }
                                      : null,
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
        await repo.createActiveSession(session: circle.activeSession!);
        Navigator.pushReplacement(
          context,
          FadeRoute(
            page: CircleSessionPage(session: circle.snapSession),
          ),
        );
        return;
      }
    } on ServiceException catch (ex) {
      debugPrint('Error creating circle: ' + ex.toString());
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
