import 'package:totem/models/index.dart';
import 'package:totem/services/topics_provider.dart';
import 'firebase_providers/firebase_topics_provider.dart';

class TotemRepository {
  late final TopicsProvider _topicsProvider;
  TotemRepository() {
    _topicsProvider = FirebaseTopicsProvider();
  }

  Stream<List<Topic>> topics({String sort = TopicSort.title}) => _topicsProvider.topics(sort: sort);
}