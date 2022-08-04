import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleDeviceSelector extends ConsumerStatefulWidget {
  const CircleDeviceSelector({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CircleDeviceSelectorState();
}

class CircleDeviceSelectorState extends ConsumerState<ConsumerStatefulWidget> {
/* TODO  bool _testingInput = false;
  bool _testingOutput = false;*/

  @override
  Widget build(BuildContext context) {
    final commProvider = ref.watch(communicationsProvider);
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textStyles;
    return Material(
      color: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: DialogContainer(
            padding:
                const EdgeInsets.only(top: 30, bottom: 30, left: 30, right: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      commProvider.audioDeviceConfigurable
                          ? t.audioVideoSettings
                          : t.videoSettings,
                      style: Theme.of(context).textStyles.headline2,
                    )),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 5, bottom: 5),
                        child: SvgPicture.asset('assets/close.svg'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  t.camera,
                  style: textStyles.headline4,
                ),
                _devicesDropDown(
                  commProvider.cameras,
                  onChanged: (item) {
                    commProvider.setCamera(item);
                  },
                  selected: commProvider.camera,
                ),
                if (commProvider.audioOutput != null) ...[
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    t.audioOutput,
                    style: textStyles.headline4,
                  ),
                  _devicesDropDown(
                    commProvider.audioOutputs,
                    onChanged: (item) {
                      commProvider.setAudioOutput(item);
                    },
                    selected: commProvider.audioOutput,
                  ),
                  /* TODO
                  !_testingOutput
                      ? ThemedRaisedButton(
                          label: "Test Audio Output",
                          onPressed: () {
                            commProvider.testAudioOutput();
                            setState(() => _testingOutput = true);
                          },
                        )
                      : Row(
                          children: [
                            ThemedRaisedButton(
                              label: "End Test",
                              onPressed: () {
                                commProvider.endTestAudioOutput();
                                setState(() => _testingOutput = false);
                              },
                            )
                          ],
                        ), */
                ],
                if (commProvider.audioInput != null) ...[
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    t.audioInput,
                    style: textStyles.headline4,
                  ),
                  _devicesDropDown(
                    commProvider.audioInputs,
                    onChanged: (item) {
                      commProvider.setAudioInput(item);
                    },
                    selected: commProvider.audioInput,
                  ),
                  /* TODO
                  !_testingInput
                      ? ThemedRaisedButton(
                          label: "Test Audio Input",
                          onPressed: () {
                            setState(() => _testingInput = true);
                          },
                        )
                      : Row(
                          children: [
                            ThemedRaisedButton(
                              label: "End Test",
                              onPressed: () {
                                setState(() => _testingInput = false);
                              },
                            )
                          ],
                        ), */
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _devicesDropDown(List<CommunicationDevice> devices,
      {required Function(dynamic item) onChanged,
      required CommunicationDevice? selected}) {
    if (devices.isEmpty) return Container();
    final dropDownMenus = <DropdownMenuItem<CommunicationDevice>>[];
    for (var v in devices) {
      dropDownMenus.add(
        DropdownMenuItem(
          value: v,
          child: Text(v.name, overflow: TextOverflow.ellipsis),
        ),
      );
    }
    return SizedBox(
      height: 40,
      child: Expanded(
        child: DropdownButton<CommunicationDevice>(
          isExpanded: true,
          items: dropDownMenus,
          value: selected,
          onChanged: (v) {
            onChanged(v);
          },
        ),
      ),
    );
  }
}
