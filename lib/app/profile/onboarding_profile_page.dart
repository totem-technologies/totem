import 'dart:async';
import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:camera/camera.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/components/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class OnboardingProfilePage extends ConsumerStatefulWidget {
  const OnboardingProfilePage({Key? key, this.onProfileUpdated, this.profile})
      : super(key: key);
  final Function(UserProfile)? onProfileUpdated;
  final UserProfile? profile;

  @override
  OnboardingProfilePageState createState() => OnboardingProfilePageState();
}

class OnboardingProfilePageState extends ConsumerState<OnboardingProfilePage>
    with AfterLayoutMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late Future<UserProfile?> _userProfileFetch;
  UserProfile? _userProfile;
  bool _busy = false;
  final GlobalKey<FileUploaderState> _uploader = GlobalKey();
  File? _pendingImageChangeFile;
  XFile? _pendingImageChange;
  final List<String> _errors = [];

  bool get hasChanged {
    return (_userProfile!.name != _nameController.text ||
        (_userProfile!.email != null &&
                _userProfile!.email != _emailController.text ||
            _pendingImageChange != null));
  }

  @override
  void initState() {
    final repo = ref.read(repositoryProvider);
    if (repo.user == null) {
      AuthUser? user = ref.read(authServiceProvider).currentUser();
      repo.user = user;
    }
    _userProfile = widget.profile;
    _nameController.text = _userProfile?.name ?? "";
    _emailController.text = _userProfile?.email ?? "";
    _userProfileFetch = repo.userProfile();
    super.initState();
  }

  Future<void> _handleUploadComplete(String? uploadedUrl, String? error) async {
    if (uploadedUrl != null) {
      _userProfile!.image = uploadedUrl;
      await ref.read(repositoryProvider).updateUserProfile(_userProfile!);
      setState(() => _busy = false);
      if (!mounted) return;
      if (widget.onProfileUpdated == null) {
        Navigator.of(context).pop();
      } else {
        widget.onProfileUpdated!(_userProfile!);
      }
    } else {
      setState(() => _busy = false);
      await _showUploadError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    final themeColors = themeData.themeColors;
    return GradientBackground(
      rotation: themeData.backgroundGradientRotation,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: WillPopScope(
          onWillPop: () async {
            if (_busy) {
              return false;
            } else if (hasChanged) {
              return await _savePrompt();
            }
            return true;
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // call this method here to hide soft keyboard
              FocusScope.of(context).unfocus();
            },
            child: SafeArea(
              top: true,
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(context),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _errors.isEmpty
                        ? Container()
                        : Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: Theme.of(context).maxRenderWidth),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: ErrorInfoBlock(
                                    errorContent: _errorPrompt(context)),
                              ),
                            ),
                          ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraint) {
                        return SingleChildScrollView(
                          padding: EdgeInsets.only(
                            left: themeData.pageHorizontalPadding,
                            right: themeData.pageHorizontalPadding,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraint.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          Theme.of(context).maxRenderWidth),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(t.addProfilePicture,
                                              style: textStyles.headline3),
                                          const SizedBox(width: 6),
                                          InkWell(
                                            onTap: () {
                                              BottomTrayHelpDialog.showTrayHelp(
                                                context,
                                                title: t.profilePicture,
                                                detail: t.helpPublicInformation,
                                              );
                                            },
                                            child: Icon(Icons.help_outline,
                                                size: 24,
                                                color: themeColors.primaryText),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      _profileEditForm(context),
                                      const SizedBox(height: 20),
                                      ThemedRaisedButton(
                                        label: t.finish,
                                        busy: _busy,
                                        onPressed: !_busy ? _saveForm : null,
                                        width: Theme.of(context)
                                            .standardButtonWidth,
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
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
      ),
    );
  }

  Widget _errorPrompt(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.errorProfileInfoMissing,
        ),
        const SizedBox(height: 10),
        ..._errors.map((error) =>
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(
                Icons.circle,
                size: 8,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(error, style: const TextStyle(fontWeight: FontWeight.w600)),
            ])),
      ],
    );
  }

  Future<void> _getUserImage(BuildContext context) async {
    XFile? imagePath = await ProfileImageDialog.showDialog(context,
        userProfile: _userProfile!);
    if (imagePath != null) {
      setState(() {
        _pendingImageChange = imagePath;
        if (!kIsWeb) {
          _pendingImageChangeFile = File(imagePath.path);
        }
      });
    }
  }

  Widget _header(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;
    return Column(
      children: [
        SizedBox(height: Theme.of(context).titleTopPadding),
        Text(
          t.aboutYou,
          style: textTheme.headline1,
        ),
        const Center(
          child: ContentDivider(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_userProfile!.name != _nameController.text ||
        _userProfile!.email != _emailController.text ||
        _pendingImageChange != null) {
      setState(() {
        _busy = true;
        _errors.clear();
      });
      _formKey.currentState!.save();
      _userProfile!.name = _nameController.text;
      _userProfile!.email = _emailController.text;
      if (_pendingImageChange != null) {
        AuthUser user = ref.read(authServiceProvider).currentUser()!;
        await _uploader.currentState!
            .profileImageUpload(_pendingImageChange!, user);
        return;
      } else {
        // just save the profile
        await ref.read(repositoryProvider).updateUserProfile(_userProfile!);
      }
    }
    if (!mounted) return;
    if (widget.onProfileUpdated == null) {
      Navigator.of(context).pop();
    } else {
      widget.onProfileUpdated!(_userProfile!);
    }
  }

  Widget _profileEditForm(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    final themeColors = themeData.themeColors;
    return FutureBuilder<UserProfile?>(
      future: _userProfileFetch,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: BusyIndicator(),
          );
        }
        if (!asyncSnapshot.hasData) {
          return Center(
            child: Column(
              children: [
                Text(
                  t.errorNoProfile,
                  style: textStyles.headline3,
                )
              ],
            ),
          );
        }
        if (_userProfile == null) {
          _userProfile = asyncSnapshot.data!;
          _nameController.text = _userProfile!.name;
          _emailController.text = _userProfile!.email ?? "";
        }
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      // edit
                      _getUserImage(context);
                    },
                    child: Stack(
                      children: [
                        ((_userProfile != null && _userProfile!.hasImage) ||
                                _pendingImageChange != null)
                            ? ProfileImage(
                                size: 100,
                                localImagePath: _pendingImageChange?.path,
                                localImageFile: _pendingImageChangeFile,
                                shape: BoxShape.circle,
                              )
                            : _emptyProfileImage(context),
                        if (_pendingImageChange != null)
                          Positioned.fill(
                            child: FileUploader(
                              key: _uploader,
                              assignProfile: false,
                              showBusy: false,
                              onComplete: (uploadedFileUrl, error) {
                                _handleUploadComplete(uploadedFileUrl, error);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(t.name, style: textStyles.inputLabel),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: ThemedTextFormField(
                      hintText: t.helpExampleName,
                      controller: _nameController,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.name,
                      autofillHints: const [AutofillHints.givenName],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return t.errorEnterName;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  InkWell(
                    onTap: () {
                      BottomTrayHelpDialog.showTrayHelp(
                        context,
                        title: t.name,
                        detail: t.helpPublicInformation,
                      );
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(bottom: 5, top: 5, left: 4),
                      child: Icon(Icons.help_outline,
                          size: 24, color: themeColors.primaryText),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),
              Text(t.email, style: textStyles.inputLabel),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ThemedTextFormField(
                      hintText: t.helpExampleEmail,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      autofillHints: const [AutofillHints.email],
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return t.errorEnterEmail;
                        } else if (!EmailValidator.validate(value)) {
                          return t.errorEmailInvalid;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  InkWell(
                    onTap: () {
                      BottomTrayHelpDialog.showTrayHelp(
                        context,
                        title: t.email,
                        detail: t.helpPrivateInformation,
                      );
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(bottom: 5, top: 5, left: 4),
                      child: Icon(Icons.help_outline,
                          size: 24, color: themeColors.primaryText),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyProfileImage(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(
            color: themeData.themeColors.profileBackground, width: 1.0),
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.camera_alt_outlined,
          color: themeData.themeColors.primaryText,
        ),
      ),
    );
  }

  Future<bool> _savePrompt() async {
    FocusScope.of(context).unfocus();
    final t = AppLocalizations.of(context)!;
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(t.cancel),
      onPressed: () {
        Navigator.of(context).pop(0);
      },
    );
    Widget saveButton = TextButton(
      child: Text(t.save),
      onPressed: () {
        Navigator.of(context).pop(2);
      },
    );
    Widget continueButton = TextButton(
      child: Text(t.leaveWithoutSaving),
      onPressed: () {
        Navigator.of(context).pop(1);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(t.changesTitle),
      content: Text(t.changesProfilePrompt),
      actions: [
        saveButton,
        continueButton,
        cancelButton,
      ],
    );
    // show the dialog
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
    if (result == 2) {
      await _saveForm();
      return false;
    }
    return result == 1;
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

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    if (widget.profile != null) {
      final t = AppLocalizations.of(context)!;
      if (_userProfile!.name.isEmpty) {
        _errors.add(t.name);
      }
      if (_userProfile!.email == null || _userProfile!.email!.isEmpty) {
        _errors.add(t.email);
      }
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_errors.isNotEmpty) {
          setState(() {});
        }
        _formKey.currentState!.validate();
      });
    }
  }
}
