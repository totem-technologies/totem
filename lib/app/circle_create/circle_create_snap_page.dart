import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:totem/app/circle_create/components/index.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/models/snap_circle_duration_option.dart';
import 'package:totem/models/snap_circle_visibility_option.dart';
import 'package:totem/services/error_report.dart';
import 'package:totem/services/index.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';

class CircleCreateSnapPage extends ConsumerStatefulWidget {
  const CircleCreateSnapPage({Key? key, this.fromCircle}) : super(key: key);
  final Circle? fromCircle;

  @override
  CircleCreateSnapPageState createState() => CircleCreateSnapPageState();
}

class CircleCreateSnapPageState extends ConsumerState<CircleCreateSnapPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final _focusNodeDescription = FocusNode();
  late final List<CircleVisibilityOption> visibilityOptions;
  late final List<CircleDurationOption> durationOptions;

  bool _busy = false;
  late CircleVisibilityOption _selectedVisibility;
  late CircleDurationOption _selectedDuration;
  late final double maxParticipants;
  late final bool isKeeper;
  double numParticipants = 20;
  CircleTheme? _selectedTheme;

  @override
  void initState() {
    final authUser = ref.read(authServiceProvider).currentUser()!;
    isKeeper = authUser.hasRole(Role.keeper);
    maxParticipants = (isKeeper
            ? Circle.maxKeeperParticipants
            : Circle.maxNonKeeperParticipants)
        .toDouble();
    numParticipants = maxParticipants;
    if (widget.fromCircle != null) {
      _nameController.text = widget.fromCircle!.name;
      _descriptionController.text = widget.fromCircle!.description ?? "";
    }
    visibilityOptions = isKeeper
        ? [
            CircleVisibilityOption(name: 'public', value: false),
            CircleVisibilityOption(name: 'private', value: true),
          ]
        : [CircleVisibilityOption(name: 'private', value: true)];
    durationOptions = [
      CircleDurationOption(value: 15),
      CircleDurationOption(value: 20),
      CircleDurationOption(value: 30),
      CircleDurationOption(value: 45),
      CircleDurationOption(value: 55),
      CircleDurationOption(value: 60),
    ];
    if (isKeeper) {
      durationOptions.addAll([
        CircleDurationOption(value: 90),
        CircleDurationOption(value: 120),
        CircleDurationOption(value: 150),
        CircleDurationOption(value: 180),
        CircleDurationOption(value: 210),
        CircleDurationOption(value: 240),
        CircleDurationOption(value: 270),
        CircleDurationOption(value: 300),
      ]);
    }
    _selectedVisibility = visibilityOptions[0];
    _selectedDuration = durationOptions[5];
    ref.read(analyticsProvider).showScreen('createSnapCircleScreen');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    final t = AppLocalizations.of(context)!;
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // call this method here to hide soft keyboard
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              SafeArea(
                top: true,
                bottom: false,
                child: Column(
                  children: [
                    SubPageHeader(title: t.createNewCircle),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: Theme.of(context).maxRenderWidth),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: themeData.pageHorizontalPadding),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(
                                      height: 46,
                                    ),
                                    Text(t.circleName,
                                        style: textStyles.headline3),
                                    ThemedTextFormField(
                                      controller: _nameController,
                                      autofocus: true,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      textInputAction: TextInputAction.next,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return t.errorEnterName;
                                        }
                                        return null;
                                      },
                                      maxLines: 1,
                                      maxLength: 50,
                                    ),
                                    const SizedBox(height: 32),
                                    Text(t.description,
                                        style: textStyles.headline3),
                                    ThemedTextFormField(
                                      focusNode: _focusNodeDescription,
                                      controller: _descriptionController,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      maxLines: 0,
                                      textInputAction: TextInputAction.newline,
                                      maxLength: 1500,
                                    ),
                                    const SizedBox(height: 32),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _durationOptions(),
                                        ),
                                        const SizedBox(width: 32),
                                        Expanded(
                                          child: _visibilityOptions(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _participantLimit(),
                                        ),
                                        const SizedBox(width: 32),
                                        Expanded(
                                          child: Container(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                    _circleTheme(),
                                    const SizedBox(height: 40),
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
                                    const SizedBox(height: 50)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_busy)
                const Center(
                  child: BusyIndicator(),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleTheme() {
    final t = AppLocalizations.of(context)!;
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textStyles;
    final isPhone = DeviceType.isPhone();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.theme, style: textStyles.headline3),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: themeColors.divider, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_selectedTheme == null)
                Text(
                  t.noTheme,
                  style: textStyles.headline4,
                  textAlign: TextAlign.center,
                ),
              if (_selectedTheme != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedTheme?.name ?? '',
                        style: textStyles.headline4,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedTheme = null;
                        });
                      },
                      icon: const Icon(
                        Icons.delete,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (!isPhone)
                  Row(
                    children: [
                      _imageDisplay(
                        imageUrl: _selectedTheme?.image,
                        aspectRatio: 1.0,
                        label: t.themeIcon,
                      ),
                      const SizedBox(width: 32),
                      _imageDisplay(
                        aspectRatio: 1000 / 300,
                        imageUrl: _selectedTheme?.bannerImage,
                        label: t.themeBanner,
                      ),
                    ],
                  ),
                if (isPhone) ...[
                  _imageDisplay(
                    imageUrl: _selectedTheme?.image,
                    aspectRatio: 1.0,
                    label: t.themeIcon,
                  ),
                  const SizedBox(height: 10),
                  _imageDisplay(
                    aspectRatio: 1000 / 300,
                    imageUrl: _selectedTheme?.bannerImage,
                    label: t.themeBanner,
                  ),
                ]
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ThemedRaisedButton(
            label: t.selectTheme,
            backgroundColor: themeColors.secondaryButtonBackground,
            onPressed: !_busy
                ? () {
                    _selectTheme();
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _imageDisplay(
      {String? imageUrl,
      final double aspectRatio = 1,
      final double height = 80,
      final String? label}) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).themeColors.altBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).themeColors.divider,
              width: 1,
            ),
          ),
          height: height,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.contain,
                      ),
                    )),
                    progressIndicatorBuilder: (context, _, __) => const Center(
                      child: BusyIndicator(
                        size: 30,
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.image,
                      size: 30,
                    ),
                  ),
          ),
        ),
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              label,
              style: Theme.of(context).textStyles.headline5!.merge(TextStyle(
                  color: Theme.of(context).themeColors.secondaryText)),
            ),
          ),
      ],
    );
  }

  void _saveCircle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    _formKey.currentState!.save();
    var repo = ref.read(repositoryProvider);
    try {
      final circle = await repo.createSnapCircle(
        name: _nameController.text,
        description: _descriptionController.text,
        keeper: widget.fromCircle?.keeper,
        previousCircle: widget.fromCircle?.id,
        isPrivate: _selectedVisibility.value,
        duration: _selectedDuration.value,
        maxParticipants: numParticipants.toInt(),
        themeRef: _selectedTheme?.ref,
        imageUrl: _selectedTheme?.image,
        bannerUrl: _selectedTheme?.bannerImage,
      );
      if (circle != null) {
        await repo.createActiveSession(
          circle: circle,
        );
        if (!mounted) return;
        context.replaceNamed(AppRoutes.circle,
            params: {'id': circle.snapSession.id});
      } /*else {
        // leave session in place or cancel?
        if (!mounted) return;
        Navigator.pop(context);
        return;
      } */
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
    final themeColors = themeData.themeColors;
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.participantLimit, style: textStyles.headline3),
        const SizedBox(height: 6),
        SpinBox(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: themeColors.divider, width: 1),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          min: Circle.minParticipants.toDouble(),
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
          style: textStyles.headline4,
        ),
      ],
    );
  }

  Widget _visibilityOptions() {
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.visibility, style: textStyles.headline3),
        const SizedBox(height: 10),
        _visibilityDropDown(
          visibilityOptions,
          selected: _selectedVisibility,
          onChanged: (item) {
            setState(() => _selectedVisibility = item);
          },
        ),
      ],
    );
  }

  Widget _visibilityDropDown(List<CircleVisibilityOption> options,
      {required Function(dynamic item) onChanged,
      required CircleVisibilityOption? selected}) {
    if (options.isEmpty) return Container();
    final dropDownMenus = <DropdownMenuItem<CircleVisibilityOption>>[];
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
      child: DropdownButton<CircleVisibilityOption>(
        isExpanded: true,
        items: dropDownMenus,
        value: selected,
        onChanged: (v) {
          onChanged(v);
        },
      ),
    );
  }

  Widget _durationOptions() {
    final themeData = Theme.of(context);
    final textStyles = themeData.textStyles;
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.duration, style: textStyles.headline3),
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

  Future<void> _selectTheme() async {
    final CircleTheme? result =
        await ThemeSelector.showDialog(context, selected: _selectedTheme);
    if (result != null) {
      setState(() {
        _selectedTheme = result;
      });
    }
  }
}
