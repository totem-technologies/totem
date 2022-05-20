import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem/app/home/components/index.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/busy_indicator.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class SnapCirclesList extends ConsumerStatefulWidget {
  const SnapCirclesList({Key? key, this.topPadding = 140}) : super(key: key);
  final double topPadding;

  @override
  SnapCirclesListState createState() => SnapCirclesListState();
}

class SnapCirclesListState extends ConsumerState<SnapCirclesList> {
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
              padding: EdgeInsets.only(
                  bottom: bottomPadding, top: widget.topPadding),
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
          bottom: bottomPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            t.ooh,
            style: themeData.textStyles.headline2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 16,
          ),
          SvgPicture.asset('assets/face.svg'),
          const SizedBox(
            height: 16,
          ),
          Text(
            t.noSnapCirclesMessage,
            style: TextStyle(
                color: themeData.themeColors.secondaryText, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 24,
          ),
          const CreateCircleButton(),
        ],
      ),
    );
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
