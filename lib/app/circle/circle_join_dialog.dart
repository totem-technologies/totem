import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/components/camera/camera_capture_component.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/providers.dart';
import 'package:totem/theme/index.dart';

class CircleJoinDialog extends ConsumerStatefulWidget {
  const CircleJoinDialog(
      {Key? key, required this.circle, this.cropEnabled = false})
      : super(key: key);
  final Circle circle;
  final bool cropEnabled;

  static Future<String?> showDialog(BuildContext context,
      {required Circle circle}) async {
    return showModalBottomSheet<String>(
      enableDrag: false,
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).themeColors.blurBackground,
      builder: (_) => CircleJoinDialog(
        circle: circle,
      ),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CircleJoinDialogState();
}

class _CircleJoinDialogState extends ConsumerState<CircleJoinDialog> {
  late Future<UserProfile?> _userProfileFetch;
  final GlobalKey<FileUploaderState> _uploader = GlobalKey();

  File? _selectedImageFile;
  bool _uploading = false;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool get hasImage {
    return _selectedImage != null;
  }

  @override
  void initState() {
    _userProfileFetch = ref.read(repositoryProvider).userProfile();
    super.initState();
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _selectedImageFile?.delete();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textStyles;
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  widget.circle.name,
                                  style: textStyles.dialogTitle,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 24),
                                Divider(
                                  thickness: 1,
                                  height: 1,
                                  color: themeColors.divider,
                                ),
                                const SizedBox(height: 24),
                                Expanded(child: _userInfo(context)),
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

  Widget _userInfo(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;

    return FutureBuilder<UserProfile?>(
      future: _userProfileFetch,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: BusyIndicator(),
          );
        }
        if (asyncSnapshot.hasData) {
          UserProfile user = asyncSnapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                user.name,
                style: textStyles.headline3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t.helpSessionProfileImage,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: Theme.of(context).maxRenderWidth),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.0,
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(24)),
                              child: Container(
                                color: themeColors.primaryText,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: !hasImage
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
                          if (hasImage)
                            Positioned.fill(
                              child: FileUploader(
                                key: _uploader,
                                assignProfile: false,
                                onComplete: (uploadedFileUrl, error) {
                                  if (uploadedFileUrl != null) {
                                    Navigator.of(context).pop(uploadedFileUrl);
                                  } else {
                                    _showUploadError(context, error);
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (hasImage) ...[
                        TextButton(
                          onPressed: !_uploading
                              ? () async {
                                  await _selectedImageFile?.delete();
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                }
                              : null,
                          child: Text(
                            t.edit,
                            style: TextStyle(
                                color: themeColors.linkText, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: ThemedRaisedButton(
                            onPressed: hasImage && !_uploading
                                ? () {
                                    _uploadImage(context);
                                  }
                                : null,
                            label: t.joinCircle,
                          ),
                        ),
                      ],
                    ],
                  )),
            ],
          );
        }
        return Container();
      },
    );
  }

  Widget _takenImage(BuildContext context) {
    if (!kIsWeb) {
      return Image.file(
        _selectedImageFile!,
        fit: BoxFit.cover,
      );
    } else {
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
      );
    }
  }

  Future<void> _uploadImage(BuildContext context) async {
    setState(() {
      _uploading = true;
    });
    final authUser = ref.read(authServiceProvider).currentUser()!;
    _uploader.currentState!.profileImageUpload(_selectedImage!, authUser);
  }

  Future<void> _handleImage(XFile imageFile) async {
    if (kIsWeb) {
      _selectedImageBytes = await imageFile.readAsBytes();
    }
    setState(() {
      _selectedImage = imageFile;
      if (!kIsWeb) {
        _selectedImageFile = File(imageFile.path);
      }
    });
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
