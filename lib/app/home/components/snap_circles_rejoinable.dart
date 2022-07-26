import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/home/components/index.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

final rejoinableCircles = StreamProvider.autoDispose<List<SnapCircle>>((ref) {
  final repo = ref.read(repositoryProvider);
  return repo.rejoinableSnapCircles();
});

class SnapCirclesRejoinable extends ConsumerStatefulWidget {
  const SnapCirclesRejoinable({Key? key, this.topPadding = 140})
      : super(key: key);
  final double topPadding;

  @override
  SnapCirclesRejoinableState createState() => SnapCirclesRejoinableState();
}

class SnapCirclesRejoinableState extends ConsumerState<SnapCirclesRejoinable> {
  @override
  Widget build(BuildContext context) {
    return ref.watch(rejoinableCircles).when(
          data: (List<SnapCircle> data) {
            if (data.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Theme.of(context).pageHorizontalPadding),
                    child: Text(
                      "Rejoin circle",
                      style: Theme.of(context).textStyles.headline2,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SnapCircleItem(
                    circle: data.first,
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
                      style: Theme.of(context).textStyles.headline2,
                    ),
                  ),
                ],
              );
            }
            return Container();
          },
          loading: () => Container(),
          error: (Object error, StackTrace? stackTrace) => Container(),
        );
  }

  Future<void> _handleShowCircle(
      BuildContext context, SnapCircle circle) async {
    var repo = ref.read(repositoryProvider);
    await repo.createActiveSession(
      circle: circle,
    );
    if (!mounted) return;
    context.go(AppRoutes.circle(circle.snapSession.id));
  }
}
