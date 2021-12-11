import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/circle_join_dialog.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/app/home/components/index.dart';
import 'package:totem/app/home/components/snap_circle_item.dart';
import 'package:totem/components/widgets/busy_indicator.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class SnapCirclesList extends ConsumerStatefulWidget {
  const SnapCirclesList({Key? key}) : super(key: key);

  @override
  _SnapCirclesListState createState() => _SnapCirclesListState();
}

class _SnapCirclesListState extends ConsumerState<SnapCirclesList> {
  late Stream<List<SnapCircle>> _circles;

  @override
  void initState() {
    super.initState();
    _updateCircleQuery();
  }

  void _updateCircleQuery() {
    var repo = ref.read(repositoryProvider);
    setState(() {
      _circles = repo.snapCircles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 100;
    return StreamBuilder<List<SnapCircle>>(
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

          final list = snapshot.data ?? <SnapCircle>[];

          if (list.isNotEmpty) {
            return ListView.builder(
              padding: EdgeInsets.only(bottom: bottomPadding),
              itemCount: list.length,
              itemBuilder: (c, i) => SnapCircleItem(
                circle: list[i],
                onPressed: (circle) => _handleShowCircle(context, circle),
              ),
            );
          }
          return _noCircles(context, bottomPadding);
        });
  }

  Widget _noCircles(BuildContext context, double bottomPadding) {
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
          left: themeData.pageHorizontalPadding,
          right: themeData.pageHorizontalPadding,
          bottom: bottomPadding + 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.noSnapCirclesMessage,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handleShowCircle(
      BuildContext context, SnapCircle circle) async {
    var repo = ref.read(repositoryProvider);
    String? sessionImage =
        await CircleJoinDialog.showDialog(context, session: circle.snapSession);
    if (sessionImage != null && sessionImage.isNotEmpty) {
      await repo.createActiveSession(
        session: circle.activeSession!,
      );
      Future.delayed(const Duration(milliseconds: 300), () async {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CircleSessionPage(
                session: circle.snapSession, sessionImage: sessionImage),
          ),
        );
      });
    }
  }
}
