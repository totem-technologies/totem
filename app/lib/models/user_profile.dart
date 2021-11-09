import 'package:flutter/foundation.dart';
import 'package:totem/models/date_name_ext.dart';

class UserProfile with ChangeNotifier {
  late String name;
  String? image;
  String? email;
  late DateTime createdOn;

  bool get hasImage {
    return image != null && image!.isNotEmpty;
  }

  String get userInitials {
    if (name.isNotEmpty) {
      int index = name.lastIndexOf(" ");
      if (index != -1) {
        try {
          String first = name.substring(0, 1);
          String last = name.substring(index + 1, index+2);
          return '$first$last';
        } catch (ex) {
          debugPrint('unable to parse name: ' + ex.toString());
        }
      }
      return name[0];
    }
    return "?";
  }

  UserProfile.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? "";
    image = json['image'];
    email = json['email'];
    createdOn = DateTimeEx.fromMapValue(json['created_on']) ?? DateTime.now();
  }

  Map<String, dynamic> toJson({bool updated=false}) {
    Map<String, dynamic> data = {
      "name": name,
      "created_on": createdOn,
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