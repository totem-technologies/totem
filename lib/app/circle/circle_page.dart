import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/components/circle_participant.dart';
import 'package:totem/app/circle/components/session_item.dart';
import 'package:totem/components/fade_route.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/components/widgets/sub_page_header.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'circle_session_page.dart';

class CirclePage extends StatelessWidget {
  const CirclePage({Key? key, required this.circle}) : super(key: key);
  final Circle circle;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final textStyles = themeData.textTheme;
    final themeColors = themeData.themeColors;
    final authUser = context.read(authServiceProvider).currentUser()!;
    final userRole = circle.participantRole(authUser.uid);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: true,
          bottom: false,
          child: Column(
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
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.0,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          return CircleParticipant(
                            participant: circle.participants[index],
                          );
                        },
                        itemCount: circle.participants.length,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        t.sessions,
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
                            return SessionItem(
                              session: circle.sessions[index],
                              role: userRole,
                              nextSession: index == 0,
                              startSession: (session) {
                                _startSession(context, session);
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startSession(BuildContext context, Session session) async {
    // use this session to create a pending session
    final repo = context.read(repositoryProvider);
    ActiveSession activeSession = await repo.activateSession(session: session);
    Navigator.pushReplacement(
      context,
      FadeRoute(
        page: CircleSessionPage(activeSession: activeSession),
      ),
    );
  }
}
