
import 'package:domino_game/constants/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_colors.dart';

ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blueGrey,
    scaffoldBackgroundColor: MyColors.sky,
    iconTheme: const IconThemeData(color: MyColors.darkBlue),

    appBarTheme: const AppBarTheme(
      // backwardsCompatibility: false, //to control status bar (Default =true)
      systemOverlayStyle:SystemUiOverlayStyle(
          statusBarColor: MyColors.white,
          statusBarIconBrightness: Brightness.dark
      ) ,
      elevation: 0.0,
      backgroundColor: MyColors.darkBlue,
      iconTheme: IconThemeData(color: MyColors.white),
    ),
    textTheme: TextTheme(
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        bodyLarge: bodyLarge ,
        bodyMedium: bodyMedium,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: GoogleFonts.aBeeZee(),
        bodySmall: GoogleFonts.aBeeZee()
    ),

);


ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.blueGrey,
  scaffoldBackgroundColor: MyColors.sky,
  iconTheme: const IconThemeData(color: MyColors.lightBeige),
  appBarTheme: const AppBarTheme(
    // backwardsCompatibility: false, //to control status bar (Default =true)
    systemOverlayStyle:SystemUiOverlayStyle(
        statusBarColor: MyColors.white,
        statusBarIconBrightness: Brightness.dark
    ) ,
    elevation: 0.0,
    backgroundColor: MyColors.darkBlue,
    iconTheme: IconThemeData(color: MyColors.white),
  ),
    textTheme: TextTheme(
        displayMedium: displayMedium.copyWith(color: MyColors.white),
        displaySmall: displaySmall.copyWith(color: MyColors.white),
        bodyLarge: bodyLarge.copyWith(color: MyColors.white) ,
        bodyMedium: bodyMedium ,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: GoogleFonts.aBeeZee().copyWith(color: MyColors.white),
        bodySmall: bodySmall.copyWith(color: MyColors.white)
    ),


);



/*
ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: MyColors.darkBlack,
  appBarTheme: AppBarTheme(
      backwardsCompatibility: false, //to control status bar (Default =true)
      systemOverlayStyle:SystemUiOverlayStyle(
          statusBarColor: MyColors.darkBlack,
          statusBarIconBrightness: Brightness.light
      ) ,
      elevation: 0.0,
      backgroundColor: MyColors.darkBlack,
      titleTextStyle:  appBarTitleStyle,
      iconTheme: IconThemeData(color: MyColors.orange)
  ),

  textTheme: TextTheme(
    headline1: headline1,
    headline2: headline2,
    bodyText1: bodyText1,
    bodyText2: bodyText2,

  ),
);*/

