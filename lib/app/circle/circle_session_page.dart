import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/index.dart';
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

final circleProvider =
    StreamProvider.autoDispose.family<Circle?, String>((ref, circleId) {
  final repo = ref.read(repositoryProvider);
  return repo.circleStream(circleId);
});

class CircleSessionPage extends ConsumerStatefulWidget {
  const CircleSessionPage({Key? key, required this.sessionID})
      : super(key: key);
  final String sessionID;

  @override
  CircleSessionPageState createState() => CircleSessionPageState();
}

enum SessionPageState {
  loading,
  prompt,
  ready,
  cancelled,
  info,
  error,
}

class CircleSessionPageState extends ConsumerState<CircleSessionPage> {
  SessionPageState _sessionState = SessionPageState.loading;
  Session? _session;
  UserProfile? _userProfile;
  bool _showInfo = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(communicationsProvider);
    ref.listen<AsyncValue?>(circleProvider(widget.sessionID),
        (previous, newCircle) {
      if (newCircle?.value != null &&
          _sessionState == SessionPageState.loading) {
        Circle circle = newCircle!.value!;
        if (!circle.isPrivate || circle.isComplete) {
          _showInfo = true;
          setState(() => _sessionState = SessionPageState.info);
          _showCircleInfo();
        } else {
          _showInfo = false;
          setState(() => _sessionState = SessionPageState.prompt);
          _showJoinPrompt(circle);
        }
      } else if (newCircle?.value == null) {
        setState(() => _sessionState = SessionPageState.error);
      }
    });
    switch (_sessionState) {
      case SessionPageState.ready:
        return CircleSessionLivePage(
          session: _session!,
          userProfile: _userProfile!,
        );
      case SessionPageState.loading:
        return _dialogContainer(const CircleLoading());
      case SessionPageState.error:
        return _dialogContainer(const CircleErrorLoading());
      default:
        return Container();
    }
  }

  Widget _dialogContainer(Widget child) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
      child: Center(
        child: DialogContainer(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }

  Future<void> _showJoinPrompt(Circle circle) async {
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
      _session = circle.session;
      setState(() => _sessionState = SessionPageState.ready);
    } else if (_showInfo) {
      if (mounted) {
        setState(() => _sessionState = SessionPageState.info);
        Future.delayed(Duration.zero, _showCircleInfo);
      }
    } else if (mounted) {
      context.pop();
    }
  }

  Future<void> _showCircleInfo() async {
    Circle? joinCircle = await CircleInfoDialog.showCircleInfo(context,
        circleId: widget.sessionID);
    if (!mounted) return;
    if (joinCircle != null) {
      await _showJoinPrompt(joinCircle);
      return;
    } else if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed(AppRoutes.home);
      }
    }
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
        circle: widget.session.circle, userProfile: widget.userProfile);
  }

  void _handleActiveSessionChange() {
    debugPrint('active session change');
    final activeSession = ref.read(activeSessionProvider);
    final commProvider = ref.read(communicationsProvider);
    if (activeSession.ended) {
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
