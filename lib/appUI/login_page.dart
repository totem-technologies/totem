import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:totem/components/widgets/Button.dart';
import 'package:totem/components/widgets/Header.dart';

class _LoginPanel2 extends StatelessWidget {
  const _LoginPanel2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
        child: CustomPaint(
          painter: CurvePainter(),
          child: Center(
              child: Column(children: [
                TotemHeader(
                  text: 'Welcome to Totem',
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30))
                    ),
                    width: 290,
                    child: Text(
                      'We are a Community, made to let you share and participate with others, by communicating your thoughts on a topic of your interest.',
                      textAlign: TextAlign.center,
                      style: TextStyle(height: 1.5,color: HexColor('#16182A')),
                    ),
                  ),
                ),


                TotemContinueButton(
                  buttonText: 'Login',
                  onButtonPressed: (stop) {
                    stop();
                    Navigator.pushNamed(context, '/login/phone');
                  },
                ),

              ])),
        ));
  }

}

class LoginPage2 extends StatelessWidget {
  LoginPage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    HexColor('#FFFDF9'),
                    HexColor('#FEEECC'),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.2, 0.8],
                  tileMode: TileMode.clamp),
            ),
            child:  Column(
              children: [
                _LoginPanel2(),
                Container(
                  color: HexColor('FFCC59'),
                  height: 200,
                )

              ],
            ),
          ),
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = HexColor('#FFCC59');
    paint.style = PaintingStyle.fill;

    var path = Path();

    path.moveTo(0, size.height * 0.8234);
    path.quadraticBezierTo(size.width * 0.07, size.height * 0.92,
        size.width * 0.5, size.height * 0.9167);
    path.quadraticBezierTo(size.width * 0.9 , size.height * 0.9167,
        size.width, size.height * 0.999);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
