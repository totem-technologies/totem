import 'package:flutter/material.dart';
import 'package:totem/app/circle/components/circle_participant.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/components/widgets/sub_page_header.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CirclePage extends StatelessWidget {
  const CirclePage({Key? key, required this.circle}) : super(key: key);
  final Circle circle;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final textStyles = themeData.textTheme;
    final themeColors = themeData.themeColors;

    // This will come from the circle
    final testUser =
        UserProfile.fromJson({"name": "schalky", "image": "assets/dude.jpg"});
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
                      if (circle.description != null) ...[
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
                            userProfile: testUser,
                            role: index == 0 ? Roles.keeper : Roles.member,
                          );
                        },
                        itemCount: 5,
                      ),
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
}
