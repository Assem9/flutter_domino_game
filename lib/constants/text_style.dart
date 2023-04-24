import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_colors.dart';

//copied from darkMode

TextStyle displayMedium = GoogleFonts.dancingScript(
    textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: Colors.black54,
    )
);

TextStyle displaySmall = GoogleFonts.aclonica(
    textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black38,
    )
);

TextStyle titleLarge = GoogleFonts.pacifico(
    textStyle: const TextStyle(
        fontSize: 26,
        color: MyColors.lemon
    )
) ;

TextStyle titleMedium = GoogleFonts.aBeeZee(textStyle: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: MyColors.lightBeige,
) );

TextStyle bodyLarge = GoogleFonts.aBeeZee(
    textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
    )
);

TextStyle bodyMedium = GoogleFonts.aBeeZee(
    textStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
    )
);

TextStyle bodySmall = GoogleFonts.aBeeZee(
    textStyle: const TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.bold,
      color: Colors.black54,
    )
);


/*


    bodyText2: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: MyColors.darkWhite
    ),
 */