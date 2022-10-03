import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:totem/models/system_video.dart';
import 'package:totem/services/firebase_providers/paths.dart';
import 'package:totem/services/index.dart';

class FirebaseSystemProvider extends SystemProvider {
  @override
  Future<SystemVideo> getSystemVideo() async {
    final systemDoc = FirebaseFirestore.instance
        .collection(Paths.system)
        .doc(Paths.systemVideo)
        .withConverter<SystemVideo>(
          fromFirestore: (snapshots, _) {
            return snapshots.data() != null
                ? SystemVideo.fromJson(snapshots.data()!)
                : SystemVideo();
          },
          toFirestore: (systemVideo, _) => systemVideo.toJson(),
        );
    DocumentSnapshot snapshot = await systemDoc.get();
    SystemVideo video = snapshot.data() != null
        ? snapshot.data()! as SystemVideo
        : SystemVideo();
    return video;
  }
}
