import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/app/circle_create/components/theme_item.dart';
import 'package:totem/components/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

final circleThemesProvider =
    FutureProvider.autoDispose<List<CircleTheme>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.getSystemCircleThemes();
});

class ThemeSelector extends ConsumerStatefulWidget {
  const ThemeSelector({super.key, this.selected});
  final CircleTheme? selected;

  static Future<CircleTheme?> showDialog(BuildContext context,
      {CircleTheme? selected}) async {
    return showModalBottomSheet<CircleTheme>(
      enableDrag: false,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).themeColors.blurBackground,
      builder: (_) => ThemeSelector(selected: selected),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ThemeSelectorState();
}

class ThemeSelectorState extends ConsumerState<ThemeSelector> {
  CircleTheme? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textStyles;
    final t = AppLocalizations.of(context)!;
    final themes = ref.watch(circleThemesProvider);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 50,
          ),
          child: BottomTrayContainer(
            fullScreen: true,
            padding: const EdgeInsets.symmetric(
              vertical: 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: Theme.of(context).pageHorizontalPadding,
                    ),
                    Expanded(
                      child: Text(
                        t.selectTheme,
                        style: textStyles.dialogTitle,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        LucideIcons.x,
                        color: themeColors.primaryText,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Theme.of(context).pageHorizontalPadding,
                  ),
                  child: Divider(
                    thickness: 1,
                    height: 1,
                    color: themeColors.divider,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: Theme.of(context).pageHorizontalPadding,
                        right: Theme.of(context).pageHorizontalPadding,
                        bottom: 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: Theme.of(context).maxRenderWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: themes.when(
                                data: (data) {
                                  if (data.isEmpty) {
                                    return Center(
                                      child: Text(
                                        t.noThemes,
                                        style: textStyles.headline3,
                                      ),
                                    );
                                  }
                                  return ListView.separated(
                                    padding: const EdgeInsets.only(top: 20),
                                    itemCount: data.length,
                                    itemBuilder: (context, index) {
                                      return ThemeItem(
                                        theme: data[index],
                                        onTap: _selectTheme,
                                        selected:
                                            data[index].ref == selected?.ref,
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return const SizedBox(height: 5);
                                    },
                                  );
                                },
                                loading: () => const Center(
                                  child: BusyIndicator(),
                                ),
                                error: (error, stack) => const Center(
                                  child: Text('Error loading themes'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectTheme(CircleTheme theme) {
    setState(() {
      selected = theme;
    });
    Navigator.of(context).pop(theme);
  }
}
