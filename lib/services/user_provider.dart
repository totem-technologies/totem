import 'dart:async';

import 'package:totem/models/index.dart';

abstract class UserProvider {
  Stream<UserProfile> userProfileStream({required String uid});
  Future<UserProfile?> userProfile(
      {required String uid, bool circlesCompleted = false});
  Future<void> updateUserProfile(
      {required UserProfile userProfile, required String uid});
  Future<void> updateUserProfileImage(
      {required String imageUrl, required String uid});
  Stream<List<Media>> userMedia({required String uid});
}
