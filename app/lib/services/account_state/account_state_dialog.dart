import 'dart:async';
import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/services/account_state/account_state_event.dart';
import 'package:totem/services/utils/device_type.dart';
import 'package:totem/theme/index.dart';

class AccountStateDialog extends ConsumerStatefulWidget {
  const AccountStateDialog({super.key, required this.event});
  final AccountStateEvent event;

  static Future<void> showEvent(BuildContext context,
      {required AccountStateEvent event}) async {
    if (DeviceType.isPhone()) {
      // show as full screen dialog
      if (event.fullScreenPhone) {
        return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AccountStateDialog(event: event),
        );
      }
      // show a modal bottom sheet
      return showModalBottomSheet<dynamic>(
        enableDrag: false,
        isScrollControlled: true,
        isDismissible: false,
        context: context,
        backgroundColor: Colors.transparent,
        barrierColor: Theme.of(context).themeColors.blurBackground,
        builder: (_) => AccountStateDialog(event: event),
      );
    }
    // show as floating dialog
    return showDialog(
      context: context,
      barrierColor: Theme.of(context).themeColors.blurBackground,
      barrierDismissible: false,
      builder: (context) {
        return AccountStateDialog(event: event);
      },
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      AccountStateDialogState();
}

class AccountStateDialogState extends ConsumerState<AccountStateDialog>
    with AfterLayoutMixin {
  @override
  Widget build(BuildContext context) {
    if (DeviceType.isPhone()) {
      // show as full screen dialog
      if (widget.event.fullScreenPhone) {
        return Material(
          color: Theme.of(context).colorScheme.background,
          child: widget.event.eventContent(context, ref),
        );
      }
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
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
                vertical: 10,
              ),
              child: widget.event.eventContent(context, ref),
            ),
          ),
        ),
      );
    }
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.event.maxWidth),
          child: DialogContainer(
            padding: EdgeInsets.only(
                top: 40,
                bottom: 20,
                left: Theme.of(context).pageHorizontalPadding,
                right: Theme.of(context).pageHorizontalPadding),
            child: widget.event.eventContent(context, ref),
          ),
        ),
      ),
    );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    if (!widget.event.testOnly) {
      widget.event.updateAccountState(context, ref);
    }
  }
}
