import 'package:flutter/material.dart';

class GradientButton extends StatefulWidget {
  const GradientButton({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 1.0],
            colors: [
              Colors.deepPurple.shade400,
              Colors.deepPurple.shade200,
            ],
          ),
          color: Colors.deepPurple.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            minimumSize: MaterialStateProperty.all(const Size(80, 50)),
            backgroundColor:
            MaterialStateProperty.all(Colors.transparent),
            // elevation: MaterialStateProperty.all(3),
            shadowColor:
            MaterialStateProperty.all(Colors.transparent),
          ),
          onPressed: () {
            //onpressed();
          },
          child: const Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Text(
              "Text",
              style: TextStyle(
                fontSize: 18,
                // fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

}