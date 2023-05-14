import 'package:action_slider/action_slider.dart';
import 'package:totem/theme/index.dart';
import 'package:flutter/material.dart';

class SliderButton extends StatelessWidget {
  const SliderButton({super.key, required this.action});
  final Function(ActionSliderController)? action;

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).themeColors;
    final textStyles = Theme.of(context).textStyles;
    return ActionSlider.standard(
      backgroundColor: themeColors.sliderBackground.withAlpha(200),
      action: action,
      boxShadow: const [],
      child: Text('Slide to pass', style: textStyles.displaySmall),
    );
  }
}


// SliderButton(
//                         borderRadius: 30,
//                         elevation: 0,
//                         height: 60,
//                         sliderRotate: false,
//                         innerColor: themeColors.profileBackground,
//                         outerColor: Colors.transparent,
//                         sliderButtonIconPadding: 0,
//                         sliderButtonIcon: Container(
//                           width: 48,
//                           height: 48,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: themeColors.primary,
//                           ),
//                           child: Center(
//                             child: Icon(LucideIcons.checkCircle2,
//                                 size: 24, color: themeColors.primaryText),
//                           ),
//                         ),
//                         submittedIcon: const SizedBox(height: 48, width: 48),
//                         onSubmit: !_processingRequest
//                             ? () {
//                                 // delay to allow for animation to complete
//                                 Future.delayed(
//                                     const Duration(milliseconds: 300), () {
//                                   _endTurn(context, participant);
//                                 });
//                               }
//                             : null,
//                         child: Padding(
//                           padding: const EdgeInsets.all(1),
//                           child: Container(
//                             decoration: BoxDecoration(
//                                 color:
//                                     themeColors.sliderBackground.withAlpha(120),
//                                 borderRadius: BorderRadius.circular(30)),
//                             child: Center(
//                               child: Padding(
//                                 padding: const EdgeInsets.only(
//                                   left: 40,
//                                 ),
//                                 child: Text(
//                                   t.slideToPass,
//                                   style: textStyles.displaySmall,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),