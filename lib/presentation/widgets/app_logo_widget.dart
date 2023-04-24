import 'package:flutter/material.dart';

import '../../constants/my_colors.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({Key? key, required this.radius}) : super(key: key);
  final double radius ;
  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: MyColors.sky,
      shadowColor: MyColors.darkBlue,
      elevation: 10,
      shape: BoxShape.circle,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return  const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomRight,
              colors: [
                MyColors.white,
                MyColors.lightBeige,
                MyColors.lemon ,
                MyColors.sky,

              ]
          ).createShader(bounds);
        },
        child: CircleAvatar(
            radius: radius , // MediaQuery.of(context).size.height/8,
            backgroundImage: const AssetImage('assets/images/dom_logo.jpg',)
        ),
      ),
    );
  }
}
