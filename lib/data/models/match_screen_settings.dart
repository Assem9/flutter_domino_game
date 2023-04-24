import 'package:flutter/cupertino.dart';

import 'board_target.dart';
import 'dom_piece.dart';
import 'match.dart';

class MatchScreenSettings{
  late ScreenPiecesList listA ;
  late ScreenPiecesList listB ;
  late ScreenPiecesList listC ;
  late ScreenPiecesList listD ;
  late ScreenPiecesList listE ;
  late double screenHeight ;
  late double screenWidth ;
  late double pieceHeight ;
  late DomPiece firstPiece ;
  late DomPiece lastPiece ;
  late BoardTarget leftTarget ;
  late BoardTarget rightTarget ;

  MatchScreenSettings({required double width,required double height}){
    screenWidth = width ;
    screenHeight = height ;
    firstPiece = lastPiece =  DomPiece('none', HalfDom("none",6), HalfDom("none",6));
    debugPrint('h: $screenHeight  w: $screenWidth') ;
  }

  void initializedTargets(){
    leftTarget = BoardTarget(
      rotateTurn: 0,
      right: screenWidth/2 - (pieceHeight/4),
      isLeft: true,
    );
    rightTarget = BoardTarget(
      rotateTurn: 0,
      right: screenWidth/2 - pieceHeight - (pieceHeight/4),
      isLeft: false,
    );
  }

  void setPieceHeight(){
    int noOfPiecesInVerticalLists = 0 ;

    if(screenWidth >= 732 ){
      // listA can hold 14 pieces
      // list limit is 12 * screen height
      pieceHeight = screenWidth / 14 ;
      noOfPiecesInVerticalLists = 12 ;
    }else if(screenWidth >= 640 ){
      pieceHeight = screenWidth / 12 ;
      noOfPiecesInVerticalLists = 10 ;
    }else if(screenWidth >= 520 ){
      pieceHeight = screenWidth / 10 ;
      noOfPiecesInVerticalLists = 8 ;
    }else{
      // listA can hold 8 pieces
      pieceHeight = screenWidth / 8 ;
      noOfPiecesInVerticalLists = 8 ;
    }
    initializeLists(noOfPiecesInVerticalLists);
  }

  void initializeLists(noOfPiecesInVerticalLists){
    listA = ScreenPiecesList(isOpen: true, maxHeight: noOfPiecesInVerticalLists * pieceHeight );
    listB = ScreenPiecesList(
        isOpen: false,
        maxHeight: (screenHeight/2) - (pieceHeight * 1.5) ,
        verticalPosition:  (screenHeight/2 ) + (pieceHeight / 4)
    );
    listD = ScreenPiecesList(
        isOpen: false,
        maxHeight: (screenHeight/2) - (pieceHeight * 1.5) ,
        verticalPosition:  (screenHeight/2 ) + (pieceHeight / 4)

    );
    listC = ScreenPiecesList(
      isOpen: false,
      maxHeight: listA.maxHeight,
    );
    listE = ScreenPiecesList(isOpen: false, maxHeight: listA.maxHeight);
  }

  double increaseListHeight(ScreenPiecesList currentList,DomPiece piece){
    double plusHeight = 0 ;
    if(piece.rightHalf.value == piece.leftHalf.value){
      plusHeight = pieceHeight/2 ;
      currentList.listHeight += plusHeight;
    }else{
      plusHeight = pieceHeight ;
      currentList.listHeight += plusHeight;
    }
    return plusHeight ;
  }

  bool checkIfListIsOpen(ScreenPiecesList currentList,DomPiece piece){
    double increasedHeight = increaseListHeight(currentList, piece) ;
    if(currentList.listHeight > currentList.maxHeight ){
      currentList.isOpen = false ;
      currentList.listHeight -= increasedHeight ;
    }
    debugPrint('list h: ${currentList.listHeight} max h: ${currentList.maxHeight}');
    return currentList.isOpen ;

  }

  void checkIfListBNeedToMove(){
    if(listA.pieces.first.rightHalf.value == listA.pieces.first.leftHalf.value ){
      listB.verticalPosition = listB.verticalPosition! +  (pieceHeight/4) ;
    }
  }

  void checkIfListDNeedToMove(){
    if(listA.pieces.last.rightHalf.value == listA.pieces.last.leftHalf.value ){
      listD.verticalPosition = listD.verticalPosition! +  (pieceHeight/4) ;
    }
  }

  void checkIfListCNeedToMove(){
    if(listB.pieces.last.rightHalf.value == listB.pieces.last.leftHalf.value ){
      debugPrint(listB.pieces.last.iD);
      listC.horizontalPosition = listC.horizontalPosition! +  (pieceHeight /2) ;
    }
  }

  void checkIfListENeedToMove(){
    if(listD.pieces.last.rightHalf.value == listD.pieces.last.leftHalf.value ){
      debugPrint(listD.pieces.last.iD);
      listE.horizontalPosition = listE.horizontalPosition! +  (pieceHeight/2)  ;
    }
  }

