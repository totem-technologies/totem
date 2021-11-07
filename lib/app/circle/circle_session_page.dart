import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/components/circle_session_content.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/active_session.dart';
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

class CircleSessionPage extends StatelessWidget {
  const CircleSessionPage({Key? key, required this.activeSession})
      : super(key: key);
  final ActiveSession activeSession;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
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
            child: Column(
              children: [
                SubPageHeader(
                  title: activeSession.session.circle.name,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                        left: themeData.pageHorizontalPadding,
                        right: themeData.pageHorizontalPadding,
                        top: 12,
                        bottom: 20),
                    child: Column(
                      children: const [
                        CircleSessionContent(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _exitPrompt(BuildContext context) async {
    return true;
  }
}
