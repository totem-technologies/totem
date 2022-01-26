import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:totem/models/user_profile.dart';
import 'package:totem/services/firebase_providers/paths.dart';
import 'package:totem/services/user_provider.dart';

class FirebaseUserProvider extends UserProvider {
  @override
  Stream<UserProfile> userProfileStream({required String uid}) {
    final userProfileDoc =
        FirebaseFirestore.instance.collection(Paths.users).doc(uid);
    return userProfileDoc.snapshots().transform(
      StreamTransformer<DocumentSnapshot<Map<String, dynamic>>,
              UserProfile>.fromHandlers(
          handleData: (DocumentSnapshot<Map<String, dynamic>> docSnapshot,
              EventSink<UserProfile> sink) {
        sink.add(UserProfile.fromJson(docSnapshot.data()!,
            uid: docSnapshot.id, ref: docSnapshot.reference.path));
      }),
    );
  }

  @override
  Future<UserProfile?> userProfile(
      {required String uid, bool circlesCompleted = false}) async {
    final userProfileDoc = FirebaseFirestore.instance
        .collection(Paths.users)
        .doc(uid)
        .withConverter<UserProfile>(
          fromFirestore: (snapshots, _) => UserProfile.fromJson(
              snapshots.data()!,
              uid: uid,
              ref: snapshots.reference.path),
          toFirestore: (userProfile, _) => userProfile.toJson(),
        );
    UserProfile? profile = (await userProfileDoc.get()).data();
    if (profile != null && circlesCompleted) {
      QuerySnapshot completed = await FirebaseFirestore.instance
          .collection(Paths.users)
          .doc(uid)
          .collection(Paths.snapCircles)
          .get();
      profile.completedCircles = completed.docs.length;
    }
    return profile;
  }

  @override
  Future<void> updateUserProfile(
      {required UserProfile userProfile, required String uid}) async {
    try {
      final userProfileDoc =
          FirebaseFirestore.instance.collection(Paths.users).doc(uid);
      await userProfileDoc.update(userProfile.toJson(updated: true));
    } catch (ex) {
      debugPrint('error updating user profile: ' + ex.toString());
    }
  }

  @override
  Future<void> updateUserProfileImage(
      {required String imageUrl, required String uid}) async {
    try {
      final userProfileDoc =
          FirebaseFirestore.instance.collection(Paths.users).doc(uid);
      await userProfileDoc.update({"image": imageUrl});
    } catch (ex) {
      debugPrint('error updating user profile image: ' + ex.toString());
    }
  }
}
