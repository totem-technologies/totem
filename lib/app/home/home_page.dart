import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem/app/home/components/index.dart';
import 'package:totem/app/home/components/named_circle_list.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

import '../../services/providers.dart';

final myPrivateCircles = StreamProvider.autoDispose<List<SnapCircle>>((ref) {
  final repo = ref.read(repositoryProvider);
  return repo.mySnapCircles();
});

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);
  final double maxContainerWidth = 654;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;
    AuthUser user = ref.read(authServiceProvider).currentUser()!;
    bool isMobile = Theme.of(context).isMobile(context);
    return Scaffold(
      backgroundColor: themeColors.altBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              top: true,
              bottom: false,
              child: isMobile
                  ? _homeContent(context, ref, isMobile: isMobile, user: user)
                  : Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: maxContainerWidth +
                                (Theme.of(context).pageHorizontalPadding * 2)),
                        child: _homeContent(context, ref,
                            isMobile: isMobile, user: user),
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _homeHeader(context, isMobile: isMobile),
          ),
/*          const Align(
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
          ),*/
        ],
      ),
    );
  }

  Widget _homeContent(BuildContext context, WidgetRef ref,
      {required bool isMobile, required AuthUser user}) {
    final t = AppLocalizations.of(context)!;
    bool isKeeper = user.hasRole(Role.keeper);
    bool hasPrivateCircles = false;
    List<SnapCircle> privateWaitingCircles = [];
    return ref.watch(myPrivateCircles).when(
          data: (List<SnapCircle> data) {
            if (data.isNotEmpty) {
              hasPrivateCircles = true;
              privateWaitingCircles = data
                  .where((element) => element.state == SessionState.waiting)
                  .toList();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 120,
                ),
                TotemHeader(
                  text: t.circles,
                  trailing: !isMobile && (isKeeper || !hasPrivateCircles)
                      ? const CreateCircleButton()
                      : null,
                ),
                SizedBox(height: isMobile ? 30 : 20),
                if (isMobile)
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: 20,
                        left: Theme.of(context).pageHorizontalPadding,
                        right: Theme.of(context).pageHorizontalPadding),
                    child: Row(children: const [CreateCircleButton()]),
                  ),
                if (privateWaitingCircles.isNotEmpty)
                  NamedCircleList(
                      name: t.yourPrivateCircles,
                      circles: privateWaitingCircles),
                const SnapCirclesRejoinable(),
                const Expanded(
                  child: SnapCirclesList(
                    topPadding: 15,
                  ),
                ),
              ],
            );
          },
          loading: () => Container(),
          error: (Object error, StackTrace? stackTrace) => Container(),
        );
  }

  Widget _homeHeader(BuildContext context, {required bool isMobile}) {
    final themeColors = Theme.of(context).themeColors;
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        color: themeColors.containerBackground,
        /* boxShadow: [
          BoxShadow(
              color: themeColors.shadow,
              offset: const Offset(0, 8),
              blurRadius: 24),
        ], */
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width:
                        isMobile ? Theme.of(context).pageHorizontalPadding : 80,
                  ),
                  SvgPicture.asset('assets/home_logo.svg'),
                  Expanded(child: Container()),
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile
                              ? Theme.of(context).pageHorizontalPadding
                              : 80,
                          vertical: 10),
                      child: const Icon(Icons.person_outline, size: 24),
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
    context.goNamed(AppRoutes.userProfile);
  }
}
