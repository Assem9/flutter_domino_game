

import 'package:domino_game/data/models/player.dart';

import 'board.dart';
import 'match_enums.dart';

class DominoMatch{
  late String iD ;
  late MatchState state ;
  late MatchMode mode ;
  late bool isOnline ;
  late DomPlayer playerOne ;
  late DomPlayer playerTwo ;
  late Board dominoBoard ;

  DominoMatch({
    required this.iD,
    required this.state ,
    required this.mode,
    required this.isOnline,
    required this.playerOne,
    required this.playerTwo,
    required this.dominoBoard
  });

  DominoMatch.fromJson(Map<String,dynamic> json){
    iD = json['iD'];
    state = StateX.fromDbCode(json['state']);
    mode = ModeX.fromJson(json['mode']);
    isOnline = json['isOnline'];
    playerOne = DomPlayer.fromJson(json['playerOne']) ;
    playerTwo = DomPlayer.fromJson(json['playerTwo']) ; //json['playerTwo'];
    dominoBoard = Board.fromJson(json['dominoBoard']);//json['dominoBoard'];
  }

  Map<String, dynamic> toMap(){
    return {
      'iD': iD,
      'state':state.toJson(),
      'mode': mode.toJson(),
      'isOnline': isOnline,
      'playerOne': playerOne.toMap(),
      'playerTwo': playerTwo.toMap(),
      'dominoBoard': dominoBoard.toMap(),
    };
  }

}
