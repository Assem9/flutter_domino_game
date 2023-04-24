import 'package:domino_game/data/models/player.dart';

abstract class GameStates {}

class InitialState extends GameStates{}

class OfflineMatchCreated extends GameStates{
  OfflineMatchCreated({required this.botGotP6_6});
  final bool botGotP6_6 ;
}

class OnlineMatchCreated extends GameStates{}

class OnlineMatchCreatingError extends GameStates{}

class OnlineMatchUpdated extends GameStates{}

class MatchLoaded extends GameStates{}

class MatchLoadingError extends GameStates{}

class OpponentPlayedPieceLoaded extends GameStates{}

class PlayerIsInAutoPlayStatus extends GameStates{}

class PlayerLeftMatch extends GameStates{}

class OnTurnPlayerLoaded extends GameStates{}

class OnTurnPlayerChanged extends GameStates{}

class MatchUpdated extends GameStates{}

class MatchUpdatingError extends GameStates{}

class FoundWinner extends GameStates{
  final  DomPlayer loser;
  final  DomPlayer winner;
 // final int roundPoints ;
  FoundWinner({required this.loser,required this.winner});
}

class PlayerPulledNewPiece extends GameStates{}

class BotPlayed extends GameStates{}

class NewRoundInitialized extends GameStates{
  NewRoundInitialized({this.winnerFromLastIsBot});
  final bool? winnerFromLastIsBot ;
}

class TimeCountDownWorking extends GameStates {}

class CancelingCubitState extends GameStates {}

class OutBoardListIsShown extends GameStates {}





