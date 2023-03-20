import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/services/account_state/index.dart';
import 'package:totem/services/index.dart';

class StartupEventsScreen extends ConsumerStatefulWidget {
  const StartupEventsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      StartupEventsScreenState();
}

class StartupEventsScreenState extends ConsumerState<StartupEventsScreen>
    with AfterLayoutMixin {
  AccountStateEvent? _event;

  @override
  Widget build(BuildContext context) {
    return (_event != null)
        ? _event!.eventContent(context, ref)
        : Scaffold(
            body: Container(),
          );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    final accountStateEventMgr = ref.read(accountStateEventManager);
    accountStateEventMgr.handleEvents(context,
        type: AccountStateEventType.startup, onShowEvent: (event) async {
      setState(() => _event = event);
    });
  }
}
