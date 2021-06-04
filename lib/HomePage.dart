import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'components/Header.dart';
import 'components/Button.dart';
import 'models/Topics.dart';

/// A reference to the list of movies.
/// We are using `withConverter` to ensure that interactions with the collection
/// are type-safe.
/// Pattern from https://github.com/FirebaseExtended/flutterfire/blob/master/packages/cloud_firestore/cloud_firestore/example/lib/main.dart
final topicsRef =
    FirebaseFirestore.instance.collection('topics').withConverter<Topic>(
          fromFirestore: (snapshots, _) => Topic.fromJson(snapshots.data()!),
          toFirestore: (movie, _) => movie.toJson(),
        );

/// The different ways that we can filter/sort.
enum TopicQuery {
  title,
}

extension on Query<Topic> {
  /// Create a firebase query from a [TopicQuery]
  Query<Topic> queryBy(TopicQuery query) {
    switch (query) {
      case TopicQuery.title:
        return orderBy('title', descending: false);
    }
  }
}

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
    _updateMoviesQuery(TopicQuery.title);
  }

  void _updateMoviesQuery(TopicQuery query) {
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
              shrinkWrap: true,
              itemCount: data.size,
              itemBuilder: (context, index) {
                return _TopicItem(topic: data.docs[index].data());
              },
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
    var auth = FirebaseAuth.instance;
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
            child: Column(children: [
          TotemHeader(text: 'Topics'),
          TopicsList(),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: TotemButton(
              icon: Icons.logout,
              text: 'Logout',
              onPressed: (stop) async {
                await auth.signOut();
              },
            ),
          )
        ])),
      ),
    );
  }
}
