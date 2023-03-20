import 'package:flutter/foundation.dart';
import 'package:totem/models/date_name_ext.dart';

class UserProfile with ChangeNotifier {
  late String name;
  String? image;
  String? email;
  late DateTime createdOn;
  late String uid;
  late String ref;
  int? completedCircles;
  late bool acceptedTOS;
  late bool ageVerified;

  bool get hasImage {
    return image != null && image!.isNotEmpty;
  }

  String get userInitials {
    if (name.isNotEmpty) {
      int index = name.lastIndexOf(" ");
      if (index != -1) {
        try {
          String first = name.substring(0, 1);
          String last = name.substring(index + 1, index + 2);
          return '$first$last';
        } catch (ex) {
          debugPrint('unable to parse name: $ex');
        }
      }
      return name[0];
    }
    return "?";
  }

  UserProfile.fromJson(Map<String, dynamic> json,
      {required this.uid, required this.ref}) {
    name = json['name'] ?? "";
    image = json['image'];
    email = json['email'];
    acceptedTOS = json['acceptedTOS'] ?? false;
    ageVerified = json['ageVerified'] ?? false;
    createdOn = DateTimeEx.fromMapValue(json['created_on']) ?? DateTime.now();
  }

  Map<String, dynamic> toJson({bool updated = false}) {
    Map<String, dynamic> data = {
      "name": name,
      "created_on": createdOn,
      "acceptedTOS": acceptedTOS,
      "ageVerified": ageVerified,
    };
    if (image != null) {
      data["image"] = image!;
    }
    if (email != null) {
      data["email"] = email!;
    }
    if (updated) {
      data["updated_on"] = DateTime.now();
    }

    return data;
  }
}
