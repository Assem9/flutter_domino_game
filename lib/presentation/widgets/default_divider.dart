import 'package:flutter/cupertino.dart';

import '../../constants/my_colors.dart';

class DefaultDivider extends StatelessWidget {
  const DefaultDivider({
    Key? key,
    required this.color,
    required this.isVertical,
    required this.withMargin
  }) : super(key: key);

  final Color color ;
  final bool isVertical ;
  final bool withMargin ;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: !withMargin ? EdgeInsets.zero :
      EdgeInsets.symmetric(
          horizontal: isVertical ? 10 : 0 ,
          vertical: isVertical ? 0 : 10
      ),
      width: isVertical ? 1 : null,
      height: isVertical ? null : 1,
      color: color,
    );
  }
}
