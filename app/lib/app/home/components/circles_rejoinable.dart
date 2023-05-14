import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/home/components/index.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

final rejoinableCircles = StreamProvider.autoDispose<List<Circle>>((ref) {
  final repo = ref.read(repositoryProvider);
  return repo.rejoinableCircles();
});

class CirclesRejoinable extends ConsumerStatefulWidget {
  const CirclesRejoinable({Key? key, this.topPadding = 140}) : super(key: key);
  final double topPadding;

  @override
  CirclesRejoinableState createState() => CirclesRejoinableState();
}

class CirclesRejoinableState extends ConsumerState<CirclesRejoinable> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return ref.watch(rejoinableCircles).when(
          data: (List<Circle> data) {
            if (data.isNotEmpty) {
              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Theme.of(context).pageHorizontalPadding),
                      child: Text(
                        t.rejoinCircle,
                        style: Theme.of(context).textStyles.displayMedium,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CircleItem(
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
                  ],
                ),
              );
            }
            return SliverToBoxAdapter(child: Container());
          },
          loading: () => SliverToBoxAdapter(
            child: Container(),
          ),
          error: (Object error, StackTrace? stackTrace) => SliverToBoxAdapter(
            child: Container(),
          ),
        );
  }

  void _handleShowCircle(BuildContext context, Circle circle) {
    context
        .goNamed(AppRoutes.circle, pathParameters: {'id': circle.session.id});
  }
}
