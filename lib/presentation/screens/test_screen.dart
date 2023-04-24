import 'package:domino_game/cubits/game_cubit/game_cubit.dart';
import 'package:domino_game/cubits/game_cubit/game_states.dart';
import 'package:domino_game/presentation/widgets/app_logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/my_colors.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.darkBlue ,
      body: Center(child: AppLogoWidget(radius: 100)),
    );
  }

  Widget buildTarget(int boardValue){
    return DragTarget(
      onAccept: (data) {
        if(boardValue== data){
          print('matches');
        }else{
          print('doesnt match ');
        }
      },
      builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) {
        return Container(
          width: 50,
          height: 50,
          color: Colors.orange,
          child: Text('$boardValue'),
        );
      },

    );
  }

  Widget buildDraggable(int pieceValue){
    return Draggable<int>(
      data: pieceValue,
      feedback: Container(
        width: 50,
        height: 50,
        color: Colors.white,
        child: Text(pieceValue.toString()),
      ),
      childWhenDragging: Container(
        width: 50,
        height: 50,
        color: Colors.red,
      ),
      child: Container(
        width: 50,
        height: 50,
        color: Colors.white,
      ),
    );
  }

}
