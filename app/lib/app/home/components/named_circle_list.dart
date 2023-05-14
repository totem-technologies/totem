import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

import 'circle_item.dart';

final userPrivateCircles = StreamProvider.autoDispose<List<Circle>>((ref) {
  final repo = ref.read(repositoryProvider);
  return repo.myCircles();
});

class NamedCircleList extends ConsumerWidget {
  const NamedCircleList({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Circle> privateWaitingCircles = [];
    return ref.watch(userPrivateCircles).when(
      data: (List<Circle> data) {
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
                        style: Theme.of(context).textStyles.displayMedium,
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

  List<Widget> _buildCircleList(BuildContext context, List<Circle> circles) {
    List<Widget> circleList = circles
        .map<Widget>((circle) => CircleItem(
              circle: circle,
              onPressed: (circle) => _handleShowCircle(context, circle),
            ))
        .toList();
    return circleList;
  }

  void _handleShowCircle(BuildContext context, Circle circle) {
    context
        .goNamed(AppRoutes.circle, pathParameters: {'id': circle.session.id});
  }
}
