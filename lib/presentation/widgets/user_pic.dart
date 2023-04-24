

import 'package:flutter/material.dart';

import '../../constants/my_colors.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    Key? key,
    required this.avatarUrl,
    required this.radius,
    required this.online
  }) : super(key: key);

  final String avatarUrl ;
  final double radius ;
  final bool online ;

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: MyColors.lightColor,
      shape: BoxShape.circle,
      elevation: 6,
      shadowColor: MyColors.darkBlue ,
      child:  online ?
      CircleAvatar(
        radius: radius,
        backgroundImage:NetworkImage(avatarUrl),
      ):
      CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage('assets/images/default_avatar.png'),
      ),
    );
  }
}
