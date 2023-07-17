import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import '../../constants/my_colors.dart';

class AppAnimatedTitle extends StatelessWidget {
  const AppAnimatedTitle({
    Key? key,
    required this.titleTextStyle,
    required this.subtitleTextStyle,
    required this.subtitleTextsList
  }) : super(key: key);
  final TextStyle titleTextStyle ;
  final TextStyle subtitleTextStyle ;
  final List<AnimatedText> subtitleTextsList ;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultTextStyle(
          style: titleTextStyle,
          //Theme.of(context).textTheme.displaySmall!.copyWith(color: MyColors.lemon, fontSize: 40),
          child: AnimatedTextKit(
              repeatForever: true,
              animatedTexts: [
                WavyAnimatedText('DOMINO  MASTERS',),
                ColorizeAnimatedText(
                    'DOMINO MASTERS',
                    textStyle: titleTextStyle,
                    colors: [MyColors.lemon, MyColors.blue, MyColors.sky]
                )
              ]
          ),
        ),
        DefaultTextStyle(
          style: subtitleTextStyle,
          // Theme.of(context).textTheme.displayMedium!.copyWith(color: MyColors.lightBeige, fontSize: 15),
          child: AnimatedTextKit(
            repeatForever: true,
            animatedTexts: subtitleTextsList
          ),
        ),
      ],
    );
  }
}
