import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:totem/theme/index.dart';
import 'package:totem/app/home/components/index.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final themeColors = themeData.themeColors;
    return GradientBackground(
      gradient: themeColors.secondaryGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: true,
          bottom: false,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                      child: SvgPicture.asset(
                    'assets/home_background.svg',
                    fit: BoxFit.fill,
                  )),
                ],
              ),
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Row(
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
                    const SizedBox(height: 10),
                    const Expanded(
                      child: SnapCirclesList(),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: BottomTrayContainer(
                  child: SafeArea(
                    top: false,
                    bottom: true,
                    child: Center(
                      child: ThemedRaisedButton(
                        elevation: 0,
                        height: 52,
                        onPressed: () {
                          // build new circle
                          Navigator.of(context)
                              .pushNamed('/snap_circle/create');
                        },
                        padding: const EdgeInsets.symmetric(horizontal: 42),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(t.createCircle),
                            const SizedBox(
                              width: 12,
                            ),
                            const Icon(Icons.add)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfile(BuildContext context) {
    Navigator.of(context).pushNamed('/profile');
  }
}
