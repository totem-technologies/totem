import 'dart:ui';

import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/app/circle/components/circle_device_settings_button.dart';
import 'package:totem/components/camera/index.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';

class CircleJoinDialog extends ConsumerStatefulWidget {
  const CircleJoinDialog(
      {Key? key, required this.circle, this.cropEnabled = false})
      : super(key: key);
  final Circle circle;
  final bool cropEnabled;

  static Future<UserProfile?> showJoinDialog(BuildContext context,
      {required Circle circle}) async {
    return DeviceType.isPhone()
        ? showModalBottomSheet<UserProfile?>(
            enableDrag: false,
            isScrollControlled: true,
            isDismissible: false,
            context: context,
            backgroundColor: Colors.transparent,
            barrierColor: Theme.of(context).themeColors.blurBackground,
            builder: (_) => CircleJoinDialog(
              circle: circle,
            ),
          )
        : showDialog(
            context: context,
            barrierColor: Theme.of(context).themeColors.blurBackground,
            barrierDismissible: false,
            builder: (BuildContext context) => CircleJoinDialog(
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
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    _userProfileFetch =
        ref.read(repositoryProvider).userProfile(circlesCompleted: true);
    Future.delayed(const Duration(milliseconds: 0), () {
      initializeProvider();
    });
    ref.read(analyticsProvider).showScreen('joinCircleDialog');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textStyles;
    final commProvider = ref.watch(communicationsProvider);
    return Material(
      color: Colors.transparent,
      child: DeviceType.isPhone()
          ? BackdropFilter(
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
                                LucideIcons.x,
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
                                    horizontal: Theme.of(context)
                                        .pageHorizontalPadding),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minHeight: constraint.maxHeight),
                                  child: IntrinsicHeight(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          widget.circle.name,
                                          style: textStyles.headline1!.merge(
                                              const TextStyle(
                                                  fontWeight: FontWeight.w400)),
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
                                        Expanded(
                                            child: _userInfo(
                                                context, commProvider)),
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
            )
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
              child: Center(
                child: SingleChildScrollView(
                  child: DialogContainer(
                    padding: const EdgeInsets.only(
                        top: 50, bottom: 40, left: 40, right: 40),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1000,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              CircleImage(circle: widget.circle),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  widget.circle.name,
                                  style: textStyles.headline1!.merge(
                                      const TextStyle(
                                          fontWeight: FontWeight.w400)),
                                  //textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 16),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5, right: 5, top: 5, bottom: 5),
                                  child: Icon(
                                    LucideIcons.x,
                                    size: 24,
                                    color: themeColors.primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: _desktopUserInfo(context, commProvider),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _cameraPreview(CommunicationProvider commProvider, UserProfile user) {
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Stack(
          children: [
            kIsWeb
                ? const rtc_local_view.SurfaceView()
                : const rtc_local_view.TextureView(),
            if (commProvider.videoMuted)
              Positioned.fill(
                child: CameraMuted(
                  userImage: user.image,
                ),
              ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ThemedControlButton(
                label: commProvider.muted ? t.unmute : t.mute,
                labelColor: themeColors.reversedText,
                icon: commProvider.muted ? LucideIcons.micOff : LucideIcons.mic,
                onPressed: () {
                  commProvider.muteAudio(!commProvider.muted);
                  debugPrint('mute pressed');
                },
              ),
              const SizedBox(
                width: 15,
              ),
              ThemedControlButton(
                label: commProvider.videoMuted ? t.startVideo : t.stopVideo,
                labelColor: themeColors.reversedText,
                icon: commProvider.videoMuted
                    ? LucideIcons.videoOff
                    : LucideIcons.video,
                onPressed: () {
                  commProvider.muteVideo(!commProvider.videoMuted);
                  debugPrint('video pressed');
                },
              ),
              if (DeviceType.isMobile()) ...[
                const SizedBox(
                  width: 15,
                ),
                ThemedControlButton(
                  label: t.camera,
                  labelColor: themeColors.reversedText,
                  child: Icon(
                    LucideIcons.switchCamera,
                    size: 24,
                    color: themeColors.primaryText,
                  ),
                  onPressed: () {
                    commProvider.switchCamera();
                    debugPrint('video switch');
                  },
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _userInfo(BuildContext context, CommunicationProvider commProvider) {
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
                t.joinCircleMessage,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: Theme.of(context).maxRenderWidth),
                child: Column(
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
                            child: _initialized
                                ? _cameraPreview(commProvider, user)
                                : Center(
                                    child: Text(
                                      _error ?? t.initializingCamera,
                                      style: TextStyle(
                                        color: themeColors.reversedText,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_initialized)
                      Center(
                        child: ThemedRaisedButton(
                          onPressed: () {
                            _join(user);
                          },
                          label: _error == null ? t.joinCircle : t.leaveSession,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }

  Widget _desktopUserInfo(
      BuildContext context, CommunicationProvider commProvider) {
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Theme.of(context).maxRenderWidth,
                      ),
                      child: Column(children: [
                        AspectRatio(
                          aspectRatio: 1.0,
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(24)),
                            child: Container(
                              color: Colors.black,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _initialized
                                    ? _cameraPreview(commProvider, user)
                                    : Center(
                                        child: Text(
                                          _error ?? t.initializingCamera,
                                          style: TextStyle(
                                            color: themeColors.reversedText,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Theme.of(context).maxRenderWidth,
                        maxHeight: 260,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(height: 8),
                          if (_initialized)
                            Center(
                              child: ThemedRaisedButton(
                                onPressed: () {
                                  _error == null
                                      ? _join(user)
                                      : Navigator.of(context).pop();
                                },
                                label: _error == null
                                    ? t.joinCircle
                                    : t.leaveSession,
                              ),
                            ),
                          Text(
                            t.joinCircleMessage,
                            textAlign: TextAlign.center,
                          ),
                          if (_initialized)
                            const Center(
                              child: CircleDeviceSettingsButton(),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          );
        }
        return Container();
      },
    );
  }

  void _join(UserProfile user) {
    Navigator.of(context).pop(user);
  }

  void initializeProvider() async {
    final commProvider = ref.read(communicationsProvider);
    SystemVideo video = await ref.read(repositoryProvider).getSystemVideo();
    String? result = await commProvider.initialDevicePreview(video: video);
    if (result == null) {
      setState(() => _initialized = true);
    } else {
      // show error, can't get one of the devices or error with agora
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        switch (result) {
          case 'errorNoMicrophone':
            result = t.errorNoMicrophone;
            break;
          case 'errorCamera':
            result = t.errorCamera;
            break;
          case 'errorNoSpeakers':
            result = t.errorNoSpeakers;
            break;
        }
        setState(() => _error = result);
      }
    }
  }
}
