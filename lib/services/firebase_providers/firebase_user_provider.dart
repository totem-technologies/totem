import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/firebase_providers/paths.dart';
import 'package:totem/services/index.dart';

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
  Stream<AccountState> userAccountStateStream({required String uid}) {
    final userAccountStateDoc =
        FirebaseFirestore.instance.collection(Paths.userAccountState).doc(uid);
    return userAccountStateDoc.snapshots().transform(
      StreamTransformer<DocumentSnapshot<Map<String, dynamic>>,
          AccountState>.fromHandlers(
        handleData: (DocumentSnapshot<Map<String, dynamic>> docSnapshot,
            EventSink<AccountState> sink) {
          if (docSnapshot.exists) {
            sink.add(AccountState.fromJson(docSnapshot.data()!));
          } else {
            sink.add(AccountState());
          }
        },
      ),
    );
  }

  @override
  Future<AccountState> userAccountState({required String uid}) async {
    final userAccountStateDoc =
        FirebaseFirestore.instance.collection(Paths.userAccountState).doc(uid);
    final docSnapshot = await userAccountStateDoc.get();
    if (docSnapshot.exists) {
      return AccountState.fromJson(docSnapshot.data()!);
    } else {
      return AccountState();
    }
  }

  @override
  Future<void> updateAccountStateValue(
      {required String uid,
      required String key,
      required dynamic value}) async {
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('updateAccountState');
      final data = {"key": key, "value": value};
      await callable(data);
    } on FirebaseException catch (e) {
      throw (ServiceException(code: e.code, message: e.message));
    } catch (e) {
      throw (ServiceException(
          code: ServiceException.errorCodeUnknown, message: e.toString()));
    }
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
      debugPrint('error updating user profile: $ex');
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
      debugPrint('error updating user profile image: $ex');
    }
  }
}
