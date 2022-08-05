import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/components/circle_participant.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

import 'components/scheduled_session_item.dart';

class CirclePage extends ConsumerStatefulWidget {
  const CirclePage({Key? key, required this.circle}) : super(key: key);
  final ScheduledCircle circle;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => CirclePageState();
}

class CirclePageState extends ConsumerState<CirclePage> {
  CirclePageState();

  late final Stream<ScheduledCircle> _stream;
  late ScheduledCircle circle;
  @override
  void initState() {
    circle = widget.circle;
    _stream = ref.read(repositoryProvider).scheduledCircle(circleId: circle.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final textStyles = themeData.textTheme;
    final themeColors = themeData.themeColors;
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: true,
          bottom: false,
          child: StreamBuilder<ScheduledCircle>(
            stream: _stream,
            builder: (context, snapshot) {
              bool loading =
                  snapshot.connectionState == ConnectionState.waiting;
              if (!loading && snapshot.hasData) {
                circle = snapshot.data!;
              }
              return Column(
                children: [
                  SubPageHeader(
                    title: circle.name,
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
                          if (circle.description != null &&
                              circle.description!.isNotEmpty) ...[
                            Text(
                              t.circleDescription,
                              style: textStyles.headline3,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(circle.description!),
                            Divider(
                              height: 48,
                              thickness: 1,
                              color: themeColors.divider,
                            ),
                          ],
                          if (!loading) ..._fullCircleContent(context),
                          if (loading) ...[
                            const SizedBox(height: 30),
                            const Center(
                              child: BusyIndicator(),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _fullCircleContent(BuildContext context) {
    final themeData = Theme.of(context);
    final textStyles = themeData.textTheme;
    final authUser = ref.read(authServiceProvider).currentUser()!;
    Role userRole = circle.participantRole(authUser.uid);
    final t = AppLocalizations.of(context)!;
    return [
      GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          Participant participant = circle.participants[index];
          return CircleParticipant(
            name: participant.userProfile.name,
            image: participant.userProfile.image,
            role: participant.role,
            me: participant.me,
          );
        },
        itemCount: circle.participants.length,
      ),
      const SizedBox(
        height: 20,
      ),
      if (!circle.hasActiveSession) ...[
        Text(
          t.sessionsUpcoming,
          style: textStyles.headline3,
        ),
        const SizedBox(
          height: 8,
        ),
        if (circle.sessions.isNotEmpty)
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return ScheduledSessionItem(
                session: circle.sessions[index],
                role: userRole,
                nextSession: index == 0,
                startSession: (session) {
                  _startSession(context, ref, session);
                },
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 8);
            },
            itemCount: circle.sessions.length,
          ),
        if (circle.sessions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              t.noUpcomingSessions,
              style: textStyles.headline4,
              textAlign: TextAlign.center,
            ),
          )
      ],
      if (circle.hasActiveSession)
        ThemedRaisedButton(
          label: t.joinSession,
          onPressed: () {
            _joinSession(context);
          },
        ),
    ];
  }

  // THIS IS PLACEHOLDER UNTIL THE SERVER UPDATES THE ACTIVE SESSION
  // AUTOMATICALLY
  void _startSession(
      BuildContext context, WidgetRef ref, ScheduledSession session) async {
    // use this session to create a pending session
    final repo = ref.read(repositoryProvider);
    await repo.activateSession(session: session);
    if (!mounted) return;
    debugPrint(session.id);
    context.goNamed(AppRoutes.circle, params: {'id': session.id});
  }

  void _joinSession(BuildContext context) async {
    // use this session to create a pending session
    final repo = ref.read(repositoryProvider);
    // Generate an instance of the live session before
    // going to the live page
    await repo.createActiveSession(circle: circle);
    /* FIXME
        Navigator.pushReplacement(
      context,
      FadeRoute(
        page: CircleSessionPage(session: circle.activeSession!),
      ),
    ); */
  }
}
