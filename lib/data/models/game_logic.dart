
/*
import 'dart:io';
import 'dart:math';
import 'package:domino/models/player.dart';

import 'board.dart';
import 'dom_piece.dart';
import 'user.dart';

class Game{
  late Match match ;
  late Board board ;
  late DomPlayer playerOne ;
  late DomPlayer playerTwo ;

  void giveFirstPiece(List<DomPlayer> players){
    final random = new Random(); 
    int index = random.nextInt(players.length);
    for(DomPlayer player in players){
      
      if(player == players[index]){
        player.pieces.add(board.outBoardPieces[27]);
        board.outBoardPieces.remove(board.outBoardPieces[27]);
        player.isPlaying = true ; // the first turn
       
         
      }else{
        int pieceIndex = random.nextInt(board.outBoardPieces.length);
         player.pieces.add(board.outBoardPieces[pieceIndex]);
      }
    }

  }

  void distributePieces(DomPlayer player){
    int index = 0 ;
    final random = new Random(); 
    for(int i= 0 ; i <6 ; i++){
      index = random.nextInt(board.outBoardPieces.length);
      player.pieces.add(board.outBoardPieces[index]) ;
      board.outBoardPieces.remove(board.outBoardPieces[index]) ;
    }
  }

  void showYourPieces(String id){
    DomPlayer player ;
    if(id == playerOne.iD){
      player = playerOne ;
    }else{
      player = playerTwo ;
    }
    print(player.iD); 
    for(DomPiece piece in player.pieces){
       
      print(piece.iD);    }
  }

  void startOfflineMatch(){
    board = Board();
  //  playerOne = DomPlayer(0,[],'One','player1','asdas');
  //  playerTwo = DomPlayer(0,[],'Two','player2','dsadasadsadsa');
    giveFirstPiece([playerOne,playerTwo]);
    distributePieces(playerOne);
    distributePieces(playerTwo);
    showYourPieces('player1');
    showYourPieces('player2');

  }

  bool leftIsOpen = false; 
  bool rightIsOpen = false;
  Map<String, bool> playingChoices = {'left':false,'right':false,};

  DomPlayer onTurnPlayer(){ 
    if(playerOne.isPlaying){
        return playerOne ;
      }else{
        return playerTwo ;
      } 
  }

  late DomPiece chosenPiece;
  bool domRightEqualsBoardRight= false;
  bool domLeftEqualsBoardLeft= false;

  void getAvailablePlays(DomPlayer player){
    domRightEqualsBoardRight = false;
    domLeftEqualsBoardLeft = false;
    print('Pick A Piece') ;
    String? pickedPieceId = stdin.readLineSync();
    for(DomPiece piece in player.pieces){
      if(piece.iD == pickedPieceId){
        chosenPiece = piece;
      }
    }
    if(chosenPiece.leftHalf.value == board.boardLeftValue ){
      playingChoices['left'] = true ;
      domLeftEqualsBoardLeft = true ;
      print('Left: ${board.boardLeftValue} is avialble') ;
    }else if(chosenPiece.rightHalf.value == board.boardLeftValue){
      playingChoices['left'] = true ;
      print('Left: ${board.boardLeftValue} is avialble') ;
    }else{
      playingChoices['left'] = false ;
    }
    if(chosenPiece.leftHalf.value == board.boardRightValue ){
      playingChoices['right'] = true ;
      print('Right: ${board.boardRightValue} is avialble') ;
    }else if(chosenPiece.rightHalf.value == board.boardRightValue){
      playingChoices['right'] = true ;
      print('Right: ${board.boardRightValue} is avialble') ;
      domRightEqualsBoardRight = true ;
    }else{
      playingChoices['right'] = false ;
    }

    // check if any side availble can play else pull form out list or try another piece
    if(playingChoices['left'] == false && playingChoices['right'] == false){
      print('Can not play this piece pls choose another one');
      print('Pull From OutBoardList ? write y if u want and n for picking another piece from your list ') ;
      String ? userAnswer = stdin.readLineSync();
      if(userAnswer == 'y'){
        pullFromOutBoardList(player);
      }else{
        getAvailablePlays(player);
      }
       
    }else{
      pickPlaySide();
      checkForReshapingDom();
      play(player);
    }
     


  }

  String? chosenSide ;
  void pickPlaySide(){
    if(playingChoices['left'] == true && playingChoices['right'] ==true){
      print('Pick Side') ;
      chosenSide = stdin.readLineSync();
    }else if(playingChoices['left'] == true && playingChoices['right'] ==false){
      chosenSide = 'left' ;
    }else{
      chosenSide = 'right' ;
    }
    
  }

  void checkForReshapingDom(){
    if(domLeftEqualsBoardLeft && chosenSide == 'left'){
      // reshape chosen piece
      chosenPiece.reshapeDom();
    }else if(domRightEqualsBoardRight && chosenSide == 'right'){
      // reshape chosen piece
      chosenPiece.reshapeDom();
    }else{
      print('Reshaping Cases Doesnt exits for this play');
    }
       
  }

  void changePlayerTurn(DomPlayer player){
    if(player.iD == playerOne.iD){
        playerOne.isPlaying = false ;
        playerTwo.isPlaying = true ;
        print('Now Turn For Player Two');
       // checkForAvailablePlays(playerTwo);
       getAvailablePlays(playerTwo);
      }else{
        playerTwo.isPlaying = false ;
        playerOne.isPlaying = true ;
        print('Now Turn For Player One');
        //checkForAvailablePlays(playerOne);
        getAvailablePlays(playerOne);
      }
  }

  void firstPlay(){
    chosenPiece = onTurnPlayer().pieces[0] ;
    board.inBoardPieces.add(chosenPiece) ;
    onTurnPlayer().pieces.remove(chosenPiece);
    changePlayerTurn(onTurnPlayer());
  }

  void play(DomPlayer player){
    if(chosenSide == 'left'){
      board.inBoardPieces.insert(0, chosenPiece) ;
      board.boardLeftValue = board.inBoardPieces[0].leftHalf.value ;
      player.pieces.remove(chosenPiece);
      print('board left: ${board.boardLeftValue} - board right: ${board.boardRightValue}' );
      showBoardPieces();
      changePlayerTurn(player);
     
    }else{
      board.inBoardPieces.add(chosenPiece);
      board.boardRightValue = board.inBoardPieces[board.inBoardPieces.length-1].rightHalf.value ;
      print('board left: ${board.boardLeftValue} - board right: ${board.boardRightValue}' );
      player.pieces.remove(chosenPiece);
       showBoardPieces();
      changePlayerTurn(player);
    }
     
     
  }

  void showBoardPieces(){
    for(DomPiece piece in board.inBoardPieces){
      print(piece.iD);
    }
  }

  void pullFromOutBoardList(DomPlayer player){
    player.pieces.add(board.outBoardPieces[0]);
    print('You pulled : ${player.pieces[player.pieces.length-1].iD}');
    getAvailablePlays(player);
  }
}
/*
void checkForAvailablePlays(DomPlayer player){
    print('Pick A Piece') ;
    String? pickedPieceId = stdin.readLineSync();
    for(DomPiece piece in player.pieces){
      if(piece.iD == pickedPieceId){
        choosenPiece = piece;
         
      }
    }
    if(choosenPiece.left.value == board.boardLeftValue || choosenPiece.right.value == board.boardLeftValue){
     // leftIsOpen = true;
      playingChoices['left'] = true ;
      print('Left: ${board.boardLeftValue} is avialble') ;
    }else {
      playingChoices['left'] = false ;
    }
    if(choosenPiece.left.value == board.boardRightValue || choosenPiece.right.value == board.boardRightValue){
      playingChoices['rigth'] = true ;
      print('Rigth: ${board.boardRightValue} is avialble') ;
    }else{
       playingChoices['rigth'] = false;
    }

    if(playingChoices['left'] == false && playingChoices['rigth'] == false){
      print('Can not play this piece pls choose another one');
      print('Pull From OutBoardList ? write y if u want and n for picking another piece from your list ') ;
      String ? userAnswer = stdin.readLineSync();
      if(userAnswer == 'y'){
        pullFromOutBoardList(player);
      }else{
        checkForAvailablePlays(player);
      }
       
    }
    pickPlaySide();
    play(player);
  }
*/

*/
