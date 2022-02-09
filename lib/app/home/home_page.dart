import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:totem/app/home/components/index.dart';
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(
                    child: SnapCirclesList(),
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
    return Stack(
      children: [
        // header background
        SimpleShadow(
          opacity: 1.0,
          offset: const Offset(0, 8),
          sigma: 24,
          color: themeColors.shadow,
          child: Stack(
            children: [
              Container(
                height: 60,
                color: themeColors.containerBackground,
              ),
              SafeArea(
                top: true,
                bottom: false,
                child: SvgPicture.asset(
                  'assets/home_header.svg',
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
        ),
        // Header details
        SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
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
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showProfile(BuildContext context) {
    Navigator.of(context).pushNamed('/profile');
  }
}
