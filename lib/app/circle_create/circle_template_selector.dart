import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:totem/components/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

final circleTemplateProvider =
    FutureProvider.autoDispose<List<CircleTemplate>>((ref) {
  final totemRepository = ref.read(repositoryProvider);
  return totemRepository.getSystemCircleTemplates();
});

class CircleTemplateSelector extends ConsumerStatefulWidget {
  const CircleTemplateSelector({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CircleTemplateSelectorState();
}

class CircleTemplateSelectorState
    extends ConsumerState<CircleTemplateSelector> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    final themeColors = themeData.themeColors;
    final t = AppLocalizations.of(context)!;
    final circleTemplates = ref.watch(circleTemplateProvider);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: themeData.pageHorizontalPadding),
            Text(
              t.createNewCircle,
              style: textStyles.headline2,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(child: Container()),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                LucideIcons.x,
                color: themeColors.primaryText,
              ),
            ),
            const SizedBox(width: 8),
            circleTemplates.when(data: (List<CircleTemplate> data) {
              if (data.isEmpty) {
                return Container();
              }
              return ResponsiveGridList(
                  minItemWidth: 200,
                  maxItemsPerRow: 4,
                  horizontalGridSpacing:
                      16, // Horizontal space between grid items
                  horizontalGridMargin: 50,
                  children:
                      data.map((template) => Text(template.name)).toList());
            }, error: (Object error, StackTrace stackTrace) {
              return Container();
            }, loading: () {
              return const Center(child: BusyIndicator());
            }),
          ],
        ),
      ],
    );
  }
}
