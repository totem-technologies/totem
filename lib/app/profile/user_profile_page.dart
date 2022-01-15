import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late Future<UserProfile?> _userProfileFetch;
  UserProfile? _userProfile;
  bool _busy = false;
  final GlobalKey<FileUploaderState> _uploader = GlobalKey();
  File? _pendingImageChange;
  bool _pendingClose = false;

  bool get hasChanged {
    return (_userProfile != null &&
        (_userProfile!.name != _nameController.text ||
            (_userProfile!.email != null &&
                    _userProfile!.email != _emailController.text ||
                _pendingImageChange != null)));
  }

  @override
  void initState() {
    _userProfileFetch = ref.read(repositoryProvider).userProfile();
    super.initState();
  }

  @override
  void dispose() async {
    _pendingImageChange?.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    return GradientBackground(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: WillPopScope(
          onWillPop: () async {
            if (_busy) {
              return false;
            } else if (hasChanged) {
              return await _savePrompt(true);
            }
            return true;
          },
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
                                    ? () {
                                        _saveForm();
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
                                      minHeight: constraint.maxHeight),
                                  child: IntrinsicHeight(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 8),
                                        Text(
                                          t.editProfile,
                                          style: textStyles.headline2,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Stack(
                                              children: [
                                                ProfileImage(
                                                  localImage:
                                                      _pendingImageChange,
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
                                                        t.profilePicture
                                                            .toLowerCase(),
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
                                                          child:
                                                              SvgPicture.asset(
                                                            'assets/more_info.svg',
                                                            width: 17,
                                                            height: 17,
                                                          ),
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
                                                      onPressed: !_busy
                                                          ? () {
                                                              _getUserImage(
                                                                  context);
                                                            }
                                                          : null,
                                                      child: Text(t.edit)),
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
                                              child: Text(t.signOut,
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        const VersionInfo(),
                                        const SizedBox(height: 20),
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
    String? imagePath = await ProfileImageDialog.showDialog(context,
        userProfile: _userProfile!);
    if (imagePath != null) {
      _pendingImageChange?.delete();
      setState(() {
        _pendingImageChange = File(imagePath);
      });
    }
  }

  Future<void> _handleUploadComplete(String? uploadedUrl, String? error) async {
    if (uploadedUrl != null) {
      _userProfile!.image = uploadedUrl;
      // delete pending image
      _pendingImageChange?.delete();
      _pendingImageChange = null;
      await ref.read(repositoryProvider).updateUserProfile(_userProfile!);
      setState(() => _busy = false);
    } else {
      // this is an error condition
      setState(() => _busy = false);
      _showUploadError(context, error);
      return;
    }
    if (_pendingClose) {
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
        _uploader.currentState!.profileImageUpload(_pendingImageChange!, user);
        return;
      } else {
        // just save the profile
        await ref.read(repositoryProvider).updateUserProfile(_userProfile!);
        setState(() => _busy = false);
      }
    }
    if (_pendingClose) {
      Navigator.of(context).pop();
    }
  }

  Widget _profileLabelItem(BuildContext context,
      {required String label, required String helpType}) {
    final textStyles = Theme.of(context).textStyles;
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
                SizedBox(
                  width: 24,
                  height: 24,
                  child: SvgPicture.asset('assets/more_info.svg'),
                ),
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
              ),
              const SizedBox(height: 22),
              _profileLabelItem(context,
                  label: t.email, helpType: t.helpPrivateInformation),
              ThemedTextFormField(
                hintText: t.helpExampleEmail,
                controller: _emailController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.errorEnterName;
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
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
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
      _saveForm();
      return false;
    }
    return result == 1;
  }
}
