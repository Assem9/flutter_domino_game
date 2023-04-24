import 'dart:math';
import 'package:domino_game/data/models/player.dart';
import 'package:flutter/cupertino.dart';
import 'board.dart';
import 'dom_piece.dart';

class BotPlayer extends DomPlayer{

  List<DomPiece> availablePieces = [];

  BotPlayer({
    required super.name,
    required super.iD,
    required super.email,
    required super.photoUrl,
    required super.friendsIds,
    required super.status
  });

  bool checkIfPieceCanBePlayed(DomPiece piece, Board board){
    if(piece.leftHalf.value == board.leftTarget || piece.leftHalf.value == board.rightTarget){
      return true ;
    }
    else if(piece.rightHalf.value == board.leftTarget || piece.rightHalf.value == board.rightTarget){
      return true ;
    }
    return false ;
  }

  void getAllAvailablePieces(Board board){
    availablePieces = [];
    for(var piece in pieces){
      if(checkIfPieceCanBePlayed(piece, board)){
        availablePieces.add(piece);
      }
    }
    debugPrint(availablePieces.length.toString());
  }

  DomPiece pickPieceToPlay(){
    debugPrint(availablePieces.length.toString());
    final random = Random();
    //int index = random.nextInt(availablePieces.length-1);
    return availablePieces[0];
  }

}