import 'package:flutter/material.dart';

import '../../constants/my_colors.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({Key? key, this.title, this.textColor, this.size, this.loaderColor}) : super(key: key);
  final String? title ;
  final Color? textColor ;
  final Color? loaderColor ;
  final double? size;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        SizedBox(
          height: size?? 100,
          width: size?? 100,
          child: CircularProgressIndicator(
            color: loaderColor?? MyColors.lemon,
            backgroundColor: MyColors.blue,
            strokeWidth: 6,
          ),
        ),
        title != null
            ? Text(title!,style: Theme.of(context).textTheme.bodyLarge,)
            : Container(),
      ],
    );
  }
}
