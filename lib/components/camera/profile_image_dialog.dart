import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/components/camera/camera_capture_component.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class ProfileImageDialog extends ConsumerStatefulWidget {
  const ProfileImageDialog({Key? key, required this.userProfile})
      : super(key: key);
  final UserProfile userProfile;

  static Future<XFile?> showDialog(BuildContext context,
      {required UserProfile userProfile}) async {
    return showModalBottomSheet<XFile?>(
      enableDrag: false,
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).themeColors.blurBackground,
      builder: (_) => ProfileImageDialog(
        userProfile: userProfile,
      ),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProfileImageDialogState();
}

class _ProfileImageDialogState extends ConsumerState<ProfileImageDialog> {
  XFile? _selectedImage;
  File? _selectedImageFile;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textStyles;
    final t = AppLocalizations.of(context)!;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 50,
          ),
          child: BottomTrayContainer(
            fullScreen: true,
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Container()),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.close,
                        color: themeColors.primaryText,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraint) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                Theme.of(context).pageHorizontalPadding),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraint.maxHeight),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  t.profilePicture,
                                  style: textStyles.dialogTitle,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                Divider(
                                  thickness: 1,
                                  height: 1,
                                  color: themeColors.divider,
                                ),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            Theme.of(context).maxRenderWidth),
                                    child: _userImage(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _userImage(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                child: Container(
                  color: themeColors.primaryText,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _selectedImage == null
                        ? CameraCapture(
                            captureMode: CaptureMode.photoOnly,
                            onImageTaken: (imageFile) {
                              _handleImage(imageFile);
                            },
                          )
                        : _takenImage(context),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_selectedImage != null)
          Column(
            children: [
              TextButton(
                onPressed: () async {
                  if (_selectedImageFile != null) {
                    await _selectedImageFile!.delete();
                  }
                  setState(() {
                    _selectedImage = null;
                    _selectedImageFile = null;
                  });
                },
                child: Text(
                  t.edit,
                  style: TextStyle(color: themeColors.linkText, fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: ThemedRaisedButton(
                  onPressed: _selectedImage != null
                      ? () {
                          _selectImage(context);
                        }
                      : null,
                  label: t.useImage,
                ),
              ),
            ],
          ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

  Widget _takenImage(BuildContext context) {
    if (_selectedImageFile != null) {
      return Image.file(
        _selectedImageFile!,
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(_selectedImage!.path, fit: BoxFit.cover);
    }
  }

  Future<void> _selectImage(BuildContext context) async {
    Navigator.of(context).pop(_selectedImage);
  }

  Future<void> _handleImage(XFile imageFile) async {
    setState(() {
      _selectedImage = imageFile;
      if (!kIsWeb) {
        _selectedImageFile = File(imageFile.path);
      }
    });
  }
}
