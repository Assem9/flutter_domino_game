import 'dart:math';
import 'package:flutter/cupertino.dart';
import '../firestore_services/match_firebase_services.dart';
import '../models/board.dart';
import '../models/bot_player.dart';
import '../models/match.dart';
import '../models/match_enums.dart';
import '../models/player.dart';
import '../models/user.dart';

class MatchRepository{
  final MatchFirebaseServices matchFirebaseServices ;

  MatchRepository(this.matchFirebaseServices);

  String generateUniqueId(String text ){
    String month = DateTime.now().month.toString();
    String day = DateTime.now().day.toString();
    String hour = DateTime.now().hour.toString();
    String second = DateTime.now().second.toString();
    String id = text + month + day + hour + second;
    return id ;
  }

  void giveFirstPiece({
    required List<DomPlayer> players,
    required Board board
  }){
    int index = Random().nextInt(players.length);
    for(DomPlayer player in players){
      if(player == players[index]){
        player.pieces.add(board.outBoardPieces.last);
        board.outBoardPieces.remove(board.outBoardPieces.last);
        player.isPlaying = true ; // the first turn
      }else{
        int pieceIndex = Random().nextInt(board.outBoardPieces.length);
        player.pieces.add(board.outBoardPieces[pieceIndex]);
        board.outBoardPieces.remove(board.outBoardPieces[pieceIndex]);
      }
    }

  }

  void distributePieces({
    required DomPlayer player,
    required Board board,
    required noOfPiece
  }){
    int index = 0 ;
    final random = Random();
    for(int i= 0 ; i < noOfPiece ; i++){
      index = random.nextInt(board.outBoardPieces.length);
      // piece = board.outBoardPieces[index]
      player.pieces.add(board.outBoardPieces[index]) ;
      board.outBoardPieces.remove(board.outBoardPieces[index]) ;
      debugPrint(player.pieces.last.iD);
    }

  }

  BotPlayer createBotPlayer(DomPlayer player){
    BotPlayer botPlayer = BotPlayer(
        name: player.name,
        iD: player.iD,
        email: player.email,
        photoUrl: player.photoUrl,
        friendsIds: [],
        status: UserStatus.online
    );
    botPlayer.pieces = player.pieces ;
    botPlayer.isPlaying = player.isPlaying ;
    debugPrint(botPlayer.pieces .length.toString());
    return botPlayer ;
  }

  DominoMatch reInitializeBoardDataForTheNewRound({required DominoMatch match}){
    match.dominoBoard = Board() ;
    match.playerOne.pieces = [];
    match.playerTwo.pieces = [];
    distributePieces(player: match.playerOne, board: match.dominoBoard, noOfPiece: 12);
    distributePieces(player: match.playerTwo, board: match.dominoBoard, noOfPiece: 12);
    setFirstValues(match) ;
    match.state = MatchState.ONGOING ;
    return match ;
  }

  void takeTargetFirstValue(DominoMatch match ,int? value){
    match.dominoBoard.rightTarget = match.dominoBoard.leftTarget  =  value ;
  }

  void setFirstValues(DominoMatch match){
    switch(match.mode){
      case MatchMode.ROUND:
        takeTargetFirstValue(match, 6) ;
        break;
      case MatchMode.FULLMATCH:
      // first Round Must Start With p6_6
        if(match.playerOne.score == 0 && match.playerTwo.score == 0){
          takeTargetFirstValue(match, 6) ;

        }// next round will be whatever winner of previous round play
        else{
          takeTargetFirstValue(match, null)  ;
        }
        break;
      case MatchMode.ASHOKROUND:
      // TODO: Handle this case.
        break;
      case MatchMode.ASHOKFULLMATCH:
      // TODO: Handle this case.
        break;
    }
  }

  DominoMatch  createOfflineMatch({
    required AppUser me,
    required MatchMode mode ,
  }){
    DominoMatch offlineMatch = DominoMatch(
      iD: 'offlineMatch',
      mode: mode,
      state: MatchState.NOTREADY,
      isOnline: false,
      dominoBoard: Board(),
      playerOne: DomPlayer(
        name: me.name,
        iD: me.iD,
        email: me.email,
        photoUrl: me.photoUrl,
        status: me.status,
        friendsIds: [],
      ),
      playerTwo: DomPlayer(
        name: 'Domino Bot',
        iD: 'Domino Bot ID',
        email: 'Domino Bot Email',
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/domino-8023b.appspot.com/o/robot2.png?alt=media&token=6ae8801a-a214-435b-b02f-3c41af9f8479',
        friendsIds: [],
        status: UserStatus.online,
      ),
    ) ;
    giveFirstPiece(players: [offlineMatch.playerOne,offlineMatch.playerTwo], board: offlineMatch.dominoBoard);
    distributePieces(player: offlineMatch.playerOne, board: offlineMatch.dominoBoard, noOfPiece: 6);
    distributePieces(player: offlineMatch.playerTwo, board: offlineMatch.dominoBoard, noOfPiece: 6);
    setFirstValues(offlineMatch) ;
    offlineMatch.state = MatchState.ONGOING ;
    return offlineMatch ;
  }

  Future<DominoMatch> createOnlineMatch({
    required AppUser me ,
    required AppUser opponent,
  })async{
    DominoMatch onlineMatch = DominoMatch(
      iD: generateUniqueId('${me.email}vs${opponent.email}'),
      mode: MatchMode.FULLMATCH,
      state: MatchState.NOTREADY,
      isOnline: true,
      dominoBoard: Board(),
      playerOne: DomPlayer(
          name: me.name,
          iD: me.iD,
          email: me.email,
          photoUrl: me.photoUrl,
          friendsIds: me.friendsIds,
          status: me.status,
      ),
      playerTwo: DomPlayer(
          name: opponent.name,
          iD: opponent.iD,
          email: opponent.email,
          photoUrl: opponent.photoUrl,
          status: opponent.status,
          friendsIds: opponent.friendsIds
      ),
    ) ;
    giveFirstPiece(players: [onlineMatch.playerOne,onlineMatch.playerTwo], board: onlineMatch.dominoBoard);
    distributePieces(player: onlineMatch.playerOne, board: onlineMatch.dominoBoard, noOfPiece: 6);
    distributePieces(player: onlineMatch.playerTwo, board: onlineMatch.dominoBoard, noOfPiece: 6);
    setFirstValues(onlineMatch) ;
    onlineMatch.state = MatchState.ONGOING ;
    await matchFirebaseServices.addNewMatchFireStore(match: onlineMatch);
    return onlineMatch ;
  }


  Future<DominoMatch> getMatchData(String id)async{
    final user = await matchFirebaseServices.getMatchDocument(matchID: id);
    return DominoMatch.fromJson(user.data() as Map<String,dynamic>)  ;
  }


}