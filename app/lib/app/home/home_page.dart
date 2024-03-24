import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem/app/circle_create/circle_template_selector.dart';
import 'package:totem/app/circle_create/index.dart';
import 'package:totem/app/home/components/index.dart';
import 'package:totem/app/home/components/named_circle_list.dart';
import 'package:totem/app_routes.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';
import 'package:totem/theme/index.dart';

import 'menu.dart';

final activeCirclesProvider = StreamProvider.autoDispose<List<Circle>>((ref) {
  final repo = ref.read(repositoryProvider);
  return repo.circles();
});

final scheduledCirclesProvider =
    StreamProvider.autoDispose<List<Circle>>((ref) {
  final authService = ref.read(authServiceProvider);
  final totemRepository = ref.read(repositoryProvider);
  return ScheduledCirclesProvider(
          authStream: authService.onAuthStateChanged,
          repository: totemRepository)
      .stream;
});

final ownerCirclesProvider = StreamProvider.autoDispose<List<Circle>>((ref) {
  final totemRepository = ref.read(repositoryProvider);
  return totemRepository.ownerUpcomingCircles();
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  final double maxContainerWidth = 654;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final themeColors = themeData.themeColors;
    AuthUser? user = ref.read(authServiceProvider).currentUser();
    ref.watch(scheduledCirclesProvider);
    ref.watch(ownerCirclesProvider);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 60,
        ),
        TotemHeader(
          text: t.circles,
          trailing: (isKeeper || !hasPrivateCircles)
              ? CreateCircleButton(onPressed: !_busy ? _createCircle : null)
              : null,
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              NamedCircleList(
                name: t.yourPrivateCircles,
              ),
              const CirclesRejoinable(),
              const SliverToBoxAdapter(
                child: SizedBox(height: 10),
              ),
              CirclesList(
                provider: activeCirclesProvider,
                title: t.activeCircles,
                description: t.activeCirclesDescription,
                noCircles: const NoCircles(),
              ),
              CirclesList(
                  provider: ownerCirclesProvider,
                  title: t.ownedCircles,
                  description: t.ownedCirclesDescription),
              CirclesList(
                  provider: scheduledCirclesProvider,
                  title: t.scheduledCircles,
                  description: t.scheduledCirclesDescription),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _createCircle() async {
    setState(() {
      _busy = true;
    });
    AuthUser? user = ref.read(authServiceProvider).currentUser();
    bool isKeeper = user?.hasRole(Role.keeper) ?? false;

    // build new circle
    if (isKeeper) {
      final template = await showDialogOrBottomSheet(
          child: const CircleTemplateSelector(),
          context: context,
          maxWidth: 1000);
      if (template != null && mounted) {
        context.goNamed(AppRoutes.circleCreate,
            extra: template is CircleTemplate ? template : null);
      }
    } else {
      final Circle? createdCircle =
          await CircleCreateNonKeeper.showNonKeeperCreateDialog(context);
      if (mounted && createdCircle != null) {
        context.goNamed(AppRoutes.circle,
            pathParameters: {'id': createdCircle.session.id});
      }
    }
    if (mounted) {
      setState(() {
        _busy = false;
      });
    }
  }
}
