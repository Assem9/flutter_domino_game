
/*
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:domino/presentation/widgets/player_widget.dart';
import 'package:domino/presentation/widgets/domino_piece_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/dom_piece.dart';
import '../../constants/components.dart';
import '../../constants/my_colors.dart';
import '../../cubits/game_cubit/game_cubit.dart';
import '../../cubits/game_cubit/game_states.dart';
import '../../data/models/board_target.dart';
import '../../data/models/match.dart';
import '../../data/models/match_screen_settings.dart';
import '../../data/models/player.dart';
import 'draggable_domino.dart';

Widget buildBoard({
  required context,
  required DominoMatch match,
  required MatchScreenSettings screenSettings
}){
  return BlocListener<GameCubit,GameStates>(
    listener: (context, state) async{
      if(state is OnTurnPlayerChanged && match.playerTwo.isPlaying){
        await Future.delayed(
            const Duration(milliseconds: 500),
                ()=>GameCubit.get(context).dominoBotPlays()
        ) ;
      }
      if(state is OfflineMatchCreated ){
        print('board');
        if(state.botGotP6_6){
          await Future.delayed(
              const Duration(milliseconds: 500),
                  ()=>GameCubit.get(context).dominoBotPlays()
          ) ;
        }

      }

    },
    child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          buildPlayersDataWidget(match),
          buildPullFromOutBoardListButton(context, match: match) ,
          //A
          Positioned(
              top: screenSettings.listA.verticalPosition,
              child: buildUiPiecesList(
                  pieces: screenSettings.listA.pieces,
                  rotateTurn: 4,
                  match: match
              )
          ),
          //B
          Positioned(
              top: screenSettings.listB.verticalPosition,//screenSettings.listA.listHeight + 37.5,// match.dominoBoard.listA.listHeight ,// 50,
              left: screenSettings.listB.horizontalPosition,
              child: buildUiPiecesList(
                  pieces: screenSettings.listB.pieces,
                  rotateTurn: 1,
                  match: match
              )
          ),
          //C
          Positioned(
              top: screenSettings.listC.verticalPosition,
              left: screenSettings.listC.horizontalPosition,
              child: buildUiPiecesList(
                  pieces: screenSettings.listC.pieces,
                  rotateTurn:2,
                  match: match,
              )
          ),
          //D
          Positioned(
              bottom: screenSettings.listD.verticalPosition,
              right: screenSettings.listD.horizontalPosition,
              child: buildUiPiecesList(
                  pieces: screenSettings.listD.pieces,
                  rotateTurn: 1,
                  match: match,
              )
          ),
          //E
          Positioned(
              bottom: screenSettings.listE.verticalPosition,
              right: screenSettings.listE.horizontalPosition,
              child: buildUiPiecesList(
                  pieces: screenSettings.listE.pieces,
                  rotateTurn: 2,
                  match: match,
              )
          ),

          buildVsAnimatedWidget(context) ,
          Container(
            alignment: AlignmentDirectional.centerStart,
            child: buildMyPlayerPiecesListView(
                context,
                player: GameCubit.get(context).myPlayer,
                match: match
            ),
          ),
          Container(
            alignment: AlignmentDirectional.centerEnd,
            child: buildMyPlayerPiecesListView(
                context,
                player: GameCubit.get(context).botPlayer,
                match: match
            ),
          ),
          buildTarget(
              context,
              target: screenSettings.leftTarget,
              color: MyColors.lemon,
              onAccept: (piece)=> GameCubit.get(context).dragPieceInLeftTarget(match: match, draggedPiece: piece),
              screenSettings: screenSettings
          ),
          buildTarget(
              context,
              target:  screenSettings.rightTarget,
              color: MyColors.red1,
              onAccept: (piece)=> GameCubit.get(context).dragPieceInRightTarget(match: match, draggedPiece: piece),
              screenSettings: screenSettings
          ),
        ]
    ),
  );
}

Widget buildPlayersDataWidget(DominoMatch match){
  return Container(
    alignment: AlignmentDirectional.centerEnd,
    margin: const EdgeInsets.symmetric(horizontal: 6,vertical: 6),
    child: RotatedBox(
      quarterTurns: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlayerDataWidget(player: match.playerOne),
          const Spacer(), //SizedBox(width: 20,),
          RotatedBox(
              quarterTurns:4,
              child: PlayerDataWidget(player: match.playerTwo)),
        ],
      ),
    ),
  );
}

Widget buildTarget(context,{
  required BoardTarget target ,
  required Color color ,
  required Function onAccept,
  required MatchScreenSettings screenSettings,
}){
  return Positioned(
    top: target.top,
    bottom: target.bottom,
    left: target.left,
    right: target.right,
    child: DragTarget(
      onAccept: (DomPiece piece){
        if(GameCubit.get(context).myPlayer.isPlaying){
          onAccept(piece);
        }else{
          showToast(message: 'Wait your turn');
        }
      },
      builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) {
        return RotatedBox(
          quarterTurns: target.rotateTurn ,
          child: Container(
            height: screenSettings.pieceHeight,
            width: screenSettings.pieceHeight * 2,
            decoration: BoxDecoration(
                color: color.withOpacity(0.5),
                //  borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black26,width: 2)
            ),
            child: Text(target.value.toString()),

          ),
        );
      },
    ),
  );
}

Widget buildUiPiecesList({
  required List<DomPiece> pieces,
  required int rotateTurn,
  required DominoMatch match
}){
  return RotatedBox(
    quarterTurns: rotateTurn,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pieces.map(
              (e) => DominoPieceWidget(piece: e, match: match)
      ).toList(),
    ),
  );
}

Widget buildPullFromOutBoardListButton(context,{required DominoMatch match}){
  return InkWell(
    onTap: (){

      if(GameCubit.get(context).myPlayer.isPlaying){
        GameCubit.get(context).pullFromOutBoardList(match: match) ;
      }else{
        showToast(message: 'Wait your turn');
      }
    },
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        alignment: AlignmentDirectional.topStart,
        child: const PhysicalModel(
          color: MyColors.lightColor,
          shape: BoxShape.circle,
          elevation: 6,
          shadowColor: MyColors.darkBlue ,
          child: CircleAvatar(
            backgroundColor: MyColors.lemon,
            radius: 20,
            child: Icon(Icons.front_hand),
          ),
        ),
      ),
    ),
  );
}

Widget buildMyPlayerPiecesListView(context, {
  required DomPlayer player,
  required DominoMatch match
}){
  return Container(
    // alignment: AlignmentDirectional.centerStart,
    child: RotatedBox(
      quarterTurns: 1,
      child: SizedBox(
        height: GameCubit.get(context).matchScreenSettings.pieceHeight,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index)=> DraggableDominoPiece(piece: player.pieces[index], match: match,) ,
          itemCount: player.pieces.length,),
      ),
    ),
  );
}

Widget buildVsAnimatedWidget(context){
  return Container(
    alignment: AlignmentDirectional.centerEnd,
    child: RotatedBox(
      quarterTurns: 1,
      child: Container(
        padding: const EdgeInsets.symmetric( horizontal: 20),
        decoration: BoxDecoration(
            color: MyColors.blue,
            borderRadius: BorderRadius.circular(5)
        ),
        child: AnimatedTextKit(
            repeatForever: true,
            pause: const Duration(seconds: 10),
            animatedTexts: [
              ColorizeAnimatedText(
                'VS ',
                textStyle: Theme.of(context).textTheme.titleLarge!,
                colors: [MyColors.light, MyColors.blue,MyColors.lemon,MyColors.red1],

              ),
            ]
        ),
      ),
    ),
  );
}
*/