import 'package:domino_game/data/models/match_screen_settings.dart';
import 'package:domino_game/presentation/widgets/default_divider.dart';
import 'package:flutter/material.dart';
import '../../constants/my_colors.dart';
import '../../cubits/game_cubit/game_cubit.dart';
import '../../data/models/dom_piece.dart';
import '../../data/models/match.dart';

class DominoPieceWidget extends StatelessWidget {
  final DomPiece piece ;
  final DominoMatch match ;
  final double height ;
  final Color? color ;
  const DominoPieceWidget({
    super.key,
    required this.piece,
    required this.match,
    required this.height,
    this.color
  });
  Widget _buildDot(context){
    return Container(
      width: height /12,
      height: height  /12,
      alignment: AlignmentDirectional.center,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildHalfDomino(context,int value ){
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Stack(
        children: [
          value == 4 || value == 5 || value == 6?
          Stack(
            children: [
              Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: _buildDot(context)
              ),
              Align(
                  alignment: AlignmentDirectional.topStart,
                  child: _buildDot(context)
              )
            ],
          ):Container(),

          value == 6 ?
          Stack(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: _buildDot(context),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _buildDot(context),
              )
            ],
          ):Container(),

          value == 1 || value == 0
              ?Container() :
          Stack(
            children: [
              Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: _buildDot(context)
              ),
              Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: _buildDot(context)
              )
            ],
          ) ,

          value == 5 || value == 1 || value == 3?
          Center(
            child: _buildDot(context),
          ) : Container(),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  PhysicalModel(
      color: MyColors.darkBlue,
      borderRadius: BorderRadius.circular(4),
      elevation: 4,
      shadowColor: MyColors.darkBlue ,
      child: Container(
        height: height,
        width: height/2 ,
        decoration: BoxDecoration(
            color: color?? MyColors.lightColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black,width: 2)
        ),
        child: Column(
          children: [
            Expanded(
              child: _buildHalfDomino (context,piece.leftHalf.value),
            ),
            const DefaultDivider(color: Colors.black, isVertical: false, withMargin: false),
            Expanded(
              child: _buildHalfDomino(context,piece.rightHalf.value),
            ),
          ],
        ),
      ),
    );
  }
}

class RotatableDominoPiece extends StatelessWidget {
  final DomPiece piece ;
  final DominoMatch match ;
  final double height ;
  const RotatableDominoPiece({super.key, required this.piece, required this.match, required this.height});

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: piece.rightHalf.value == piece.leftHalf.value
          ? piece.rotateTurn +1
          : piece.rotateTurn,
      child: DominoPieceWidget(piece: piece, match: match, height: height,),
    );
  }
}

class OldDominoPiece extends StatelessWidget {
  const OldDominoPiece({Key? key, required this.piece, required this.match, required this.list}) : super(key: key);
  final DomPiece piece ;
  final DominoMatch match ;
  final ScreenPiecesList list ;


  int setPieceRotateValue(ScreenPiecesList list){
    if(list.pieces[0] == piece ){
      return piece.rotateTurn;
    }
    else if(list.pieces.last == piece && !list.isOpen){
      return piece.rotateTurn;
    }
    else if(piece.rightHalf.value == piece.leftHalf.value){
      return piece.rotateTurn +1;
    }else{
      return piece.rotateTurn;
    }
  }

  @override
  Widget build(BuildContext context) {

    return RotatedBox(
      quarterTurns:// setPieceRotateValue(list),
      piece.rightHalf.value == piece.leftHalf.value
          ? piece.rotateTurn +1
          : piece.rotateTurn,
      child: PhysicalModel(
        color: MyColors.darkBlue,
        borderRadius: BorderRadius.circular(4),
        elevation: 2,
        shadowColor: MyColors.darkBlue ,
        child: Container(
          height: GameCubit.get(context).matchScreenSettings.pieceHeight,
          width: GameCubit.get(context).matchScreenSettings.pieceHeight /2 ,
          decoration: BoxDecoration(
              color: MyColors.lightColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black,width: 2)
          ),

          child: Column(
            children: [
              Expanded(
                  child: Text(
                    piece.leftHalf.value.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
              ),
              Container(
                height: 1,
                width: 20,
                color: Colors.black,
              ),
              Expanded(
                  child: Text(
                    piece.rightHalf.value.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
