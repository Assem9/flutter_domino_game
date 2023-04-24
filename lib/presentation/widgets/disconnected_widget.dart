import 'package:domino_game/constants/my_colors.dart';
import 'package:domino_game/presentation/widgets/app_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DisconnectedWidget extends StatelessWidget {
  const DisconnectedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SvgPicture.asset(
            'assets/images/disconnected.svg',
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const AppLoader(size: 40,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Disconnected',
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(color: MyColors.lemon),
                  ),
                  Text(
                    'Check your internet connection',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: MyColors.lightBeige),
                  ),
                ],
              ),

            ],
          )
        ),
      ],
    );
  }
}
