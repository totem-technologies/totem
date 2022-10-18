import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/app_theme_styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:totem/config.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/models/index.dart';

import '../../components/index.dart';

class TotemDrawer extends ConsumerWidget {
  const TotemDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;
    var userFuture = ref.read(repositoryProvider).userProfile();
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(20),
        ),
      ),
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: themeColors.altBackground,
            ),
            child: FutureBuilder<UserProfile?>(
                future: userFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  var user = snapshot.data!;
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileImage(
                          profile: user,
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Text(
                          user.name,
                          style: themeData.textStyles.displayMedium,
                        )
                      ]);
                }),
          ),
          DrawerItem(
              text: t.profile,
              icon: FontAwesomeIcons.solidUser,
              onTap: () {
                Navigator.pop(context);
                context.goNamed(AppRoutes.userProfile);
              }),
          DrawerItem(
              text: t.help,
              icon: FontAwesomeIcons.solidCircleQuestion,
              onTap: () {
                Navigator.pop(context);
                launchUrl(
                  Uri.parse(DataUrls.docs),
                  mode: LaunchMode.externalApplication,
                );
              }),
          DrawerItem(
              text: t.donate,
              icon: FontAwesomeIcons.circleDollarToSlot,
              onTap: () {
                Navigator.pop(context);
                launchUrl(
                  Uri.parse(DataUrls.donate),
                  mode: LaunchMode.externalApplication,
                );
              }),
          DrawerItem(
              text: t.feedback,
              icon: FontAwesomeIcons.solidComments,
              onTap: () {
                Navigator.pop(context);
                launchUrl(
                  Uri.parse(DataUrls.userFeedback),
                  mode: LaunchMode.externalApplication,
                );
              }),
          DrawerItem(
              text: t.reportIssue,
              icon: FontAwesomeIcons.bug,
              onTap: () {
                Navigator.pop(context);
                launchUrl(
                  Uri.parse(DataUrls.bugReport),
                  mode: LaunchMode.externalApplication,
                );
              }),
          if (AppConfig.isDev)
            DrawerItem(
                text: t.devTools,
                icon: FontAwesomeIcons.code,
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed(AppRoutes.dev);
                })
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem(
      {super.key, required this.text, required this.icon, required this.onTap});
  final Function() onTap;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(children: [
        SizedBox(
          width: 30,
          child: FaIcon(icon, size: 24),
        ),
        const SizedBox(width: 15),
        Text(text)
      ]),
      onTap: onTap,
    );
  }
}
