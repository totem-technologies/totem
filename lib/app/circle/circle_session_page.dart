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
  final communicationProvider = repo.createCommunicationProvider();
  ref.onDispose(() {
    communicationProvider.dispose();
  });
  return communicationProvider;
});

class CircleSessionPage extends ConsumerStatefulWidget {
  const CircleSessionPage({Key? key, required this.activeSession})
      : super(key: key);
  final ActiveSession activeSession;

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
                      title: widget.activeSession.session.circle.name,
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
                            if (widget.activeSession.session.circle
                                        .description !=
                                    null &&
                                widget.activeSession.session.circle.description!
                                    .isNotEmpty) ...[
                              Text(
                                t.circleDescription,
                                style: textStyles.headline3,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(widget
                                  .activeSession.session.circle.description!),
                              Divider(
                                height: 48,
                                thickness: 1,
                                color: themeColors.divider,
                              ),
                            ],
                            if (commProvider.state == CommunicationState.active)
                              const CircleSessionContent(),
                            if (commProvider.state ==
                                CommunicationState.joining)
                              _joiningSession(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
    // TODO - check session state here and if active,
    // then prompt the user about leaving
    return true;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final provider = ref.read(communicationsProvider);
    provider.joinSession(
      session: widget.activeSession.session,
      handler: CommunicationHandler(
          joinedCircle: (String sessionId, String sessionUserId) {
/*        setState(() {
          _sessionUserId = sessionUserId;
        }); */
        debugPrint("joined circle as: " + sessionUserId);
      }, leaveCircle: () {
        debugPrint("left circle");
        // prompt?
      }),
    );
  }
}
