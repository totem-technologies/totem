import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/index.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';
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
  const CircleSessionPage({Key? key, required this.sessionID})
      : super(key: key);
  final String sessionID;

  @override
  CircleSessionPageState createState() => CircleSessionPageState();
}

class CircleSessionPageState extends ConsumerState<CircleSessionPage> {
  late Future<Session?> _loadSession;
  bool _canceled = false;

  @override
  void initState() {
    _loadSession = _loadSessionData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(communicationsProvider);
    return FutureBuilder<Session?>(
      future: _loadSession,
      builder: (BuildContext context, AsyncSnapshot<Session?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingSession(context);
        }
        if (snapshot.hasData) {
          return CircleSessionLivePage(
            session: snapshot.data!,
          );
        }
        return !_canceled ? _failedToLoadSession(context) : Container();
      },
    );
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

  Future<Session?> _loadSessionData() async {
    var repo = ref.read(repositoryProvider);
    // find the circle / session first
    SnapCircle? circle = await repo.circleFromId(widget.sessionID);
    if (circle != null) {
      if (circle.state == SessionState.complete ||
          circle.state == SessionState.cancelled) {
        // circle is complete or cancelled, so will have to start a new one
        // Make sure there isn't a new one already started as well,
        // should only be 1 that is waiting with a previous circle referencing this one
        SnapCircle? pending = await repo.circleFromPreviousIdAndNotState(
            circle.id, [SessionState.cancelled, SessionState.complete]);
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
        if (true) {
          await OnboardingScreen.showOnboarding(context, onComplete: (bool result) {
            // show
            Navigator.of(context).pop();
          });
        }
        if (!mounted) return null;
        bool? state =
            await CircleJoinDialog.showDialog(context, circle: circle);
        if (state != null && state) {
          return circle.snapSession;
        } else {
          _canceled = true;
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      }
    }
    return null;
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
