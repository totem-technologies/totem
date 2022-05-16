import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/components/circle_scheduled_session_content.dart';
import 'package:totem/app/circle/components/circle_snap_session_content.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';

import 'circle_join_dialog.dart';

final activeSessionProvider =
    ChangeNotifierProvider.autoDispose<ActiveSession>((ref) {
  final repo = ref.read(repositoryProvider);
  ref.onDispose(() {
    repo.clearActiveSession();
  });
  return repo.activeSession!;
});

final communicationsProvider =
    ChangeNotifierProvider.autoDispose<CommunicationProvider>((ref) {
  final repo = ref.read(repositoryProvider);
  return repo.createCommunicationProvider();
});

class CircleSessionPage extends ConsumerStatefulWidget {
  const CircleSessionPage({Key? key, required this.session}) : super(key: key);
  final Session session;

  @override
  CircleSessionPageState createState() => CircleSessionPageState();
}

class CircleSessionPageState extends ConsumerState<CircleSessionPage>
    with AfterLayoutMixin<CircleSessionPage> {
  bool joined = false;
  Map<String, bool>? sessionState;

  @override
  void initState() {
    ref.read(activeSessionProvider).addListener(() {
      final commProvider = ref.read(communicationsProvider);
      final activeSession = ref.read(activeSessionProvider);

      if ((activeSession.state == SessionState.cancelled ||
              activeSession.state == SessionState.complete) &&
          commProvider.state == CommunicationState.active) {
        // the session has been ended remotely... trigger leave session
        commProvider.leaveSession(requested: false);
        debugPrint('triggering leave session for session that has eneded');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(communicationsProvider);
    if (!joined) {
      return const Material(color: Colors.transparent);
    }
    if (widget.session is SnapSession) {
      return CircleSnapSessionContent(
          circle: widget.session.circle as SnapCircle, state: sessionState!);
    } else {
      return CircleScheduledSessionContent(session: widget.session);
    }
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    Map<String, bool>? state = await CircleJoinDialog.showDialog(context,
        circle: widget.session.circle);
    if (state != null) {
      Future.delayed(const Duration(milliseconds: 300), () async {
        setState(() {
          joined = true;
          sessionState = state;
        });
      });
    } else {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
