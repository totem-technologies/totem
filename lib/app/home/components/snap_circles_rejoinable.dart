import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/home/components/index.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class SnapCirclesRejoinable extends ConsumerStatefulWidget {
  const SnapCirclesRejoinable({Key? key, this.topPadding = 140})
      : super(key: key);
  final double topPadding;

  @override
  SnapCirclesRejoinableState createState() => SnapCirclesRejoinableState();
}

class SnapCirclesRejoinableState extends ConsumerState<SnapCirclesRejoinable> {
  late Stream<List<SnapCircle>> _circles;

  @override
  void initState() {
    super.initState();
    _updateCircleQuery();
  }

  void _updateCircleQuery() {
    var repo = ref.read(repositoryProvider);
    setState(() {
      _circles = repo.rejoinableSnapCircles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 100;
    return StreamBuilder<List<SnapCircle>>(
        stream: _circles,
        builder: (context, snapshot) {
          if (snapshot.hasError ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          final list = snapshot.data ?? <SnapCircle>[];

          if (list.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Theme.of(context).pageHorizontalPadding),
                  child: Text(
                    "Rejoin circle",
                    style: Theme.of(context).textStyles.headline3,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SnapCircleItem(
                  circle: list[0],
                  onPressed: (circle) => _handleShowCircle(context, circle),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: Theme.of(context).pageHorizontalPadding),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).themeColors.divider,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: Theme.of(context).pageHorizontalPadding),
                  child: Text(
                    "Other circles",
                    style: Theme.of(context).textStyles.headline3,
                  ),
                ),
              ],
            );
          }
          return Container();
        });
  }

  Future<void> _handleShowCircle(
      BuildContext context, SnapCircle circle) async {
    var repo = ref.read(repositoryProvider);
    await repo.createActiveSession(
      circle: circle,
    );
    if (!mounted) return;
    Navigator.of(context).pushNamed(AppRoutes.circle, arguments: {
      'session': circle.snapSession,
    });
/*REMOVE    var repo = ref.read(repositoryProvider);
    Map<String, bool>? state =
        await CircleJoinDialog.showDialog(context, circle: circle);
    if (state != null) {
      await repo.createActiveSession(
        circle: circle,
      );
      Future.delayed(const Duration(milliseconds: 300), () async {
        Navigator.of(context).pushNamed(AppRoutes.circle, arguments: {
          'session': circle.snapSession,
          'state': state,
        });
      });
    } */
  }
}
