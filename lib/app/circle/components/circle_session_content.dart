import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/app/circle/components/circle_pending_session_users.dart';
import 'package:totem/app/circle/components/circle_live_session_users.dart';
import 'package:totem/models/active_session.dart';

class CircleSessionContent extends ConsumerWidget {
  const CircleSessionContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    if (activeSession.state == SessionState.live) {
      return CircleLiveSessionUsers();
    } else if (activeSession.state == SessionState.waiting) {
      return const CirclePendingSessionUsers();
    }
    return Container();
  }
}
