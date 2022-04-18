import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CameraMuted extends StatelessWidget {
  const CameraMuted({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Align(
        alignment: Alignment.center,
        child: SvgPicture.asset('assets/cam.svg'),
      ),
    );
  }
}
