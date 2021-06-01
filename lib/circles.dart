import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  String full_name = '';
  String company = '';
}

class UserInformation extends StatefulWidget {
  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        List<QueryDocumentSnapshot<User?>> users =
            snapshot.data?.docs as List<QueryDocumentSnapshot<User?>>;

        if (users == null) {
          users = [];
        }

        return new ListView(
          children: users.map((DocumentSnapshot document) {
            return new ListTile(
              title: new Text(document.data()!['full_name']),
              subtitle: new Text(document.data()!['company']),
            );
          }).toList(),
        );
      },
    );
  }
}
