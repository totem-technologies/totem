import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/models/snap_circle.dart';
import 'package:totem/theme/index.dart';

import 'snap_circle_item.dart';

class NamedCircleList extends ConsumerWidget {
  const NamedCircleList({Key? key, required this.name, required this.circles})
      : super(key: key);
  final String name;
  final List<SnapCircle> circles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          itemCount: circles.length,
          itemBuilder: (c, i) => SnapCircleItem(
            circle: circles[i],
            onPressed: (circle) => _handleShowCircle(context, circle),
          ),
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
      ],
    );
  }

  void _handleShowCircle(BuildContext context, SnapCircle circle) {
    context.goNamed(AppRoutes.circle, params: {'id': circle.snapSession.id});
  }
}
