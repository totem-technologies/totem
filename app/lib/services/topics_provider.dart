import 'package:totem/models/index.dart';

class TopicSort {
  static const String title = "title";
}

abstract class TopicsProvider {
  Stream<List<Topic>> topics({String sort});
}