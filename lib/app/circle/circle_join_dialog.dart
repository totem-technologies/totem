import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:totem/components/camera/camera_capture_component.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/providers.dart';
import 'package:totem/theme/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:camera/camera.dart';

class CircleJoinDialog extends ConsumerStatefulWidget {
  const CircleJoinDialog({Key? key, required this.session}) : super(key: key);
  final Session session;

  static Future<String?> showDialog(BuildContext context,
      {required Session session}) async {
    return showModalBottomSheet<String>(
      enableDrag: false,
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).themeColors.blurBackground,
      builder: (_) => CircleJoinDialog(
        session: session,
      ),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CircleJoinDialogState();
}

class _CircleJoinDialogState extends ConsumerState<CircleJoinDialog> {
  late Future<UserProfile?> _userProfileFetch;
  final cropKey = GlobalKey<CropState>();
  final GlobalKey<FileUploaderState> _uploader = GlobalKey();

  File? _pendingImage;
  File? _selectedImage;
  bool _busy = false;
  bool _uploading = false;

  @override
  void initState() {
    _userProfileFetch = ref.read(repositoryProvider).userProfile();
    super.initState();
  }

  @override
  void dispose() {
    _pendingImage?.delete();
    _selectedImage?.delete();
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  widget.session.circle.name,
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
                                Expanded(child: _userInfo(context)),
                                if (_selectedImage != null)
                                  SafeArea(
                                    top: false,
                                    bottom: true,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ThemedRaisedButton(
                                          label: t.joinSession,
                                          onPressed: _selectedImage != null
                                              ? () {
                                                  _uploadImage(context);
                                                }
                                              : null,
                                          width: Theme.of(context)
                                              .standardButtonWidth,
                                        ),
                                      ],
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              if (_pendingImage == null)
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(24)),
                        child: Container(
                          decoration: BoxDecoration(
                            color: themeColors.profileBackground,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(24)),
                          ),
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
                    if (_selectedImage != null)
                      Positioned.fill(
                        child: FileUploader(
                          key: _uploader,
                          assignProfile: false,
                          onComplete: (uploadedFileUrl) {
                            Navigator.of(context).pop(uploadedFileUrl);
                          },
                        ),
                      ),
                  ],
                ),
              if (_pendingImage != null) ...[
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(24)),
                        child: _cropImage(context),
                      ),
                    ),
                    if (_busy)
                      Positioned.fill(
                        child: Center(
                          child: BusyIndicator(
                            color: themeColors.reversedText,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  'Drag image to recenter, pinch to zoom in or out',
                  style: textStyles.headline4,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: !_busy
                          ? () {
                              _savePendingImage(context);
                            }
                          : null,
                      child: Text(
                        'Use Image',
                        style: TextStyle(color: themeColors.linkText),
                      ),
                    ),
                    TextButton(
                      onPressed: !_busy
                          ? () async {
                              await _pendingImage!.delete();
                              setState(() {
                                _pendingImage = null;
                              });
                            }
                          : null,
                      child: Text(
                        'Retake',
                        style: TextStyle(color: themeColors.linkText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
              ]
            ],
          );
        }
        return Container();
      },
    );
  }

  Widget _cropImage(BuildContext context) {
    return Crop.file(
      _pendingImage!,
      key: cropKey,
      aspectRatio: 1.0,
    );
  }

  Widget _takenImage(BuildContext context) {
    return Image.file(
      _selectedImage!,
      fit: BoxFit.cover,
    );
  }

  Future<void> _uploadImage(BuildContext context) async {
    setState(() {
      _uploading = true;
    });
    final authUser = ref.read(authServiceProvider).currentUser()!;
    _uploader.currentState!.profileImageUpload(_selectedImage!, authUser);
  }

  Future<void> _savePendingImage(BuildContext context) async {
    setState(() => _busy = true);
    final scale = cropKey.currentState!.scale;
    final area = cropKey.currentState!.area;

    final sample = await ImageCrop.sampleImage(
      file: _pendingImage!,
      preferredSize: (500 / scale).round(),
    );

    final selected = await ImageCrop.cropImage(file: sample, area: area!);
    sample.delete();
    _pendingImage!.delete();
    setState(() {
      _pendingImage = null;
      _selectedImage = selected;
      _busy = false;
    });
  }

  Future<void> _handleImage(XFile imageFile) async {
    setState(() {
      _pendingImage = File(imageFile.path);
    });
  }
}
