import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:domino_game/constants/components.dart';
import 'package:domino_game/data/models/board_target.dart';
import 'package:domino_game/data/models/match_enums.dart';
import 'package:domino_game/data/models/player.dart';
import 'package:domino_game/presentation/widgets/alert_dialog.dart';
import 'package:domino_game/presentation/widgets/player_widget.dart';
import 'package:domino_game/presentation/widgets/turn_duration_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../constants/constants.dart';
import '../../constants/my_colors.dart';
import '../../constants/strings.dart';
import '../../cubits/game_cubit/game_cubit.dart';
import '../../cubits/game_cubit/game_states.dart';
import '../../data/models/dom_piece.dart';
import '../../data/models/match.dart';
import '../../data/models/match_screen_settings.dart';
import 'domino_piece_widget.dart';

class BoardWithDragTargetWidget extends StatelessWidget {
  const BoardWithDragTargetWidget({
    Key? key,
    required this.match,
    required this.screenSettings
  }) : super(key: key);

  final DominoMatch match;
  final MatchScreenSettings screenSettings ;

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameCubit,GameStates>(
      listener: (BuildContext context, state) async{
        var cubit  = GameCubit.get(context);
        if(!match.isOnline && state is OnTurnPlayerChanged && match.playerTwo.isPlaying ){
         await Future.delayed(
             const Duration(milliseconds: 6750),
                 ()=> cubit.dominoBotPlays(bot: cubit.botPlayer, match: cubit.offlineMatch)
         );
        }
        if(state is PlayerLeftMatch){
          Navigator.pushNamedAndRemoveUntil(context, home,(route) => false) ;
        }
      },
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          buildVsAnimatedWidget(context) ,
          match.isOnline ?
          buildOnlinePlayersDataWidget()
          :_buildOfflinePlayersData(),
          match.state == MatchState.ONGOING ?
          Align(
              alignment: AlignmentDirectional.bottomStart,
              child: buildPullFromOutBoardListButton(context)
          ): Container() ,
          //A
          Positioned(
              top: screenSettings.listA.verticalPosition,
              bottom: screenSettings.listA.verticalPosition,
              child: buildUiPiecesList(screenSettings.listA,3)
          ),
          //B
          Positioned(
              bottom: screenSettings.listB.verticalPosition,//screenSettings.listA.listHeight + 37.5,// match.dominoBoard.listA.listHeight ,// 50,
              left: screenSettings.listB.horizontalPosition,
              child: buildUiPiecesList(screenSettings.listB ,4)
          ),
          //C
          Positioned(
              bottom: screenSettings.listC.verticalPosition,
              left: screenSettings.listC.horizontalPosition,
              child: buildUiPiecesList(screenSettings.listC ,1)
          ),
          //D
          Positioned(
              top: screenSettings.listD.verticalPosition,
              right: screenSettings.listD.horizontalPosition,
              child: buildUiPiecesList(screenSettings.listD ,4)
          ),
          //E
          Positioned(
              top: screenSettings.listE.verticalPosition,
              right: screenSettings.listE.horizontalPosition,
              child: buildUiPiecesList(screenSettings.listE ,1)
          ),


          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: buildMyPlayerPiecesListView(
                context,
                player: GameCubit.get(context).myPlayer
            ),
          ),

          buildTarget(
              context,
              target: screenSettings.leftTarget,
              color: MyColors.lemon,
              onAccept: (piece)=> GameCubit.get(context).dragPieceInLeftTarget(match: match, draggedPiece: piece)
          ),
          // if first play => cant play right
          match.dominoBoard.inBoardPieces.isNotEmpty ?
          buildTarget(
              context,
              target: screenSettings.rightTarget,
              color: MyColors.red1,
              onAccept: (piece)=> GameCubit.get(context).dragPieceInRightTarget(match: match, draggedPiece: piece)
          ) : Container(),
          GameCubit.get(context).isOutBoardListShown ?
          Align(
              alignment: AlignmentDirectional.bottomStart,
              child: buildOutBoardList(context)
          ): Container(),

