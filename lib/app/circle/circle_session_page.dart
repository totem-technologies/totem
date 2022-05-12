import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/components/circle_scheduled_session_content.dart';
import 'package:totem/app/circle/components/circle_snap_session_content.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';

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
  const CircleSessionPage({Key? key, required this.session, this.state})
      : super(key: key);
  final Session session;
  final Map<String, bool>? state;

  @override
  CircleSessionPageState createState() => CircleSessionPageState();
}

class CircleSessionPageState extends ConsumerState<CircleSessionPage> {
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
    if (widget.session is SnapSession) {
      return CircleSnapSessionContent(
          circle: widget.session.circle as SnapCircle, state: widget.state);
    } else {
      return CircleScheduledSessionContent(session: widget.session);
    }
  }
}
