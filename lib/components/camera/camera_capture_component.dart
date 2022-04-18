import 'dart:io';
import 'dart:typed_data';

import 'package:after_layout/after_layout.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:totem/components/camera/camera_muted.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/theme/index.dart';
import 'package:uuid/uuid.dart';

enum CaptureMode { videoAndPhoto, videoOnly, photoOnly, preview }

class CameraCapture extends StatefulWidget {
  const CameraCapture({
    Key? key,
    this.captureMode = CaptureMode.videoAndPhoto,
    this.mirrorFrontImage = true,
    this.cropImage = true,
    this.onImageTaken,
  }) : super(key: key);
  final CaptureMode captureMode;
  final bool mirrorFrontImage;
  final bool cropImage;
  final void Function(XFile)? onImageTaken;
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
  bool _retry = false;
  bool _muted = false;
  bool _videoMuted = false;
  CameraImage? _savedImage;
  PermissionStatus? _permissionError;

  bool get muted {
    return _muted;
  }

  bool get videoMuted {
    return _videoMuted;
  }

  Future<void> _initCamera() async {
    // check camera permissions here
    if (!kIsWeb) {
      PermissionStatus status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        setState(() {
          _permissionError = status;
          _error = true;
          _retry = false;
        });
        return;
      }
    }
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
      _controller = CameraController(
        _cameras![startIndex],
        ResolutionPreset.medium,
      );
      await _controller!.initialize();
      if (!mounted) {
        return;
      }
      setState(() {
        _initialized = true;
      });
      if (!kIsWeb && widget.captureMode != CaptureMode.preview) {
        _controller!.startImageStream((image) {
          _savedImage = image;
        });
      }
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
    final themeColor = Theme.of(context).themeColors;
    if (_permissionError != null) {
      return _buildCameraError(context);
    }
    if (_controller != null) {
      if (_initialized && !_controller!.value.isInitialized) {
        return _buildCameraError(context);
      }
    } else if (!_initialized) {
      final t = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BusyIndicator(
              color: themeColor.reversedText,
            ),
            const SizedBox(height: 20),
            Text(
              t.initializingCamera,
              style: TextStyle(color: themeColor.reversedText, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    if (_error) {
      return _buildCameraError(context);
    }
    return Stack(
      children: <Widget>[
        Container(
          color: themeColor.primaryText,
        ),
        if (_initialized) _buildCameraPreview(context),
        if (!_saving && _videoMuted) const CameraMuted(),
        if (_saving)
          Positioned.fill(
            child: Center(
              child: BusyIndicator(
                color: themeColor.reversedText,
              ),
            ),
          ),
        if (!_saving && widget.captureMode != CaptureMode.preview)
          _buildCameraControl(context),
        if (!_saving && widget.captureMode == CaptureMode.preview)
          _buildCameraPreviewControls(context),
        if (!_saving && _cameras != null && _cameras!.length > 1)
          _buildCameraSelectorControl(context),
      ],
    );
  }

  Widget _buildCameraError(BuildContext context) {
    final themeColor = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;
    final errorStyle = TextStyle(color: themeColor.reversedText);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: themeColor.reversedText, size: 36),
            const SizedBox(
              height: 15,
            ),
            Text(t.errorCamera, style: errorStyle),
            if (_permissionError != null &&
                _permissionError != PermissionStatus.granted) ...[
              const SizedBox(height: 10),
              Text(
                t.errorCameraPermissions,
                style: errorStyle,
                textAlign: TextAlign.center,
              ),
            ],
            if (_permissionError != null) ...[
              const SizedBox(height: 30),
              Text(
                t.errorEnablePermissions,
                style: errorStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Center(
                child: ThemedRaisedButton(
                  label: _retry ? t.errorRetryStart : t.errorDeviceSettings,
                  onPressed: () {
                    // trigger app settings
                    if (!_retry) {
                      openAppSettings();
                      setState(() => _retry = true);
                    } else {
                      // user says they have reset, retry
                      setState(() {
                        _permissionError = null;
                        _error = false;
                      });
                      _initCamera();
                    }
                  },
                ),
              ),
            ],
            const SizedBox(
              height: 50,
            ),
          ],
        ),
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

  Widget _buildCameraPreviewControls(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final t = AppLocalizations.of(context)!;

    return Positioned(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ThemedControlButton(
            label: _muted ? t.unmute : t.mute,
            labelColor: themeColors.reversedText,
            svgImage:
                _muted ? 'assets/microphone_mute.svg' : 'assets/microphone.svg',
            onPressed: () {
              setState(() => _muted = !_muted);
              debugPrint('mute pressed');
            },
          ),
          const SizedBox(
            width: 20,
          ),
          ThemedControlButton(
            label: _videoMuted ? t.startVideo : t.stopVideo,
            labelColor: themeColors.reversedText,
            svgImage:
                _videoMuted ? 'assets/video.svg' : 'assets/video_stop.svg',
            onPressed: () {
              if (!_videoMuted) {
                _controller!.pausePreview();
              } else {
                _controller!.resumePreview();
              }
              setState(() => _videoMuted = !_videoMuted);

              debugPrint('video pressed');
            },
          ),
        ],
      ),
      left: 0,
      right: 0,
      bottom: 8,
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
              await HapticFeedback.heavyImpact();
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
    setState(() {
      _initialized = false;
    });
    final CameraDescription cameraDescription =
        (_controller!.description == _cameras![0])
            ? _cameras![1]
            : _cameras![0];
    _frontCamera = cameraDescription.lensDirection == CameraLensDirection.front;
    CameraController? _oldController = _controller;
    if (!kIsWeb && widget.captureMode != CaptureMode.preview) {
      await _oldController?.stopImageStream();
    }
    _controller = CameraController(cameraDescription, ResolutionPreset.medium);
    await _oldController?.dispose();
    _controller!.addListener(() {
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
      _initialized = true;
      if (!kIsWeb && widget.captureMode != CaptureMode.preview) {
        _controller!.startImageStream((image) {
          _savedImage = image;
        });
      }
    }
  }

  void _captureImage() async {
    debugPrint('_captureImage');
    if (_controller!.value.isInitialized) {
      debugPrint('About to pause preview');
      await _controller!.pausePreview();
      debugPrint('Pause Preview to take picture');
      if (!kIsWeb) {
        if (_savedImage != null) {
          setState(() => _saving = true);
          final Directory extDir = await getTemporaryDirectory();
          const uuid = Uuid();
          final path = extDir.path + "/" + uuid.v1() + ".jpg";
          final result = await compute(processImage, {
            'image': _savedImage!,
            'path': path,
            'mirror': (widget.mirrorFrontImage && _frontCamera),
            'crop': widget.cropImage,
            'rotation': _controller!.value.aspectRatio > 1
                ? (_frontCamera ? 270 : 90)
                : 0,
          });
          if (result != null && widget.onImageTaken != null) {
            XFile file = XFile(result);
            widget.onImageTaken!(file);
          } else {
            setState(() {
              _saving = false;
            });
            showInSnackBar('Camera error, unrecognized format');
          }
        } else {
          showInSnackBar('Camera error, unable to capture image');
        }
      } else {
        setState(() => _saving = true);
        XFile file = await _controller!.takePicture();
        List<int> bytes = await file.readAsBytes();
        List<int>? processedBytes = await compute(processLandscapePhoto, bytes);
        if (processedBytes != null) {
          file = XFile.fromData(Uint8List.fromList(processedBytes),
              mimeType: file.mimeType);
        }
        if (widget.onImageTaken != null) {
          widget.onImageTaken!(file);
        }
        setState(() => _saving = false);
      }
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
Future<String?> processImage(Map<String, dynamic> data) async {
  try {
    CameraImage image = data['image'];
    String path = data['path'];
    imglib.Image img;
    bool crop = data['crop'] ?? true;
    int rotation = data['rotation'] ?? 0;
    bool mirrorImage = data['mirror'] ?? true;
    if (image.format.group == ImageFormatGroup.yuv420) {
      // Convert yuv420 to rgb,
      final int width = image.width;
      final int height = image.height;
      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;
      img = imglib.Image(width, height);
      for (int x = 0; x < width; x++) {
        // Fill image buffer with plane[0] from YUV420_888
        for (int y = 0; y < height; y++) {
          final int uvIndex =
              uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
          final int index = y * uvRowStride +
              x; // Use the row stride instead of the image width as some devices pad the image data, and in those cases the image width != bytesPerRow. Using width will give you a distored image.
          final yp = image.planes[0].bytes[index];
          final up = image.planes[1].bytes[uvIndex];
          final vp = image.planes[2].bytes[uvIndex];
          int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
          int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
              .round()
              .clamp(0, 255);
          int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
          img.setPixelRgba(x, y, r, g, b);
        }
      }
      if (rotation != 0) {
        img = imglib.copyRotate(img, rotation);
      }
      if (mirrorImage) {
        img = imglib.flipHorizontal(img);
      }
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      // this format doesn't seem to require rotation/mirror manipulation
      img = imglib.Image.fromBytes(
        image.width,
        image.height,
        image.planes[0].bytes,
        format: imglib.Format.bgra,
      );
    } else if (image.format.group == ImageFormatGroup.jpeg) {
      imglib.Image? jpgImg = imglib.decodeJpg(image.planes[0].bytes);
      if (jpgImg == null) {
        return null;
      }
      img = jpgImg;
      if (rotation != 0) {
        img = imglib.copyRotate(img, rotation);
      }
      if (mirrorImage) {
        img = imglib.flipHorizontal(img);
      }
    } else {
      return null;
    }
    int top = (img.height / 2 - img.width / 2).toInt();
    if (crop) {
      img = imglib.copyCrop(img, 0, top, img.width, img.width);
    }
    File outfile = File(path);
    await outfile.writeAsBytes(
      imglib.encodeJpg(img),
      flush: true,
    );
    return path;
  } catch (e) {
    debugPrint("image processing error:" + e.toString());
  }
  return null;
}

// run as isolate in background
Future<List<int>?> processLandscapePhoto(List<int> imageBytes) async {
  imglib.Image? originalImage = imglib.decodeImage(imageBytes);
  if (originalImage != null) {
    // crop to a square
    int left = (originalImage.width / 2 - originalImage.height / 2).toInt();
    originalImage = imglib.copyCrop(
        originalImage, left, 0, originalImage.height, originalImage.height);
    List<int> bytes = imglib.encodePng(originalImage);
    return bytes;
  }
  return null;
}