          buildQuitButton(context),
        ]
      ),
    );
  }



  Widget buildOnlinePlayersDataWidget(){
    return Container(
      alignment: AlignmentDirectional.topCenter,
      margin: const EdgeInsets.symmetric(horizontal: 6,vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlayerDataWidget(player: match.playerOne, isOnline: true,),
          buildOpponentPiecesGridView( player: match.playerOne),
          match.playerOne.isPlaying
              ? const PlayerTurnDuration()
              : Container(),
          const Spacer(),
          match.playerTwo.isPlaying
              ? const PlayerTurnDuration()
              : Container(),
          buildOpponentPiecesGridView( player: match.playerTwo),
          RotatedBox(
              quarterTurns:4,
              child: PlayerDataWidget(player: match.playerTwo, isOnline: true,)
          )

        ],
      ),
    );
  }

  Widget _buildBotLottie(){
    return Stack(
      children: [
        RotatedBox(
            quarterTurns: 4,
            child: PlayerDataWidget(player: match.playerTwo, isOnline: false,)),
        PhysicalModel(
          color: MyColors.lightColor,
          shape: BoxShape.circle,
          elevation: 6,
          shadowColor: MyColors.darkBlue ,
          child: CircleAvatar(
            radius:  match.playerTwo.isPlaying ? 35 :20,
            child: Lottie.asset(
                'assets/images/robot_thinking.zip',
                animate: match.playerTwo.isPlaying ? true :false,
                fit: BoxFit.contain
            ) ,
          ),
        )
      ],
    );
  }

  Widget _buildOfflinePlayersData(){
    return Container(
      alignment: AlignmentDirectional.topCenter,
      margin: const EdgeInsets.symmetric(horizontal: 6,vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlayerDataWidget(player: match.playerOne, isOnline: false,),
          buildOpponentPiecesGridView( player: match.playerOne),
          const Spacer(),
          buildOpponentPiecesGridView( player: match.playerTwo),//SizedBox(width: 20,),
         _buildBotLottie(),
        ],
      ),
    );
  }

  Widget buildTarget(context,{
    required BoardTarget target ,
    required Color color ,
    required Function onAccept,
  }){
    return Positioned(
      top: target.top,
      bottom: target.bottom,
      left: target.left,
      right: target.right,
      child: DragTarget(
        onAccept: (DomPiece piece){
          debugPrint('target value in touch ${target.value}');
          var cubit = GameCubit.get(context);
          if(cubit.onTurnPlayer(match).iD == cubit.myPlayer.iD ){
            onAccept(piece);
          }else{
            showToast(message: 'Wait your turn');
          }
        },
        builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) {
          return RotatedBox(
            quarterTurns: target.rotateTurn ,
            child: Container(
              height: screenSettings.pieceHeight  * 1.5,
              width: screenSettings.pieceHeight * 2,
              decoration:  BoxDecoration(
                  color: MyColors.blue.withOpacity(0.1) ,
                  borderRadius: BorderRadius.circular(20),
                  /*boxShadow: [
                    BoxShadow(
                      color: MyColors.blue.withOpacity(0.7),
                      blurRadius: 22,
                      spreadRadius: screenSettings.pieceHeight/2  ,
                      //offset: Offset(0, -1.5),
                    ),
                  ]*/
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildRotatableDominoPiece(DomPiece piece){
    return RotatedBox(
      quarterTurns: piece.rightHalf.value == piece.leftHalf.value
          ? piece.rotateTurn +1
          : piece.rotateTurn,
      child: DominoPieceWidget(piece: piece, match: match, height: screenSettings.pieceHeight,),
    );
  }

  Widget buildUiPiecesList(ScreenPiecesList list,int rotateTurn){
    return RotatedBox(
      quarterTurns: rotateTurn,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: list.pieces.map(
                (piece) => buildRotatableDominoPiece(piece)
        ).toList(),
      ),
    );
  }

  Widget buildPullFromOutBoardListButton(context){
    return InkWell(
      onTap: (){
        if(GameCubit.get(context).myPlayer.isPlaying ){
          GameCubit.get(context).pullFromOutBoardList(match: match) ;
        }else{
          showToast(message: 'Wait your turn');
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PhysicalModel(
          color: MyColors.lightColor,
          shape: BoxShape.circle,
          elevation: 6,
          shadowColor: MyColors.darkBlue ,
          child: CircleAvatar(
            backgroundColor: match.dominoBoard.outBoardPieces.isNotEmpty
                ? MyColors.lemon : MyColors.red1,
            radius: 20,
            child: Text(
              match.dominoBoard.outBoardPieces.isNotEmpty ?
              'Pull' : 'Pass',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOutBoardList(context){
    return Container(
      margin: const EdgeInsets.only(top: 80,bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal:5 ,vertical: 5),
      width: (GameCubit.get(context).matchScreenSettings.pieceHeight * 2) + 12,
        color: MyColors.darkBlue.withOpacity(0.5),
      child: Column(
        children: [
          Text(
            '${match.dominoBoard.outBoardPieces.length} piece left',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Expanded(
              child:  GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio:2/1  ,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 4,
                ),
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index)=> buildDominoPieceBack(context),
                itemCount: match.dominoBoard.outBoardPieces.length,
              ),
          ),
        ],
      ),
    );
  }

  Widget buildDominoPieceBack(context){
    return PhysicalModel(
      color: MyColors.lightColor,
      borderRadius: BorderRadius.circular(5),
      elevation: 2,
      shadowColor: MyColors.darkBlue ,
      child: Container(
        width: GameCubit.get(context).matchScreenSettings.pieceHeight,
        height: GameCubit.get(context).matchScreenSettings.pieceHeight/2,
        decoration: BoxDecoration(
            color: MyColors.lightColor,
            border: Border.all(width: 2,color: MyColors.blue),
            borderRadius: BorderRadius.circular(5)
        ),
        child: Row(
          children: [
            Expanded(child:Container()),
            Container(
              width: 3,
              height: GameCubit.get(context).matchScreenSettings.pieceHeight/2,
              color: MyColors.blue,
            ),
            Expanded(child:Container()),
          ],
        ),
      ),
    );
  }

  Widget buildDraggableDomino(DomPiece piece){
    return Draggable<DomPiece>(
        data: piece,
        feedback: DominoPieceWidget(
          piece: piece,
          match: match,
          height: screenSettings.pieceHeight,
        ),
        childWhenDragging: DominoPieceWidget(
          piece: piece,
          match: match,
          height: screenSettings.pieceHeight,
          color: MyColors.lemon,
        ) ,
        child: DominoPieceWidget(
          piece: piece,
          match: match,
          height: screenSettings.pieceHeight,
        )
    );
  }

  Widget buildMyPlayerPiecesListView(context, {required DomPlayer player}){
    return Container(
      padding: const EdgeInsets.only(top: 8, left: 14,right: 14,bottom: 2),
      decoration: const BoxDecoration(
        color: MyColors.blue,
        borderRadius: BorderRadius.only(topRight: Radius.circular(23) ,topLeft: Radius.circular(23) )
      ),
      child: SizedBox(
        height: GameCubit.get(context).matchScreenSettings.pieceHeight,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index)=> buildDraggableDomino(player.pieces[index]) ,
          itemCount: player.pieces.length,),
      ),
    );
  }

  Widget buildOpponentPiecesGridView( {required DomPlayer player}){
    return RotatedBox(
      quarterTurns: 1,
      child: SizedBox(
        //height: 100,
        width: screenSettings.pieceHeight ,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio:3/1.8  ,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemBuilder: (context, index)=> buildDominoPieceBack(context),
          itemCount: player.pieces.length,
        ),
      ),
    );
  }
  
  Widget buildVsAnimatedWidget(context){
    return Align(
      alignment: AlignmentDirectional.topCenter,
      child: Container(
        padding: const EdgeInsets.symmetric( horizontal: 20,vertical: 3),
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
                textStyle: Theme.of(context).textTheme.displaySmall!,
                colors: MyColors.colorizeColors,

              ),
            ]
        ),
      ),
    );
  }

  Widget buildQuitButton(cubitContext){
    return Positioned(
      bottom: 10,
      right: 5,
      child: CircleAvatar(
        backgroundColor: MyColors.lemon,
        child: IconButton(
            onPressed: ()=> showDialog(
                context: cubitContext,
                builder: (context)=> DefaultDialog(
                    title: 'Domino',
                    content: 'Are sure you want to quit match',
                    onConfirm: (){
                      if(uId !=null){
                        GameCubit.get(cubitContext).playerQuitMatch(match) ;
                      }else{
                        Navigator.pushNamedAndRemoveUntil(context, firstScreen, (route) => false);
                      }
                    }
                )
            ),
            icon: const Icon(Icons.exit_to_app,color: Colors.white,)
        ),
      ),
    );
  }

}