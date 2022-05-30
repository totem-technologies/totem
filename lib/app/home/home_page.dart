import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem/app/home/components/index.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/theme/index.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;
    return Scaffold(
      backgroundColor: themeColors.altBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              top: true,
              bottom: false,
              child: Column(
                children: const [
                  SizedBox(
                    height: 140,
                  ),
                  SnapCirclesRejoinable(),
                  Expanded(
                    child: SnapCirclesList(
                      topPadding: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _homeHeader(context),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomTrayContainer(
              child: SafeArea(
                top: false,
                bottom: true,
                child: Center(
                  child: CreateCircleButton(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeHeader(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeColors = Theme.of(context).themeColors;
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(30),
        ),
        color: themeColors.containerBackground,
        boxShadow: [
          BoxShadow(
              color: themeColors.shadow,
              offset: const Offset(0, 8),
              blurRadius: 24),
        ],
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 46),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TotemHeader(text: t.circles),
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: SvgPicture.asset('assets/profile.svg'),
                    ),
                    onTap: () {
                      _showProfile(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfile(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.userProfile);
  }
}
