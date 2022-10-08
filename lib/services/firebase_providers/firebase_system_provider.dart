import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:totem/models/index.dart';
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
    SystemVideo video = (await systemDoc.get()).data()!;
    return video;
  }

  @override
  Future<List<CircleTheme>> getSystemCircleThemes() async {
    final systemThemeCollection = FirebaseFirestore.instance
        .collection(Paths.system)
        .doc(Paths.systemCircle)
        .collection(Paths.systemCircleThemes)
        .withConverter<CircleTheme>(
          fromFirestore: (snapshots, _) {
            return CircleTheme.fromJson(snapshots.data()!);
          },
          toFirestore: (circleTheme, _) => circleTheme.toJson(),
        );
    final snapshot = await systemThemeCollection.get();
    List<CircleTheme> themes = snapshot.docs
        .map((DocumentSnapshot<CircleTheme> doc) => doc.data()!)
        .toList();
    return themes;
  }
}
