
import 'package:flutter/cupertino.dart';

import 'match.dart';
import 'match_screen_settings.dart';

class BoardTarget{
  int? value ;
  late int rotateTurn ;
  late bool isLeft ;
  late ListsOpenMode mode ;
  double? left ;
  double? right ;
  double? top ;
  double? bottom ;

  BoardTarget({
    required this.rotateTurn,
    required this.isLeft,
    this.right,
    this.top,
    this.bottom,
  }) {
    mode = ListsOpenMode.lsitA_isOpen ;
  }

  void move(MatchScreenSettings settings,DominoMatch match){
    switch(mode){
      // done
    //match.dominoBoard.inBoardPieces.length > 2
      case  ListsOpenMode.lsitA_isOpen :
        double newRight = 0 ;
        if(isLeft){
          if(match.dominoBoard.inBoardPieces.length > 2){
            right = (settings.screenWidth/2) + (settings.listA.listHeight/2)- (settings.pieceHeight);
          }else{
            right = (settings.screenWidth/2) + (settings.listA.listHeight/2) ;
          }
        }else{
          if(match.dominoBoard.inBoardPieces.length > 2){
            right = (settings.screenWidth/2) - (settings.pieceHeight) - (settings.listA.listHeight/2);
          }else{
            right = (settings.screenWidth/2) - (settings.pieceHeight*2) - (settings.listA.listHeight/2);
          }
        }
        debugPrint(right .toString()) ;
        break ;
      case ListsOpenMode.listB_isOpen:
        rotateTurn = 3 ;
        right = right! ;//- (settings.listB.horizontalPosition!/2);
        bottom = settings.listB.verticalPosition! + settings.listB.listHeight -  (settings.pieceHeight /2);
        debugPrint('move target top: $top') ;
        break;
      case ListsOpenMode.listC_isOpen:
        rotateTurn = 2 ;
        bottom = settings.listC.verticalPosition! - settings.pieceHeight/2; //settings.pieceHeight/2
        right = null;
        left = settings.listC.horizontalPosition! + settings.listC.listHeight - settings.pieceHeight;
        debugPrint('move target: $right') ;
        break;
      case ListsOpenMode.listD_isOpen:
        rotateTurn = 3 ;
        right = settings.listD.horizontalPosition ;
        top = settings.listD.verticalPosition! + settings.listB.listHeight - (settings.pieceHeight /2);//+ settings.pieceHeight;
        debugPrint(bottom .toString()) ;
        break;
      case ListsOpenMode.listE_isOpen:
        rotateTurn = 2 ;
        left = null ;
        top = settings.listE.verticalPosition! - settings.pieceHeight/2 ;
        right = settings.listE.horizontalPosition! + settings.listE.listHeight - settings.pieceHeight;
        debugPrint(top .toString()) ;
        break;
    }
  }
}

enum ListsOpenMode{
  lsitA_isOpen,
  listB_isOpen,
  listC_isOpen,
  listD_isOpen,
  listE_isOpen,
}