import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:totem/app/home/components/snap_circle_item.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/services/providers.dart';

final scheduledCirclesProvider = StreamProvider<List<Circle>>((ref) {
  final authService = ref.read(authServiceProvider);
  final totemRepository = ref.read(repositoryProvider);
  return ScheduledCirclesProvider(
          authStream: authService.onAuthStateChanged,
          repository: totemRepository)
      .stream;
});

class ScheduledCirclesList extends ConsumerStatefulWidget {
  const ScheduledCirclesList({Key? key}) : super(key: key);

  @override
  ScheduledCirclesListState createState() => ScheduledCirclesListState();
}

class ScheduledCirclesListState extends ConsumerState<ScheduledCirclesList> {
  @override
  Widget build(BuildContext context) {
    final scheduledCircles = ref.watch(scheduledCirclesProvider);
    return scheduledCircles.when(
      data: (List<Circle> list) {
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
        return SliverToBoxAdapter(
          child: Container(),
        );
      },
      loading: () {
        return const SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20),
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

  Future<void> _handleShowCircle(BuildContext context, Circle circle) async {
    if (!mounted) return;
    Map<String, String> params = {'id': circle.session.id};
    context.goNamed(AppRoutes.circle, params: params);
  }
}
