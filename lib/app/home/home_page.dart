import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem/app/home/components/index.dart';
import 'package:totem/app/home/components/named_circle_list.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

import 'menu.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);
  final double maxContainerWidth = 654;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;
    AuthUser? user = ref.read(authServiceProvider).currentUser();
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
      body: user != null
          ? Stack(
              children: [
                Positioned.fill(
                  child: SafeArea(
                    top: true,
                    bottom: false,
                    child: isMobile
                        ? _homeContent(context, ref,
                            isMobile: isMobile, user: user)
                        : Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: maxContainerWidth +
                                      (Theme.of(context).pageHorizontalPadding *
                                          2)),
                              child: _homeContent(context, ref,
                                  isMobile: isMobile, user: user),
                            ),
                          ),
                  ),
                ),
              ],
            )
          : Container(),
    );
  }

  Widget _homeContent(BuildContext context, WidgetRef ref,
      {required bool isMobile, required AuthUser user}) {
    final t = AppLocalizations.of(context)!;
    final bool isKeeper = user.hasRole(Role.keeper);
    final bool hasPrivateCircles =
        ref.watch(userPrivateCircles).value?.isNotEmpty ?? false;
    final bool hasRejoinable =
        ref.watch(rejoinableCircles).value?.isNotEmpty ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 60,
        ),
        TotemHeader(
          text: t.circles,
          trailing: (isKeeper || !hasPrivateCircles)
              ? const CreateCircleButton()
              : null,
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              NamedCircleList(
                name: t.yourPrivateCircles,
              ),
              const SnapCirclesRejoinable(),
              SliverToBoxAdapter(
                child: (hasPrivateCircles || hasRejoinable)
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal:
                                Theme.of(context).pageHorizontalPadding),
                        child: Text(
                          t.otherCircles,
                          style: Theme.of(context).textStyles.headline2,
                        ),
                      )
                    : const SizedBox(height: 10),
              ),
              const SnapCirclesList(),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
