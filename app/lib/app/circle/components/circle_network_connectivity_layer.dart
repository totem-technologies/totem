import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totem/app/circle/circle_session_page.dart';
import 'package:totem/services/communication_provider.dart';

class CircleNetworkConnectivityLayer extends ConsumerWidget {
  const CircleNetworkConnectivityLayer({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commProvider = ref.watch(communicationsProvider);
    return Stack(
      children: [
        child,
        if (commProvider.state == CommunicationState.networkConnectivity)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
              child: Container(
                color: Colors.black.withOpacity(0.50),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("You are experiencing network connectivity issues.")
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
