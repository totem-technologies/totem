import 'package:flutter/material.dart';
import 'package:totem/theme/index.dart';
import 'package:totem/app/circle/circle_page.dart';
import 'package:totem/app/home/components/index.dart';
import 'package:totem/components/widgets/busy_indicator.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CirclesList extends ConsumerStatefulWidget {
  const CirclesList({Key? key}) : super(key: key);

  @override
  CirclesListState createState() => CirclesListState();
}

class CirclesListState extends ConsumerState<CirclesList> {
  late Stream<List<ScheduledCircle>> _circles;
  final double bottomPadding = 80;

  @override
  void initState() {
    super.initState();
    _updateCircleQuery();
  }

  void _updateCircleQuery() {
    var repo = ref.read(repositoryProvider);
    setState(() {
      _circles = repo.scheduledCircles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return StreamBuilder<List<ScheduledCircle>>(
        stream: _circles,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: const BusyIndicator(),
              ),
            );
          }

          final list = snapshot.data ?? <ScheduledCircle>[];

          if (list.isNotEmpty) {
            return ListView.builder(
              padding: EdgeInsets.only(bottom: 100 + bottomPadding),
              itemCount: list.length,
              itemBuilder: (c, i) => CircleItem(
                circle: list[i],
                onPressed: (circle) => _handleShowCircle(context, circle),
              ),
            );
          }
          return _noCircles(context);
        });
  }

  Widget _noCircles(BuildContext context) {
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
          left: themeData.pageHorizontalPadding,
          right: themeData.pageHorizontalPadding,
          bottom: bottomPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.noCirclesMessage,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleShowCircle(BuildContext context, ScheduledCircle circle) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => CirclePage(circle: circle)));
  }
}
