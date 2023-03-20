import 'package:flutter/material.dart';
import 'package:totem/app/home/components/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopicsList extends ConsumerStatefulWidget {
  const TopicsList({Key? key}) : super(key: key);

  @override
  TopicsListState createState() => TopicsListState();
}

class TopicsListState extends ConsumerState<TopicsList> {
  late Stream<List<Topic>> _topics;

  @override
  void initState() {
    super.initState();
    _updateTopicsQuery();
  }

  void _updateTopicsQuery({String sort = TopicSort.title}) {
    var repo = ref.read(repositoryProvider);
    setState(() {
      _topics = repo.topics(sort: sort);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Topic>>(
        stream: _topics,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data ?? <Topic>[];

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (c, i) => TopicItem(
              topic: list[i],
              onPressed: (topic) => _handleShowTopic(context, topic),
            ),
          );
        });
  }

  void _handleShowTopic(BuildContext context, Topic topic) {}
}
