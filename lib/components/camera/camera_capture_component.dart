import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image/image.dart' as img;
import 'package:totem/components/widgets/index.dart';
import 'package:totem/theme/index.dart';

enum CaptureMode { videoAndPhoto, videoOnly, photoOnly }

class CameraCapture extends StatefulWidget {
  const CameraCapture({
    Key? key,
    this.captureMode = CaptureMode.videoAndPhoto,
    this.mirrorFrontImage = true,
    this.cropImage = true,
    required this.onImageTaken,
  }) : super(key: key);
  final CaptureMode captureMode;
  final bool mirrorFrontImage;
  final bool cropImage;
  final void Function(XFile) onImageTaken;
  @override
  CameraCaptureScreenState createState() => CameraCaptureScreenState();
}

class CameraCaptureScreenState extends State<CameraCapture>
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin<CameraCapture> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _initialized = false;
  bool _error = false;
  bool _frontCamera = false;
  bool _saving = false;

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      int startIndex = 0;
      // start with the front facing camera if available
      for (int i = 0; i < _cameras!.length; i++) {
        if (_cameras![i].lensDirection == CameraLensDirection.front) {
          startIndex = i;
          _frontCamera = true;
          break;
        }
      }
      _controller =
          CameraController(_cameras![startIndex], ResolutionPreset.medium);
      _controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _initialized = true;
        });
      });
    } else {
      setState(() {
        _initialized = true;
        _error = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_controller != null) {
      if (!_controller!.value.isInitialized) {
        return _buildCameraError(context);
      }
    } else if (!_initialized) {
      return const Center(
        child: BusyIndicator(),
      );
    }
    if (_error) {
      return _buildCameraError(context);
    }
    final themeColor = Theme.of(context).themeColors;
    return Stack(
      children: <Widget>[
        Container(
          color: themeColor.primaryText,
        ),
        _buildCameraPreview(context),
        if (_saving)
          Positioned.fill(
            child: Center(
              child: BusyIndicator(
                color: themeColor.reversedText,
              ),
            ),
          ),
        if (!_saving) _buildCameraControl(context),
        if (!_saving) _buildCameraSelectorControl(context),
      ],
    );
  }

  Widget _buildCameraError(BuildContext context) {
    final themeColor = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: themeColor.reversedText, size: 36),
          const SizedBox(
            height: 15,
          ),
          Text(t.errorCamera, style: TextStyle(color: themeColor.reversedText)),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(BuildContext context) {
    return Center(
      child: Transform.scale(
        scale: _controller!.value.aspectRatio,
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _buildCameraSelectorControl(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return Positioned(
      child: InkWell(
        onTap: () async {
          await HapticFeedback.lightImpact();
          _onCameraSwitch();
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(
              color: themeColors.divider.withAlpha(184),
              width: 1.0,
            ),
            color: themeColors.trayBackground.withAlpha(204),
            boxShadow: [
              BoxShadow(
                  color: themeColors.shadow,
                  offset: const Offset(0, -8),
                  blurRadius: 24),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.cameraswitch,
              color: themeColors.primaryText,
            ),
          ),
        ),
      ),
      right: 12,
      bottom: 12,
    );
  }

  Widget _buildCameraControl(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    return Positioned(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () async {
              HapticFeedback.heavyImpact();
              _captureImage();
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: themeColors.profileBackground,
                  width: 4.0,
                ),
                color: Colors.white.withAlpha(120),
              ),
            ),
          ),
        ],
      ),
      left: 0,
      right: 0,
      bottom: 8,
    );
  }

  Future<void> _onCameraSwitch() async {
    final CameraDescription cameraDescription =
        (_controller!.description == _cameras![0])
            ? _cameras![1]
            : _cameras![0];
    _frontCamera = cameraDescription.lensDirection == CameraLensDirection.front;
    if (_controller != null) {
      await _controller!.dispose();
    }
    _controller = CameraController(cameraDescription, ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.jpeg);
    _controller!.addListener(() {
      if (mounted) setState(() {});
      if (_controller!.value.hasError) {
        showInSnackBar('Camera error ${_controller!.value.errorDescription}');
      }
    });

    try {
      await _controller!.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _captureImage() async {
    debugPrint('_captureImage');
    if (_controller!.value.isInitialized) {
      await _controller!.pausePreview();
      XFile file = await _controller!.takePicture();
      setState(() => _saving = true);
      if (widget.cropImage || (widget.mirrorFrontImage && _frontCamera)) {
        await compute(processPhoto,
            '${file.path}|${widget.cropImage.toString()}|${(_frontCamera && widget.mirrorFrontImage).toString()}');
      }
      widget.onImageTaken(file);
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description ?? "");
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void logError(String code, String message) =>
      debugPrint('Error: $code\nError Message: $message');

  @override
  bool get wantKeepAlive => true;

  @override
  void afterFirstLayout(BuildContext context) {
    _initCamera();
  }
}

// run as isolate in background
void processPhoto(String values) async {
  List<String> params = values.split("|");
  File file = File(params[0]);
  bool crop = (params.length > 1) ? params[1] == 'true' : false;
  bool mirror = (params.length > 2) ? params[2] == 'true' : false;
  List<int> imageBytes = await file.readAsBytes();
  img.Image? originalImage = img.decodeImage(imageBytes);
  if (originalImage != null) {
    if (mirror) {
      // have to flip the image to mirrored as the output is no mirrored
      originalImage = img.flipHorizontal(originalImage);
    }
    if (crop) {
      // crop to a square
      int top = (originalImage.height / 2 - originalImage.width / 2).toInt();
      originalImage = img.copyCrop(
          originalImage, 0, top, originalImage.width, originalImage.width);
    }
    File outfile = File(file.path);
    await outfile.writeAsBytes(
      img.encodeJpg(originalImage),
      flush: true,
    );
  }
}
