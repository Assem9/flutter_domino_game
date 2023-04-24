import 'package:flutter/material.dart';
import '../../constants/my_colors.dart';

class DefaultTextField extends StatelessWidget {
  final TextEditingController controller ;
  final String hint ;
  final TextInputType type ;
  final Widget? suffixIcon ;
  final int? maxLines ;
  final InputBorder? border ;
  final bool? obscureText ;

  const DefaultTextField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.type,
    this.suffixIcon,
    this.maxLines,
    this.border, this.obscureText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: MyColors.sky,
      ),
      child: TextFormField(
        maxLines: maxLines ?? 1,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MyColors.lightBeige) ,
        controller: controller ,
        obscureText: obscureText?? false,
        validator: (value){
          if(value!.isEmpty) {
            return 'please $hint ';
          }
          return null;
        },
      //  cursorColor: Colors.red,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:  Theme.of(context).textTheme.bodyMedium!.copyWith(color: MyColors.lightBeige) ,
          border: border ??  OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          suffixIcon: suffixIcon
        ) ,
      ),
    );
  }
}
