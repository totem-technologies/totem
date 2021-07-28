import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:totem/components/widgets/Header.dart';
import 'package:totem/models/Topics.dart';
import 'package:totem/services/topics.dart';

class TopicsList extends StatefulWidget {
  const TopicsList({Key? key}) : super(key: key);

  @override
  _TopicsListState createState() => _TopicsListState();
}

class _TopicsListState extends State<TopicsList> {
  late Query<Topic> _topicsQuery;
  late Stream<QuerySnapshot<Topic>> _topics;

  @override
  void initState() {
    super.initState();
    _updateTopicsQuery(TopicQuery.title);
  }

  void _updateTopicsQuery(TopicQuery query) {
    setState(() {
      _topicsQuery = topicsRef.queryBy(query);
      _topics = _topicsQuery.snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot<Topic>>(
          stream: _topics,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.requireData;

            return ListView.builder(
              clipBehavior: Clip.none,
              shrinkWrap: true,
              itemCount: data.size,
              itemBuilder: (c, i) => _TopicItem(topic: data.docs[i].data()),
            );
          }),
    );
  }
}

class _TopicItem extends StatelessWidget {
  const _TopicItem({Key? key, required this.topic}) : super(key: key);
  final Topic topic;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.all(Radius.circular(10))),
        // height: 100,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    topic.title,
                    style: TextStyle(fontSize: 20),
                  )),
              Text(topic.description)
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
        color: Colors.black,
        child: Center(
            child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Colors.grey[700],
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              )
            ],
          ),
          TotemHeader(text: 'Circles'),
          TopicsList()
        ])),
      ),
    ));
  }
}
