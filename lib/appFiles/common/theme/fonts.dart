import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

TextTheme buildTextTheme(
  TextTheme base,
  String? language, [
  String fontFamily = 'Almarai',
  String fontHeader = 'Almarai',
]) {
  return base
      .copyWith(
        headline1: GoogleFonts.getFont(
          fontHeader,
          textStyle: base.headline1!.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ).copyWith(

            /// If using the custom font
            /// un-comment below and clone to other headline.., bodyText..
           fontFamily: 'Almarai',
            ),
        headline2: GoogleFonts.getFont(
          fontHeader,
          textStyle: base.headline1!.copyWith(fontWeight: FontWeight.w700,fontFamily: 'Almarai'),
        ),
        headline3: GoogleFonts.getFont(
          fontHeader,
          textStyle: base.headline3!.copyWith(fontWeight: FontWeight.w700,fontFamily: 'Almarai'),
        ),
        headline4: GoogleFonts.getFont(
          fontHeader,
          textStyle: base.headline4!.copyWith(fontWeight: FontWeight.w700,fontFamily: 'Almarai'),
        ),
        headline5: GoogleFonts.getFont(
          fontHeader,
          textStyle: base.headline5!.copyWith(fontWeight: FontWeight.w500,fontFamily: 'Almarai'),
        ),
        headline6: GoogleFonts.getFont(
          fontHeader,
          textStyle: base.headline6!.copyWith(
            fontWeight: FontWeight.normal
              ,fontFamily: 'Almarai'
          ),
        ).copyWith(
            // fontFamily: 'Your Custom Font',
            ),
        caption: GoogleFonts.getFont(
          fontFamily,
          textStyle: base.caption!
              .copyWith(fontWeight: FontWeight.w400, fontSize: 14.0,fontFamily: 'Almarai'),
        ),
        subtitle1: GoogleFonts.getFont(
          fontFamily,
          textStyle: base.subtitle1!.copyWith(fontFamily: 'Almarai'),

        ),
        subtitle2: GoogleFonts.getFont(
          fontFamily,
          textStyle: base.subtitle2!.copyWith(fontFamily: 'Almarai'),
        ),
        bodyText1: GoogleFonts.getFont(
          fontFamily,
          textStyle: base.bodyText1!.copyWith(fontFamily: 'Almarai'),
        ),
        bodyText2: GoogleFonts.getFont(
          fontFamily,
          textStyle: base.bodyText1!.copyWith(fontFamily: 'Almarai'),
        ),
        button: GoogleFonts.getFont(
          fontFamily,
          textStyle: base.button!
              .copyWith(fontWeight: FontWeight.w400, fontSize: 14.0,fontFamily: 'Almarai'),
        ),
      )
      .apply(
        displayColor: kGrey900,
        bodyColor: kGrey900,
      );
}
