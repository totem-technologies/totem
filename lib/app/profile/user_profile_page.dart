import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:libphonenumber_plugin/libphonenumber_plugin.dart';
import 'package:totem/app/profile/components/index.dart';
import 'package:totem/components/camera/index.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends ConsumerState<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late Future<UserProfile?> _userProfileFetch;
  UserProfile? _userProfile;
  bool _busy = false;
  final GlobalKey<FileUploaderState> _uploader = GlobalKey();
  XFile? _pendingImageChange;
  File? _pendingImageChangeFile;
  bool _pendingClose = false;
  bool _hasChanged = false;

  bool get hasChanged {
    return (_userProfile != null &&
        (_userProfile!.name != _nameController.text ||
            (_userProfile!.email != null &&
                    _userProfile!.email != _emailController.text ||
                _pendingImageChange != null)));
  }

  @override
  void initState() {
    _userProfileFetch =
        ref.read(repositoryProvider).userProfile(circlesCompleted: true);
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    await _pendingImageChangeFile?.delete();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    final themeColors = themeData.themeColors;
    return GradientBackground(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: ConditionalWillPopScope(
          onWillPop: () async {
            if (_busy) {
              return false;
            } else if (hasChanged) {
              return await _savePrompt(true);
            }
            return true;
          },
          shouldAddCallback: _hasChanged,
          child: GestureDetector(
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 8,
                            ),
                            const BackButton(),
                            Expanded(child: Container()),
                            TextButton(
                                onPressed: !_busy && hasChanged
                                    ? () async {
                                        await _saveForm();
                                        if (!mounted) return;
                                        await Navigator.maybePop(context);
                                      }
                                    : null,
                                child: Text(t.save)),
                            const SizedBox(
                              width: 8,
                            ),
                          ],
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          t.editProfile,
                                          style: textStyles.headline2,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          children: [
                                            Stack(
                                              children: [
                                                GestureDetector(
                                                  onTap: () =>
                                                      _getUserImage(context),
                                                  child: ProfileImage(
                                                    localImagePath:
                                                        _pendingImageChange
                                                            ?.path,
                                                    localImageFile:
                                                        _pendingImageChangeFile,
                                                  ),
                                                ),
                                                if (_pendingImageChange != null)
                                                  Positioned.fill(
                                                    child: FileUploader(
                                                      key: _uploader,
                                                      assignProfile: false,
                                                      showBusy: false,
                                                      onComplete:
                                                          (uploadedFileUrl,
                                                              error) {
                                                        _handleUploadComplete(
                                                            uploadedFileUrl,
                                                            error);
                                                      },
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        t.profilePicture,
                                                        style: textStyles
                                                            .headline3,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      InkWell(
                                                        customBorder:
                                                            const CircleBorder(),
                                                        onTap: () {
                                                          BottomTrayHelpDialog
                                                              .showTrayHelp(
                                                                  context,
                                                                  title: t
                                                                      .profilePicture,
                                                                  detail: t
                                                                      .helpPublicInformation);
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical: 5),
                                                          child: Icon(
                                                              Icons
                                                                  .help_outline,
                                                              size: 24,
                                                              color: themeColors
                                                                  .primaryText),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                        minimumSize: Size.zero,
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 8,
                                                                bottom: 8,
                                                                right: 20),
                                                        tapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                      ),
                                                      onPressed: () =>
                                                          _getUserImage(
                                                              context),
                                                      child: Text(t.change)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Divider(
                                          color: themeData.themeColors.divider,
                                          height: 1,
                                          thickness: 1,
                                        ),
                                        const SizedBox(height: 22),
                                        _profileEditForm(context),
                                        Expanded(
                                          child: Container(),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: !_busy
                                                  ? () {
                                                      _promptSignOut(context);
                                                    }
                                                  : null,
                                              child: Text(t.signOut),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: !_busy
                                                  ? () {
                                                      _promptDeleteAccount(
                                                          context);
                                                    }
                                                  : null,
                                              child: Text(t.deleteAccount),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        const VersionInfo(),
                                        const SizedBox(height: 40),
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
                  if (_busy)
                    const Center(
                      child: BusyIndicator(),
                    )
                ],
              )),
        ),
      ),
    );
  }

  Future<void> _getUserImage(BuildContext context) async {
    if (_busy) {
      return;
    }
    XFile? imagePath = await ProfileImageDialog.showDialog(context,
        userProfile: _userProfile!);
    if (imagePath != null) {
      await _pendingImageChangeFile?.delete();
      setState(() {
        _pendingImageChange = imagePath;
        _hasChanged = true;
        if (!kIsWeb) {
          _pendingImageChangeFile = File(imagePath.path);
        }
      });
    }
  }

  Future<void> _handleUploadComplete(String? uploadedUrl, String? error) async {
    if (uploadedUrl != null) {
      _userProfile!.image = uploadedUrl;
      // delete pending image
      await _pendingImageChangeFile?.delete();
      _pendingImageChangeFile = null;
      _pendingImageChange = null;
      await ref.read(repositoryProvider).updateUserProfile(_userProfile!);
      setState(() => _busy = false);
    } else {
      // this is an error condition
      setState(() => _busy = false);
      await _showUploadError(context, error);
      return;
    }
    if (_pendingClose) {
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }
  /* currently unused - revive if we make icon buttons for profile
  Widget _iconButton(BuildContext context, IconData icon, String label,
      VoidCallback? onPressed) {
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: themeData.themeColors.primaryText,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                label,
                style: textStyles.button,
              ),
            ),
          ],
        ),
      ),
    );
  } */

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

  Future<void> _promptDeleteAccount(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    bool? deleteAccount = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final actions = [
          TextButton(
            child: Text(t.cancel),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text(t.deleteEverythingButton),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ];
        return AlertDialog(
          title: Text(
            t.deleteAccount,
          ),
          content: Text(t.deleteAccountMessage),
          actions: actions,
        );
      },
    );
    if (deleteAccount == true) {
      setState(() => _busy = true);
      await ref.read(authServiceProvider).deleteAccount();
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  Future<void> _promptSignOut(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    bool? signOut = await showDialog<bool>(
      context: context,
      /*it shows a popup with few options which you can select, for option we
        created enums which we can use with switch statement, in this first switch
        will wait for the user to select the option which it can use with switch cases*/
      builder: (BuildContext context) {
        final actions = [
          TextButton(
            child: Text(t.signOut),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          TextButton(
            child: Text(t.cancel),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ];
        return AlertDialog(
          title: Text(
            t.signOut,
          ),
          content: Text(t.areYouSureSignOut),
          actions: actions,
        );
      },
    );
    if (signOut == true) {
      setState(() => _busy = true);
      await ref.read(authServiceProvider).signOut();
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (hasChanged) {
      setState(() => _busy = true);
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
        setState(() => _busy = false);
      }
    }
    if (_pendingClose) {
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  Widget _profileLabelItem(BuildContext context,
      {required String label, required String helpType}) {
    final textStyles = Theme.of(context).textStyles;
    final themeColors = Theme.of(context).themeColors;
    return Row(
      children: [
        InkWell(
          onTap: () {
            BottomTrayHelpDialog.showTrayHelp(context,
                title: label, detail: helpType);
          },
          child: Padding(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 5,
            ),
            child: Row(
              children: [
                Text(label, style: textStyles.inputLabel),
                const SizedBox(
                  width: 8,
                ),
                Icon(Icons.help_outline,
                    size: 24, color: themeColors.primaryText)
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileEditForm(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    AuthUser user = ref.read(authServiceProvider).currentUser()!;
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
              _profileLabelItem(context,
                  label: t.name, helpType: t.helpPublicInformation),
              ThemedTextFormField(
                hintText: t.helpExampleName,
                autofillHints: const [AutofillHints.givenName],
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.errorEnterName;
                  }
                  return null;
                },
                onChanged: _checkHasChanged,
              ),
              const SizedBox(height: 22),
              _profileLabelItem(context,
                  label: t.email, helpType: t.helpPrivateInformation),
              ThemedTextFormField(
                hintText: t.helpExampleEmail,
                controller: _emailController,
                autofillHints: const [AutofillHints.email],
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                autocorrect: false,
                onChanged: _checkHasChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.errorEnterEmail;
                  } else if (!EmailValidator.validate(value)) {
                    return t.errorEmailInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              _profileLabelItem(context,
                  label: t.phoneNumber, helpType: t.helpPrivateInformation),
              FutureBuilder<String>(
                future: _formatPhoneNumber(user.phoneNumber),
                builder: (context, asyncSnapshot) {
                  return Text(asyncSnapshot.data ?? user.phoneNumber);
                },
              ),
              const SizedBox(height: 10),
              Divider(
                color: themeData.themeColors.divider,
                height: 1,
                thickness: 1,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    t.memberSince,
                    style: textStyles.inputLabel,
                  ),
                  Expanded(
                    child: Text(
                      DateFormat.yMMMM().format(_userProfile!.createdOn),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(
                color: themeData.themeColors.divider,
                height: 1,
                thickness: 1,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    t.circlesDone,
                    style: textStyles.inputLabel,
                  ),
                  Expanded(
                    child: Text(
                      _userProfile!.completedCircles?.toString() ?? "0",
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(
                color: themeData.themeColors.divider,
                height: 1,
                thickness: 1,
              ),
            ],
          ),
        );
      },
    );
  }

  void _checkHasChanged(String val) {
    bool changed = hasChanged;
    if (changed != _hasChanged) {
      setState(() => _hasChanged = changed);
    }
  }

  Future<String> _formatPhoneNumber(String phoneNumber) async {
    PhoneNumber num =
        await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber);
    String? formattedNumber =
        await PhoneNumberUtil.formatAsYouType(num.phoneNumber!, num.isoCode!);
    return formattedNumber ?? "";
  }

  Future<bool> _savePrompt(bool pendingClose) async {
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
      _pendingClose = pendingClose;
      await _saveForm();
      return false;
    }
    if (result == 1) {
      setState(() {
        _hasChanged = false;
      });
      // set a delay to process on next cycle after _hasChange has been set
      Future.delayed(const Duration(milliseconds: 0), () {
        Navigator.of(context).pop();
      });
    }
    return false;
  }
}
