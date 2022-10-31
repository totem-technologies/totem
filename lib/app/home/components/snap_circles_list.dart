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

final snapCircles = StreamProvider.autoDispose<List<SnapCircle>>((ref) {
  final repo = ref.read(repositoryProvider);
  return repo.snapCircles();
});

class SnapCirclesList extends ConsumerStatefulWidget {
  const SnapCirclesList({Key? key, this.topPadding = 140}) : super(key: key);
  final double topPadding;

  @override
  SnapCirclesListState createState() => SnapCirclesListState();
}

class SnapCirclesListState extends ConsumerState<SnapCirclesList> {
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 100;
    return ref.watch(snapCircles).when(
      data: (List<SnapCircle> list) {
        if (list.isNotEmpty) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return SnapCircleItem(
                  circle: list[index],
                  onPressed: (circle) => _handleShowCircle(context, circle),
                );
              },
              childCount: list.length,
            ),
          );
        }
        return SliverFillRemaining(
          child: _noCircles(context, bottomPadding),
        );
      },
      loading: () {
        return SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: const BusyIndicator(),
            ),
          ),
        );
      },
      error: (Object error, StackTrace? stackTrace) {
        return SliverToBoxAdapter(
          child: Center(
            child: Text(error.toString()),
          ),
        );
      },
    );
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
        ],
      ),
    );
  }

  Future<void> _handleShowCircle(
      BuildContext context, SnapCircle circle) async {
    if (!mounted) return;
    Map<String, String> params = {'id': circle.snapSession.id};
    context.goNamed(AppRoutes.circle, params: params);
  }
}
