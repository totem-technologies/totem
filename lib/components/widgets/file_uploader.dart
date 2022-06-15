import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/components/widgets/busy_indicator.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/providers.dart';
import 'package:totem/theme/index.dart';
import 'package:uuid/uuid.dart';

class FileUploader extends ConsumerStatefulWidget {
  const FileUploader({
    Key? key,
    this.onComplete,
    this.clearFile = false,
    this.assignProfile = true,
    this.showBusy = true,
  }) : super(key: key);
  final Function(String?, String?)? onComplete;
  final bool clearFile;
  final bool assignProfile;
  final bool showBusy;

  @override
  FileUploaderState createState() => FileUploaderState();
}

class FileUploaderState extends ConsumerState<FileUploader> {
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;
  firebase_storage.UploadTask? _uploadTask;
  Map<String, dynamic>? upload;
  String? uploadContext;

  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null) {
      return StreamBuilder<firebase_storage.TaskSnapshot>(
        stream: _uploadTask!.snapshotEvents,
        builder: (context, snapshot) {
          //var event = snapshot?.data?.snapshot;
          //double progressPercent = event != null ? event.bytesTransferred / event.totalByteCount : 0;
          return widget.showBusy
              ? Center(
                  child: BusyIndicator(
                    color: Theme.of(context).themeColors.reversedText,
                  ),
                )
              : Container();
        },
      );
    } else {
      return Container();
    }
  }

  Future<void> profileImageUpload(XFile upload, AuthUser user) async {
    const uuid = Uuid();
    try {
      firebase_storage.Reference ref =
          _storage.ref().child('user').child(user.uid).child(uuid.v1());
      Uint8List bytes = await upload.readAsBytes();

      setState(() {
        _uploadTask = ref.putData(bytes,
            firebase_storage.SettableMetadata(contentType: upload.mimeType));
      });
      firebase_storage.TaskSnapshot? snapshot = await _uploadTask;
      if (snapshot != null) {
        String url = await snapshot.ref.getDownloadURL();
        await _completeUpload(upload, url: url);
      }
    } on firebase_core.FirebaseException catch (e) {
      debugPrint(e.message);
      if (e.code == 'permission-denied') {
        debugPrint(
            'User does not have permission to upload to this reference.');
      }
      if (widget.onComplete != null) {
        widget.onComplete!(null, e.message);
      }
    }
  }

  Future<void> _completeUpload(XFile? upload, {String url = ''}) async {
    if (url.isNotEmpty && widget.assignProfile) {
      var repo = ref.read(repositoryProvider);
      await repo.updateUserProfileImage(url);
    }
    // await clearTemporaryFiles(upload);
    if (widget.onComplete != null) {
      widget.onComplete!(url, null);
    }
  }

  static Future<void> clearTemporaryFiles(File? upload) async {
    if (upload != null) {
      try {
        await upload.delete();
      } catch (ex) {
        debugPrint(ex.toString());
      }
    }
  }
}
