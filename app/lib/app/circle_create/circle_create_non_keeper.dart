import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/circle_duration_option.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/error_report.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

class CircleCreateNonKeeper extends ConsumerStatefulWidget {
  const CircleCreateNonKeeper({super.key, this.fromCircle});
  final Circle? fromCircle;
  static Future<Circle?> showNonKeeperCreateDialog(BuildContext context) async {
    return showDialog<Circle?>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      barrierColor: Theme.of(context).themeColors.blurBackground,
      builder: (_) => Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
          child: Center(
            child: SingleChildScrollView(
              child: DialogContainer(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: Theme.of(context).maxRenderWidth),
                  child: const CircleCreateNonKeeper(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  CircleCreateNonKeeperState createState() => CircleCreateNonKeeperState();
}

class CircleCreateNonKeeperState extends ConsumerState<CircleCreateNonKeeper> {
  final _formKey = GlobalKey<FormState>();
  late final List<CircleDurationOption> durationOptions;

  bool _busy = false;
  late CircleDurationOption _selectedDuration;
  final double maxParticipants = 5;
  double numParticipants = 5;
  CircleTheme? _selectedTheme;

  @override
  void initState() {
    numParticipants = maxParticipants;
    durationOptions = [
      CircleDurationOption(value: 15),
      CircleDurationOption(value: 20),
      CircleDurationOption(value: 30),
      CircleDurationOption(value: 45),
      CircleDurationOption(value: 55),
      CircleDurationOption(value: 60),
    ];
    _selectedDuration = durationOptions.last;
    ref.read(analyticsProvider).showScreen('circleCreateNonKeeper');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    final themeColors = themeData.themeColors;
    final t = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: themeData.pageHorizontalPadding),
                Expanded(
                  child: Text(
                    t.createNewCircle,
                    style: textStyles.displayMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                const SizedBox(width: 8),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: themeData.pageHorizontalPadding),
              child: _userCreateForm(),
            ),
          ],
        ),
        if (_busy)
          const Positioned.fill(
            child: Center(
              child: BusyIndicator(),
            ),
          )
      ],
    );
  }

  Widget _userCreateForm() {
    final t = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 46,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _durationOptions(),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _participantLimit(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: ThemedRaisedButton(
              label: t.createCircle,
              onPressed: !_busy
                  ? () {
                      _saveCircle();
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _saveCircle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    final userProfile = await ref.read(repositoryProvider).userProfile();
    if (!mounted) {
      return;
    }
    _formKey.currentState!.save();
    final t = AppLocalizations.of(context)!;
    var repo = ref.read(repositoryProvider);
    try {
      final circle = await repo.createCircle(
        name: t.usersCircle(userProfile?.name ?? ""),
        keeper: widget.fromCircle?.keeper,
        previousCircle: widget.fromCircle?.id,
        isPrivate: true,
        duration: _selectedDuration.value,
        maxParticipants: numParticipants.toInt(),
        themeRef: _selectedTheme?.ref,
        imageUrl: _selectedTheme?.image,
        bannerUrl: _selectedTheme?.bannerImage,
      );
      if (circle != null) {
        if (!mounted) return;
        Navigator.of(context).pop(circle);
        return;
      }
    } on ServiceException catch (ex, stack) {
      debugPrint('Error creating circle: $ex');
      await reportError(ex, stack);
      await _showCreateError(ex);
    }
    setState(() => _busy = false);
  }

  Future<void> _showCreateError(ServiceException exception) async {
    final t = AppLocalizations.of(context)!;
    AlertDialog alert = AlertDialog(
      title: Text(t.errorCreateSnapCircle),
      content: Text(exception.toString()),
      actions: [
        TextButton(
          child: Text(t.ok),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
    // show the dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _participantLimit() {
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.participantLimit, style: textStyles.displaySmall),
        const SizedBox(height: 6),
        SpinBox(
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          min: CircleTemplate.minParticipants.toDouble(),
          max: maxParticipants,
          value: numParticipants,
          onChanged: (value) {
            setState(() {
              numParticipants = value;
            });
          },
        ),
        const SizedBox(height: 4),
        Text(
          t.maximumParticipants(maxParticipants.toInt().toString()),
          style: textStyles.headlineMedium,
        ),
      ],
    );
  }

  Widget _durationOptions() {
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.duration, style: textStyles.displaySmall),
        const SizedBox(height: 10),
        _durationDropDown(
          durationOptions,
          selected: _selectedDuration,
          onChanged: (item) {
            setState(() => _selectedDuration = item);
          },
        ),
      ],
    );
  }

  Widget _durationDropDown(List<CircleDurationOption> options,
      {required Function(dynamic item) onChanged,
      required CircleDurationOption? selected}) {
    if (options.isEmpty) return Container();
    final dropDownMenus = <DropdownMenuItem<CircleDurationOption>>[];
    for (var v in options) {
      dropDownMenus.add(
        DropdownMenuItem(
          value: v,
          child: Text(v.getName(context), overflow: TextOverflow.ellipsis),
        ),
      );
    }
    return SizedBox(
      height: 40,
      child: DropdownButton<CircleDurationOption>(
        isExpanded: true,
        items: dropDownMenus,
        value: selected,
        onChanged: (v) {
          onChanged(v);
        },
      ),
    );
  }
}
