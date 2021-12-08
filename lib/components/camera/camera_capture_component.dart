import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/theme/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum CaptureMode { videoAndPhoto, videoOnly, photoOnly }

class CameraCapture extends StatefulWidget {
  const CameraCapture({
    Key? key,
    this.captureMode = CaptureMode.videoAndPhoto,
    required this.onImageTaken,
  }) : super(key: key);
  final CaptureMode captureMode;
  final void Function(XFile) onImageTaken;
  @override
  CameraCaptureScreenState createState() => CameraCaptureScreenState();
}

class CameraCaptureScreenState extends State<CameraCapture>
    with AutomaticKeepAliveClientMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _initialized = false;
  bool _error = false;
  // bool _saving = false;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 0), () {
      _initCamera();
    });
    super.initState();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      int startIndex = 0;
      // start with the front facing camera if available
      for (int i = 0; i < _cameras!.length; i++) {
        if (_cameras![i].lensDirection == CameraLensDirection.front) {
          startIndex = i;
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
    return LayoutBuilder(builder: (context, constraints) {
      return _buildContent(context, constraints);
    });
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

  Widget _buildContent(BuildContext context, BoxConstraints constraints) {
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
    return Stack(
      children: <Widget>[
        _buildCameraPreview(context, constraints),
        _buildCameraControl(context),
        _buildCameraSelectorControl(context),
      ],
    );
  }

  Widget _buildCameraPreview(BuildContext context, BoxConstraints constraints) {
    var size = MediaQuery.of(context).size;
    var scale = size.width / _controller!.value.previewSize!.width;
    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Container(
      constraints: const BoxConstraints.expand(),
      child: Center(
        child: Transform.scale(
          scale: scale,
          child: CameraPreview(_controller!),
        ),
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
    if (_controller != null) {
      await _controller!.dispose();
    }
    _controller = CameraController(cameraDescription, ResolutionPreset.medium);
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
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/media';
      await Directory(dirPath).create(recursive: true);
      final String filePath = '$dirPath/${_timestamp()}.jpeg';
      debugPrint('path: $filePath');
      XFile file = await _controller!.takePicture();
      widget.onImageTaken(file);
    }
  }

  String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

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
}
