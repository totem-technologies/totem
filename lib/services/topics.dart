import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Topics.dart';

/// A reference to the list of movies.
/// We are using `withConverter` to ensure that interactions with the collection
/// are type-safe.
/// Pattern from https://github.com/FirebaseExtended/flutterfire/blob/master/packages/cloud_firestore/cloud_firestore/example/lib/main.dart
final topicsRef =
    FirebaseFirestore.instance.collection('topics').withConverter<Topic>(
          fromFirestore: (snapshots, _) => Topic.fromJson(snapshots.data()!),
          toFirestore: (topic, _) => topic.toJson(),
        );

/// The different ways that we can filter/sort.
enum TopicQuery {
  title,
}

extension TopicQueryExt<Topic> on Query<Topic> {
  /// Create a firebase query from a [TopicQuery]
  Query<Topic> queryBy(TopicQuery query) {
    switch (query) {
      case TopicQuery.title:
        return orderBy('title', descending: false);
    }
  }
}
