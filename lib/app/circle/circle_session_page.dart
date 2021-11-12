import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/components/circle_session_content.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';
import 'components/circle_session_controls.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CircleSessionPageState();
}

class _CircleSessionPageState extends ConsumerState<CircleSessionPage>
    with AfterLayoutMixin<CircleSessionPage> {
  // String? _sessionUserId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;
    final textStyles = themeData.textStyles;
    final t = AppLocalizations.of(context)!;
    final commProvider = ref.watch(communicationsProvider);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: WillPopScope(
          onWillPop: () async {
            return await _exitPrompt(context);
          },
          child: SafeArea(
            top: true,
            bottom: false,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SubPageHeader(
                      title: widget.session.circle.name,
                      onClose: () async {
                        if (await _exitPrompt(context)) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                            left: themeData.pageHorizontalPadding,
                            right: themeData.pageHorizontalPadding,
                            top: 12,
                            bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.session.circle.description != null &&
                                widget.session.circle.description!
                                    .isNotEmpty) ...[
                              Text(
                                t.circleDescription,
                                style: textStyles.headline3,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(widget.session.circle.description!),
                              Divider(
                                height: 48,
                                thickness: 1,
                                color: themeColors.divider,
                              ),
                            ],
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: _sessionContent(context, commProvider),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (commProvider.state == CommunicationState.active)
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: CircleSessionControls(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sessionContent(
      BuildContext context, CommunicationProvider commProvider) {
    switch (commProvider.state) {
      case CommunicationState.failed:
        return _errorSession(context);
      case CommunicationState.joining:
        return _joiningSession(context);
      case CommunicationState.active:
        return const CircleSessionContent();
      case CommunicationState.disconnected:
        return _sessionDisconnected(context);
    }
  }

  Widget _sessionDisconnected(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textStyles;
    final repo = ref.read(repositoryProvider);
    // then prompt the user about leaving
    final commProvider = ref.read(communicationsProvider);
    if (repo.activeSession != null) {
      return Container();
    }
    return Center(
      child: Column(
        children: [
          Text(
            t.errorJoinSession,
            style: textStyles.headline3,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            ErrorCodeTranslation.get(
                context, commProvider.lastError ?? "unknown"),
          ),
        ],
      ),
    );
  }

  Widget _errorSession(BuildContext context) {
    final commProvider = ref.read(communicationsProvider);
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textStyles;
    return Center(
      child: Column(
        children: [
          Text(
            t.errorJoinSession,
            style: textStyles.headline3,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(ErrorCodeTranslation.get(
              context, commProvider.lastError ?? "unknown")),
        ],
      ),
    );
  }

  Widget _joiningSession(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final textStyles = Theme.of(context).textStyles;
    return Center(
      child: Column(
        children: [
          Text(
            t.joiningCircle,
            style: textStyles.headline3,
          ),
          const SizedBox(
            height: 20,
          ),
          const BusyIndicator(),
        ],
      ),
    );
  }

  Future<bool> _exitPrompt(BuildContext context) async {
    final repo = ref.read(repositoryProvider);
    final authUser = ref.read(authServiceProvider).currentUser()!;
    // then prompt the user about leaving
    final commProvider = ref.read(communicationsProvider);
    if (repo.activeSession != null) {
      final role = repo.activeSession!.participantRole(authUser.uid);
      if (commProvider.state == CommunicationState.active) {
        // prompt
        FocusScope.of(context).unfocus();
        final t = AppLocalizations.of(context)!;
        // set up the AlertDialog
        final actions = [
          TextButton(
            child: Text(t.leaveSession),
            onPressed: () {
              Navigator.of(context).pop("leave");
            },
          ),
          TextButton(
            child: Text(t.cancel),
            onPressed: () {
              Navigator.of(context).pop("cancel");
            },
          ),
        ];
        if (role == Roles.keeper) {
          actions.insert(
            0,
            TextButton(
              child: Text(t.endSession),
              onPressed: () {
                Navigator.of(context).pop("end");
              },
            ),
          );
        }

        AlertDialog alert = AlertDialog(
          title: Text(
              role == Roles.keeper ? t.endSessionPrompt : t.leaveSessionPrompt),
          content: Text(role == Roles.keeper
              ? t.endSessionPromptMessage
              : t.leaveSessionPromptMessage),
          actions: actions,
        );
        // show the dialog
        final result = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return alert;
          },
        );
        if (result != "cancel") {
          await completeSession(result == "end");
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<void> completeSession(bool complete) async {
    final repo = ref.read(repositoryProvider);
    repo.clearActiveSession();
    final commProvider = ref.read(communicationsProvider);
    if (!complete) {
      await commProvider.leaveSession();
    } else {
      await commProvider.endSession();
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final provider = ref.read(communicationsProvider);
    provider.joinSession(
      session: widget.session,
      handler: CommunicationHandler(
          joinedCircle: (String sessionId, String sessionUserId) {
        debugPrint("joined circle as: " + sessionUserId);
      }, leaveCircle: () {
        // prompt?
        Future.delayed(const Duration(milliseconds: 0), () {
          Navigator.of(context).pop();
        });
      }),
    );
  }
}
