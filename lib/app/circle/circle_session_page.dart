import 'dart:async';
import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/account_state/account_state_event_manager.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

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
  loading,
  prompt,
  ready,
  cancelled,
  error,
}

class CircleSessionPageState extends ConsumerState<CircleSessionPage>
    with AfterLayoutMixin {
  SessionPageState _sessionState = SessionPageState.loading;
  Session? _session;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(communicationsProvider);
    switch (_sessionState) {
      case SessionPageState.loading:
        return _loadingSession(context);
      case SessionPageState.ready:
        return CircleSessionLivePage(
          session: _session!,
        );
      case SessionPageState.error:
        return _failedToLoadSession(context);
      case SessionPageState.cancelled:
      case SessionPageState.prompt:
      default:
        return Container();
    }
  }

  Widget _loadingSession(BuildContext context) {
    return _interstitialBackground(
      context,
      ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 250),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.loadingCircle,
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 30,
            ),
            const BusyIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _failedToLoadSession(BuildContext context) {
    return _interstitialBackground(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.errorSessionInvalid,
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 30,
          ),
          ThemedRaisedButton(
            label: AppLocalizations.of(context)!.ok,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _interstitialBackground(BuildContext context, Widget child) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
      child: Center(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: Theme.of(context).maxRenderWidth),
          child: DialogContainer(
              padding: const EdgeInsets.only(
                  top: 50, bottom: 80, left: 40, right: 40),
              child: child),
        ),
      ),
    );
  }

  Future<void> _loadSessionData() async {
    var repo = ref.read(repositoryProvider);
    // find the circle / session first
    SnapCircle? circle = await repo.circleFromId(widget.sessionID);
    if (circle != null) {
      if (circle.state == SessionState.complete ||
          circle.state == SessionState.cancelled) {
        // circle is complete or cancelled, so will have to start a new one
        // Make sure there isn't a new one already started as well,
        // should only be 1 that is waiting with a previous circle referencing this one
        SnapCircle? pending = await repo.circleFromPreviousIdAndState(circle.id,
            [SessionState.waiting, SessionState.starting, SessionState.live]);
        if (pending == null) {
          // this is a create new circle moment
          circle = await repo.createSnapCircle(
              name: circle.name,
              description: circle.description,
              keeper: circle.keeper,
              previousCircle: circle.id);
        } else {
          // join the pending one
          circle = pending;
        }
      }
      if (circle != null) {
        // Create the active session if needed
        if (repo.activeSession == null) {
          await repo.createActiveSession(circle: circle);
        }
        setState(() => _sessionState = SessionPageState.prompt);
        if (!mounted) return;
        await ref
            .read(accountStateEventManager)
            .handleEvents(context, type: AccountStateEventType.preCircle);
        if (!mounted) return;
        bool? state =
            await CircleJoinDialog.showJoinDialog(context, circle: circle);
        if (state != null && state) {
          _session = circle.snapSession;
          setState(() => _sessionState = SessionPageState.ready);
        } else {
          if (mounted) {
            setState(() => _sessionState = SessionPageState.cancelled);
            Navigator.of(context).pop();
          }
        }
      }
    } else {
      setState(() => _sessionState = SessionPageState.error);
    }
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    _loadSessionData();
  }
}

class CircleSessionLivePage extends ConsumerStatefulWidget {
  const CircleSessionLivePage({Key? key, required this.session})
      : super(key: key);
  final Session session;

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
  Widget build(BuildContext context) {
    // listen to changes in the session
    ref.watch(activeSessionProvider);
    if (widget.session is SnapSession) {
      return CircleSnapSessionContent(
          circle: widget.session.circle as SnapCircle);
    } else {
      return CircleScheduledSessionContent(session: widget.session);
    }
  }

  void _handleActiveSessionChange() {
    debugPrint('active session change');
    final activeSession = ref.read(activeSessionProvider);
    final commProvider = ref.read(communicationsProvider);
    if ((activeSession.state == SessionState.cancelled ||
            activeSession.state == SessionState.complete) &&
        commProvider.state == CommunicationState.active) {
      // the session has been ended remotely... trigger leave session
      commProvider.leaveSession(requested: false);
      debugPrint('triggering leave session for session that has ended');
    }
  }
}
