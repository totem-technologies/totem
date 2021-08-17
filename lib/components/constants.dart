import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Color darkBlueColor = HexColor('#163253');
Color yellowColor = HexColor('#EEAD68');
Color dullYellowColor = HexColor('#ffdb58');

///White 32 BoldTextStyle
TextStyle white32BoldTextStyle = TextStyle(
    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 32.sp);

///White 16 NormalTextStyle
TextStyle white16NormalTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.normal,
  fontSize: 16.sp,
);

///White 12 NormalTextStyle
TextStyle white12NormalTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.normal,
  fontSize: 12.sp,
);

///White 16 BoldTextStyle
TextStyle white16BoldTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.w700,
  fontSize: 16.sp,
);

///DarkBlue 16 NormalTextStyle
TextStyle darkBlue16NormalTextStyle = TextStyle(
  color: darkBlueColor,
  fontWeight: FontWeight.normal,
  fontSize: 16.sp,
);

final otpInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 15.h),
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.white),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.white),
  ),
  border: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.white),
  ),
);