  ScreenPiecesList closingListA(DomPiece piece, BoardTarget target){
    listA.horizontalPosition = (screenWidth - listA.listHeight) / 2;
    listC.horizontalPosition = listE.horizontalPosition = listA.horizontalPosition!  + (pieceHeight /2);
    if(target.isLeft){
      openListB(piece) ;
      return listB ;
    }else{
      openListD(piece);
      return listD ;
    }
  }

  void openListB(DomPiece piece){
    listB.isOpen = true ;
    leftTarget.mode = ListsOpenMode.listB_isOpen;
    if(piece.rightHalf.value == piece.leftHalf.value){
      listB.horizontalPosition = listA.horizontalPosition! - (pieceHeight /2);
      listC.horizontalPosition = listC.horizontalPosition! - (pieceHeight /4);
    }else{
      listB.horizontalPosition = listA.horizontalPosition!  ;
    }
    increaseListHeight(listB, piece) ;
    checkIfListBNeedToMove();
  }

  void openListC(DomPiece piece){
    debugPrint('listC Opened');
    listC.isOpen = true ;
    leftTarget.mode = ListsOpenMode.listC_isOpen;
    listC.verticalPosition = listB.listHeight + listB.verticalPosition! - (pieceHeight /2) ;
    increaseListHeight(listC, piece) ;
    checkIfListCNeedToMove();
  }

  void openListD(DomPiece piece){
    listD.isOpen = true ;
    rightTarget.mode = ListsOpenMode.listD_isOpen;
    if(piece.rightHalf.value == piece.leftHalf.value){
      listD.horizontalPosition = listA.horizontalPosition! - (pieceHeight /2);
      listE.horizontalPosition = listE.horizontalPosition! - (pieceHeight /4);
    }else{
      listD.horizontalPosition = listA.horizontalPosition! ;
    }
    increaseListHeight(listD, piece);
    checkIfListDNeedToMove();
  }

  void openListE(DomPiece piece){
    debugPrint('listE Opened');
    listE.isOpen = true ;
    rightTarget.mode = ListsOpenMode.listE_isOpen;
    listE.verticalPosition = listD.listHeight + listD.verticalPosition! - (pieceHeight /2) ;
    increaseListHeight(listE, piece) ;
    checkIfListENeedToMove();
  }

  ScreenPiecesList getScreenCurrentOpenedPiecesList({
    required DominoMatch match ,
    required DomPiece piece ,
    required BoardTarget target
  }){
    ScreenPiecesList currentOpenList = listA ;
    switch(target.mode){
      case ListsOpenMode.lsitA_isOpen:
        if(checkIfListIsOpen(listA, piece)){
          currentOpenList = listA;
        }else{
          currentOpenList = closingListA(piece,target);
        }
        break;
      case ListsOpenMode.listB_isOpen:
        if(checkIfListIsOpen(listB, piece)){
          currentOpenList = listB;
        }else{
          openListC(piece);
          currentOpenList = listC ;
        }
        break;
      case ListsOpenMode.listC_isOpen:
        if(checkIfListIsOpen(listC, piece)){
          currentOpenList = listC ;
        }
        break;
      case ListsOpenMode.listD_isOpen:
        if(checkIfListIsOpen(listD, piece)){
          currentOpenList = listD;
        }else{
          openListE(piece);
          currentOpenList = listE;
        }
        break;
      case ListsOpenMode.listE_isOpen:
        if(checkIfListIsOpen(listE, piece)){
          currentOpenList = listE ;
        }
        break;
    }
    return currentOpenList;

  }

  void addPieceToLeftTarget({
    required DominoMatch match,
    required DomPiece draggedPiece,
  }){
    if(match.dominoBoard.leftTarget == null && match.dominoBoard.rightTarget == null ){
      rightTarget.value = match.dominoBoard.rightTarget = draggedPiece.rightHalf.value ;
    }
    ScreenPiecesList? currentList = getScreenCurrentOpenedPiecesList(
        match: match,
        piece: draggedPiece,
        target: leftTarget
    ) ;
    currentList.pieces.insert(0, draggedPiece) ;
    firstPiece = draggedPiece;
    leftTarget.value = draggedPiece.leftHalf.value ;

  }

  void addPieceToRightTarget({
    required DominoMatch match,
    required DomPiece draggedPiece,
  }){
    ScreenPiecesList? currentList = getScreenCurrentOpenedPiecesList(
        match: match,
        piece: draggedPiece,
        target: rightTarget
    ) ;
    currentList.pieces.add(draggedPiece) ;
    lastPiece = draggedPiece ;
    rightTarget.value = draggedPiece.rightHalf.value ;

  }

}

class ScreenPiecesList{
  late bool isOpen ;
  late double listHeight ;
  late double maxHeight ;
  double? horizontalPosition ;
  double? verticalPosition ;
  List<DomPiece> pieces = [] ;

  ScreenPiecesList({
    required this.isOpen ,
    required this.maxHeight,
    this.verticalPosition
  }){
    listHeight = 0 ;
    pieces = [] ;
  }

}
