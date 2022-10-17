import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem/app/home/components/index.dart';
import 'package:totem/app/home/components/named_circle_list.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';
import '../../services/providers.dart';
import 'menu.dart';

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
      appBar: AppBar(
        toolbarHeight: 75,
        centerTitle: false,
        backgroundColor: themeColors.containerBackground,
        title: SvgPicture.asset('assets/home_logo.svg'),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: themeColors.altBackground,
      endDrawer: const TotemDrawer(),
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
                  height: 60,
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
}
