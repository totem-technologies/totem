import 'package:flutter/material.dart';
import 'dart:ui';

class FrostedPanelWidget extends StatelessWidget {
  final bool full;
  final Widget child;
  const FrostedPanelWidget({required this.child, this.full = true, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var borderRadius = 30.0;
    var heightRatio = full ? 0.9 : 0.3;
    return Positioned(
        width: MediaQuery.of(context).size.width,
        bottom: 0,
        child: AnimatedContainer(
            curve: Curves.easeInOut,
            height: MediaQuery.of(context).size.height * heightRatio,
            duration: const Duration(milliseconds: 500),
            child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    topRight: Radius.circular(borderRadius)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.50),
                    child: child,
                  ),
                ))));
  }
}

// class FrostedPanelWidget extends StatelessWidget {
//   const FrostedPanelWidget({Key? key, this.full = true, required this.child})
//       : super(key: key);
//   final full;
//   final Widget child;
//   @override
//   Widget build(BuildContext context) {
//     var borderRadius = 30.0;
//     return Positioned(
//         height: MediaQuery.of(context).size.height * .3,
//         width: MediaQuery.of(context).size.width,
//         bottom: 0,
//         child: Container(
//             child: ClipRRect(
//                 borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(borderRadius),
//                     topRight: Radius.circular(borderRadius)),
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//                   child: Container(
//                     color: Colors.black.withOpacity(0.50),
//                     child: this.child,
//                   ),
//                 ))));
//   }
// }
