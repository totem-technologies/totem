import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/components/widgets/themed_raised_button.dart';
import 'package:totem/services/providers.dart';
import 'package:totem/theme/index.dart';

import 'file_uploader.dart';

class FilePromptSave extends ConsumerStatefulWidget {
  final XFile uploadTarget;

  const FilePromptSave({
    Key? key,
    required this.uploadTarget,
  }) : super(key: key);

  @override
  FilePromptSaveState createState() => FilePromptSaveState();
}

class FilePromptSaveState extends ConsumerState<FilePromptSave> {
  static const double padding = 20;
  static const double imageRadius = 80;
  bool _uploading = false;
  bool _exists = true;
  final GlobalKey<FileUploaderState> _uploader = GlobalKey();

  @override
  void initState() {
    if (!kIsWeb) {
      File file = File(widget.uploadTarget.path);
      _exists = file.existsSync();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
/*      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ), */
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(child: contentBox(context)),
    );
  }

  Widget contentBox(context) {
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(
              left: padding, top: padding, right: padding, bottom: padding),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                    color: themeColors.shadow,
                    offset: const Offset(0, 5),
                    blurRadius: 5),
              ]),
          child: (_exists)
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      t.saveProfileImage,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CircleAvatar(
                      radius: imageRadius,
                      child: ClipOval(
                        child: SizedBox(
                          width: imageRadius * 2,
                          height: imageRadius * 2,
                          child: !kIsWeb
                              ? Image.file(File(widget.uploadTarget.path),
                                  fit: BoxFit.cover)
                              : Image.network(widget.uploadTarget.path),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    if (_uploading)
                      const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [SizedBox(height: 30)]),
                    if (!_uploading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              FocusScopeNode current = FocusScope.of(context);
                              if (!current.hasPrimaryFocus) {
                                current.unfocus();
                              }
                              Navigator.pop(context);
                            },
                            child: Text(t.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              _saveProfileImage(context);
                            },
                            child: Text(
                              t.ok,
                            ),
                          ),
                        ],
                      ),
                  ],
                )
              : _fileNotAvailable(),
        ),
        Positioned.fill(
          child: Center(
            child: FileUploader(
              key: _uploader,
              onComplete: ({String? error, String? url, String? path}) {
                if (url != null) {
                  Navigator.pop(context, url);
                } else {
                  _showUploadError(context, error);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _fileNotAvailable() {
    final t = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 10,
        ),
        Text(
          t.errorCantAccessImage,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ThemedRaisedButton(
          label: t.ok,
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  void _saveProfileImage(BuildContext context) {
    FocusScopeNode current = FocusScope.of(context);
    if (!current.hasPrimaryFocus) {
      current.unfocus();
    }
    setState(() {
      _uploading = true;
    });
    final authUser = ref.read(authServiceProvider).currentUser()!;
    _uploader.currentState!.profileImageUpload(widget.uploadTarget, authUser);
  }

  Future<void> _showUploadError(BuildContext context, String? error) async {
    final t = AppLocalizations.of(context)!;
    await showDialog<bool>(
      context: context,
      /*it shows a popup with few options which you can select, for option we
        created enums which we can use with switch statement, in this first switch
        will wait for the user to select the option which it can use with switch cases*/
      builder: (BuildContext context) {
        final actions = [
          TextButton(
            child: Text(t.ok),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ];
        return AlertDialog(
          title: Text(
            t.uploadErrorTitle,
          ),
          content: Text(error ?? t.uploadErrorGeneric),
          actions: actions,
        );
      },
    );
  }
}
