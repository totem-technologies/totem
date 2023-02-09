import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/home/components/index.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/busy_indicator.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CirclesList extends ConsumerStatefulWidget {
  const CirclesList(
      {Key? key,
      required this.provider,
      required this.title,
      required this.description,
      this.noCircles})
      : super(key: key);
  final AutoDisposeStreamProvider<List<Circle>> provider;
  final String title;
  final String description;
  final Widget? noCircles;

  @override
  CirclesListState createState() => CirclesListState();
}

class CirclesListState extends ConsumerState<CirclesList> {
  @override
  Widget build(BuildContext context) {
    return ref.watch(widget.provider).when(
      data: (List<Circle> list) {
        if (list.isNotEmpty) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.only(
                        top: 20,
                        left: Theme.of(context).pageHorizontalPadding,
                        right: Theme.of(context).pageHorizontalPadding),
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textStyles.displayMedium,
                    ),
                  );
                }
                if (index == 1) {
                  return Padding(
                    padding: EdgeInsets.only(
                        left: Theme.of(context).pageHorizontalPadding,
                        right: Theme.of(context).pageHorizontalPadding,
                        bottom: 10),
                    child: Text(
                      widget.description,
                      style: Theme.of(context).textStyles.headlineMedium,
                    ),
                  );
                }
                return CircleItem(
                  circle: list[index - 2],
                  onPressed: (circle) => _handleShowCircle(context, circle),
                );
              },
              childCount: list.length + 2,
            ),
          );
        }
        return SliverToBoxAdapter(
          child: widget.noCircles ?? Container(),
        );
      },
      loading: () {
        return const SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: BusyIndicator(),
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
