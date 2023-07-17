import 'package:domino_game/presentation/widgets/app_logo_widget.dart';
import 'package:flutter/material.dart';
import '../../constants/my_colors.dart';
import 'default_button.dart';

class DefaultDialog extends StatelessWidget {
  const DefaultDialog({
    Key? key,
    this.title,
    required this.content,
    required this.onConfirm,
    this.contentWidget
  }) : super(key: key);

  final String? title;
  final String content;
  final Function onConfirm ;
  final Widget? contentWidget ;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        icon: Align(
            alignment: AlignmentDirectional.topStart,
            child: AppLogoWidget(radius: MediaQuery.of(context).size.height/18),
        ),
        content: contentWidget ??
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        backgroundColor: MyColors.sky,
        elevation: 10,
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              Expanded(
                  child: DefaultButton(
                    buttonColor: MyColors.blue,
                    title: 'CANCEL',
                    onTap: ()=> Navigator.pop(context),
                  ),
              ),
              const SizedBox(width: 5,),
              Expanded(
                child: DefaultButton(
                    buttonColor: MyColors.lemon,
                    title: 'CONFIRM',
                    onTap: (){onConfirm();}
                ),
              ),
            ],
          )
        ]
    );
  }

}
