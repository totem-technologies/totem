import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem/components/constants.dart';
import 'package:totem/components/widgets/Button.dart';

class GuidelineScreen extends StatefulWidget {
  GuidelineScreen({Key? key}) : super(key: key);

  @override
  _GuidelineScreenState createState() => _GuidelineScreenState();
}

class _GuidelineScreenState extends State<GuidelineScreen> {
  bool isAccepted = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: 35.w, right: 35.w),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40.h,
                    ),
                    Text(
                      'Totem Community Guidelines',
                      style: white32BoldTextStyle,
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5.h, bottom: 20.h),
                      child: Container(
                        height: 5.h,
                        width: 90.w,
                        decoration: BoxDecoration(
                            color: yellowColor,
                            borderRadius: BorderRadius.circular(10.w)),
                      ),
                    ),
                    Container(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            Text('Last Time Updated: May 12,2021',
                                style: white16BoldTextStyle),
                            /*Text(widget.uid,  ///showing uID as user logged-in
                                style: white16BoldTextStyle),*/
                          ],
                        )),
                    SizedBox(
                      height: 15.h,
                    ),
                    Text(
                      'We are a Community, made to let you share  and participate with others, by communicating your thoughts on a topic of your '
                      'interests.'
                      'We are a Community, made to let you share  and participate with others, by communicating your thoughts on a topic of your interests.'
                      'We are a Community, made to let you share  and participate with others, by communicating your thoughts on a topic of your interests.'
                      'We are a Community, made to let you share  and participate with others, by communicating your thoughts on a topic of your interests.'
                      'We are a Community, made to let you share  and participate with others, by communicating your thoughts on a topic of your interests.'
                      'We are a Community, made to let you share  and participate with others, by communicating your thoughts on a topic of your interests.'
                      'We are a Community, made to let you share  and participate with others, by communicating your thoughts on a topic of your interests.'
                      'We are a Community, made to let you share  and participate with others, by communicating your thoughts on a topic of your interests.'
                      'We are a Community, made to let you share  and participate with others, by communicating your thoughts on a topic of your interests.'
                      'We are a Community, made to let you share  and participate with others, by communicating your thoughts on a topic of your interests.',
                      style: white16NormalTextStyle,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 150.h,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                // Clip it cleanly.
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 150.h,
                    padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.w),
                            topRight: Radius.circular(30.w)),
                        border: Border.all(color: Colors.white)),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        TotemButton(
                          buttonText: 'Accept Guidelines',
                          onButtonPressed:(stop) {
                                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                          },
                        ),
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  size: 30.w,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 9.w,
                                ),
                                Text(
                                  'Back',
                                  style: white16BoldTextStyle,
                                )
                              ],
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}
