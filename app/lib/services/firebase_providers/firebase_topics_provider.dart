import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:totem/models/topic.dart';
import 'package:totem/services/firebase_providers/paths.dart';
import 'package:totem/services/topics_provider.dart';

class FirebaseTopicsProvider extends TopicsProvider {
  @override
  Stream<List<Topic>> topics({String sort = TopicSort.title}) {
    final collection = FirebaseFirestore.instance.collection(Paths.topics).withConverter<Topic>(
      fromFirestore: (snapshots, _) => Topic.fromJson(snapshots.data()!),
      toFirestore: (topic, _) => topic.toJson(),
    );
    final query = collection.orderBy(sort, descending: false);
    return query.snapshots().transform(
      StreamTransformer<QuerySnapshot<Topic>, List<Topic>>.fromHandlers(
        handleData: (QuerySnapshot<Topic> querySnapshot, EventSink<List<Topic>> sink) {
          List<Topic> topics = querySnapshot.docs.map((DocumentSnapshot<Topic> doc) => doc.data()!).toList();
          sink.add(topics);
        }
      )
    );
  }
}