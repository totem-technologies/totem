import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
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
      {Key? key, required this.session, this.cropEnabled = false})
      : super(key: key);
  final Session session;
  final bool cropEnabled;

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
  final GlobalKey<FileUploaderState> _uploader = GlobalKey();

  File? _selectedImage;
  bool _uploading = false;

  @override
  void initState() {
    _userProfileFetch = ref.read(repositoryProvider).userProfile();
    super.initState();
  }

  @override
  void dispose() {
    _selectedImage?.delete();
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
              const SizedBox(height: 10),
              if (_selectedImage != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: !_uploading
                          ? () async {
                              await _selectedImage!.delete();
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
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: ThemedRaisedButton(
                    onPressed: _selectedImage != null && !_uploading
                        ? () {
                            _uploadImage(context);
                          }
                        : null,
                    label: t.joinCircle,
                  ),
                ),
              ],
              const SizedBox(
                height: 8,
              ),
            ],
          );
        }
        return Container();
      },
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

  Future<void> _handleImage(XFile imageFile) async {
    setState(() {
      _selectedImage = File(imageFile.path);
    });
  }
}
