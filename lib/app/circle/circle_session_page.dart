import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/account_state/account_state_event_manager.dart';
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
  const CircleSessionPage({Key? key, required this.sessionID})
      : super(key: key);
  final String sessionID;

  @override
  CircleSessionPageState createState() => CircleSessionPageState();
}

enum SessionPageState {
  prompt,
  ready,
  cancelled,
  info,
}

class CircleSessionPageState extends ConsumerState<CircleSessionPage>
    with AfterLayoutMixin {
  SessionPageState _sessionState = SessionPageState.info;
  Session? _session;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(communicationsProvider);
    switch (_sessionState) {
      case SessionPageState.ready:
        return CircleSessionLivePage(
          session: _session!,
          userProfile: _userProfile!,
        );
      case SessionPageState.cancelled:
      case SessionPageState.prompt:
      default:
        return Container();
    }
  }

  Future<void> _showJoinPrompt(SnapCircle circle) async {
    var repo = ref.read(repositoryProvider);
    setState(() => _sessionState = SessionPageState.prompt);
    await ref
        .read(accountStateEventManager)
        .handleEvents(context, type: AccountStateEventType.preCircle);
    if (!mounted) return;
    UserProfile? user =
        await CircleJoinDialog.showJoinDialog(context, circle: circle);
    if (user != null) {
      if (repo.activeSession == null) {
        await repo.createActiveSession(circle: circle);
      }
      _userProfile = user;
      repo.activeSession!.userProfile = user;
      _session = circle.snapSession;
      setState(() => _sessionState = SessionPageState.ready);
    } else {
      if (mounted) {
        setState(() => _sessionState = SessionPageState.info);
        Future.delayed(const Duration(milliseconds: 0), _loadSessionData);
      }
    }
  }

  Future<void> _loadSessionData() async {
    SnapCircle? joinCircle = await CircleInfoDialog.showCircleInfo(context,
        circleId: widget.sessionID);
    if (!mounted) return;
    if (joinCircle != null) {
      await _showJoinPrompt(joinCircle);
      return;
    } else if (mounted) {
      context.pop();
    }
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    _loadSessionData();
  }
}

class CircleSessionLivePage extends ConsumerStatefulWidget {
  const CircleSessionLivePage(
      {Key? key, required this.session, required this.userProfile})
      : super(key: key);
  final Session session;
  final UserProfile userProfile;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CircleSessionLivePageState();
}

class CircleSessionLivePageState extends ConsumerState<CircleSessionLivePage> {
  @override
  void initState() {
    ref.read(activeSessionProvider).addListener(_handleActiveSessionChange);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // listen to changes in the session
    ref.watch(activeSessionProvider);
    return CircleSnapSessionContent(
        circle: widget.session.circle as SnapCircle,
        userProfile: widget.userProfile);
  }

  void _handleActiveSessionChange() {
    debugPrint('active session change');
    final activeSession = ref.read(activeSessionProvider);
    final commProvider = ref.read(communicationsProvider);
    if (activeSession.state == SessionState.cancelled ||
        activeSession.state == SessionState.complete ||
        activeSession.state == SessionState.removed) {
      // the session has been ended remotely... trigger leave session
      if (commProvider.state == CommunicationState.active) {
        commProvider.leaveSession(requested: false);
        debugPrint('triggering leave session for session that has ended');
      }
      context.replaceNamed(AppRoutes.circleEnded, extra: {
        'removed': activeSession.state == SessionState.removed,
        'circle': activeSession.circle
      });
    }
  }
}
