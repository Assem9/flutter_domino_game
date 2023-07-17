import 'package:flutter/material.dart';
import '../../constants/my_colors.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    Key? key,
    required this.title,
    required this.onTap,
    this.buttonColor ,
    this.textStyle,
    this.width,
    this.height,
    this.textColor,
    this.icon,
  }) : super(key: key);

  final double? width ;
  final double? height ;
  final String title ;
  final Function onTap ;
  final Color? buttonColor;
  final Color? textColor;
  final IconData? icon;
  final TextStyle? textStyle ;

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: height?? 40,
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(buttonColor?? MyColors.lemon),
        ),
        onPressed: (){onTap();},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon != null
                ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(icon,size: 15,color: MyColors.lemon,),
                )
                : Container(),
            Text(
              title,
              overflow: TextOverflow.clip,
              style: textStyle?? Theme.of(context).textTheme.titleMedium!
                  .copyWith(color: textColor?? Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
