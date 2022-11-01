import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

import 'snap_circle_item.dart';

final userPrivateCircles = StreamProvider.autoDispose<List<SnapCircle>>((ref) {
  final repo = ref.read(repositoryProvider);
  return repo.mySnapCircles();
});

class NamedCircleList extends ConsumerWidget {
  const NamedCircleList({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<SnapCircle> privateWaitingCircles = [];
    return ref.watch(userPrivateCircles).when(
      data: (List<SnapCircle> data) {
        if (data.isNotEmpty) {
          privateWaitingCircles = data
              .where((element) => element.state == SessionState.waiting)
              .toList();
        }
        return SliverToBoxAdapter(
          child: privateWaitingCircles.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Theme.of(context).pageHorizontalPadding),
                      child: Text(
                        name,
                        style: Theme.of(context).textStyles.headline2,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ..._buildCircleList(context, privateWaitingCircles),
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
                  ],
                )
              : Container(),
        );
      },
      error: (Object error, StackTrace? stackTrace) {
        return SliverToBoxAdapter(
          child: Container(),
        );
      },
      loading: () {
        return SliverToBoxAdapter(
          child: Container(),
        );
      },
    );
  }

  List<Widget> _buildCircleList(
      BuildContext context, List<SnapCircle> circles) {
    List<Widget> circleList = circles
        .map<Widget>((circle) => SnapCircleItem(
              circle: circle,
              onPressed: (circle) => _handleShowCircle(context, circle),
            ))
        .toList();
    return circleList;
  }

  void _handleShowCircle(BuildContext context, SnapCircle circle) {
    context.goNamed(AppRoutes.circle, params: {'id': circle.snapSession.id});
  }
}
