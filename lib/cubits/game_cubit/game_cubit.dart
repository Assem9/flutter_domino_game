import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domino_game/constants/components.dart';
import 'package:domino_game/data/firestore_services/match_firebase_services.dart';
import 'package:domino_game/data/firestore_services/user_firebase_services.dart';
import 'package:domino_game/data/models/board.dart';
import 'package:domino_game/data/models/board_target.dart';
import 'package:domino_game/data/models/bot_player.dart';
import 'package:domino_game/data/models/match_request.dart';
import 'package:domino_game/data/models/match_screen_settings.dart';
import 'package:domino_game/data/repository/match_repository.dart';
import 'package:domino_game/data/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/constants.dart';
import '../../constants/strings.dart';
import '../../data/models/dom_piece.dart';
import '../../data/models/match.dart';
import '../../data/models/match_enums.dart';
import '../../data/models/player.dart';
import '../../data/models/user.dart';
import 'game_states.dart';

class GameCubit extends Cubit<GameStates> {
  GameCubit(this.matchRepository): super(InitialState());
  static GameCubit get(context) => BlocProvider.of(context);
  final MatchRepository matchRepository ;

  void testFunc(){
    // print('${offlineMatch.dominoBoard.listA.listHeight}');
    emit(NewRoundInitialized(winnerFromLastIsBot: false));
  }

  DomPlayer? findMyPlayer(DominoMatch match){
    for(var player in [match.playerTwo,match.playerOne]){
      if(player.iD == uId || player.iD == 'fakeUser'){
        return player ;
      }
    }
    return null ;
  }
  ///////////////////////////////////////// player life cycle //////////////////////////////////

  bool awayTimerStopped = false;
  void autoPlay({
    required DomPlayer player,
    required DominoMatch match
  }){
    // if user is away create autoPlayer that can use the bot functions to play auto
   //if(player.status != UserStatus.leftMatch){
      BotPlayer autoPlayer = matchRepository.createBotPlayer(player) ;
      dominoBotPlays(bot: autoPlayer, match: match) ;
      player.status = UserStatus.inMatch ;
      updateMatchInFireStore(match);
  //  }

  }

  void checkIfPlayingDurationEnded(DominoMatch match)async{
    DomPlayer player = onTurnPlayer(match);
    // check if player is away =>tell opponents its afk
    //else below code
    player.status = UserStatus.autoPlay ;
    emit(PlayerIsInAutoPlayStatus());
    if(uId != player.iD){
      await Future.delayed(
          const Duration(seconds: 7),
          ()=> autoPlay(player:player, match: match)
      ) ;
    }
  }

  /////////////

  void initializeNextRound(DominoMatch match){
    initScreenSettings(width: matchScreenSettings.screenWidth, height: matchScreenSettings.screenHeight) ;
    match = matchRepository.reInitializeBoardDataForTheNewRound(match: match);
    matchScreenSettings.leftTarget.value = matchScreenSettings.rightTarget.value = match.dominoBoard.leftTarget ;
    initAllSevenInCase(match) ;

    if(!match.isOnline){
      botPlayer = matchRepository.createBotPlayer(offlineMatch.playerTwo) ;
      emit(NewRoundInitialized(winnerFromLastIsBot: botPlayer.isPlaying));
    }else{
      updateMatchInFireStore(match);
      emit(NewRoundInitialized());
    }

  }

/////////////////////////////////////////////// offline ///////////////////////////////////////////////

  late BotPlayer botPlayer ;
  late DominoMatch offlineMatch ;
  void createOfflineMatch(AppUser user)async{
    offlineMatch = matchRepository.createOfflineMatch(me: user, mode: MatchMode.FULLMATCH,);
    matchScreenSettings.leftTarget.value = matchScreenSettings.rightTarget.value = offlineMatch.dominoBoard.leftTarget ;
    initAllSevenInCase(offlineMatch) ;
    debugPrint(offlineMatch.iD);
    myPlayer = findMyPlayer(offlineMatch)!;
    botPlayer = matchRepository.createBotPlayer(offlineMatch.playerTwo) ;
    await Future.delayed(
        const Duration(seconds: 1),
            ()=> emit(OfflineMatchCreated(botGotP6_6: botPlayer.isPlaying))
    );

  }

/////////////////////////////////////////////// online match ///////////////////////////////////////////////

  late DomPlayer myPlayer ;
  late DominoMatch onlineMatch ;
  void createPublicOnlineOneVsOneMatch({
    required AppUser me,
    required AppUser opponent,
    required MatchRequest request,
}){
    matchRepository.createOnlineMatch(
        me: me,
        opponent: opponent,
    ).then((value) {
      UserRepository(UserFireBaseServices()).addMatchIdToCreatedRequest(
          request: request,
          matchId: value.iD
      );
      onlineMatch = value ;
      matchScreenSettings.leftTarget.value = matchScreenSettings.rightTarget.value = onlineMatch.dominoBoard.leftTarget ;
      // if im the creator so im playerone
      initAllSevenInCase(onlineMatch);
      myPlayer = findMyPlayer(onlineMatch)!;

      emit(OnlineMatchCreated());
    }).catchError((e){
      debugPrint('$e');
      emit(OnlineMatchCreatingError());
    });
  }

  void createFriendsOnlineOneVsOneMatch({
    required AppUser me,
    required AppUser opponent,
    required FriendMatchRequest request,
  }){
    matchRepository.createOnlineMatch(
      me: me,
      opponent: opponent,
    ).then((value) {
      UserRepository(UserFireBaseServices()).addMatchIdToFriendMatchRequest(
          request: request,
          matchId: value.iD
      );
      onlineMatch = value ;
      matchScreenSettings.leftTarget.value = matchScreenSettings.rightTarget.value = onlineMatch.dominoBoard.leftTarget ;

      initAllSevenInCase(onlineMatch);
      myPlayer = findMyPlayer(onlineMatch)!;

      emit(OnlineMatchCreated());
    }).catchError((e){
      debugPrint('$e');
      emit(OnlineMatchCreatingError());
    });
  }
  void getOnlineMatchData(id){
    MatchRepository(MatchFirebaseServices()).getMatchData(id).then((value){
      onlineMatch = value ;
      myPlayer = findMyPlayer(onlineMatch)!;
      initAllSevenInCase(onlineMatch); // there were error here *****
      emit(MatchLoaded());
    }).catchError((e){
      debugPrint('loading march error $e');
      emit(MatchLoadingError());
    });
  }

  void streamMatchData(AsyncSnapshot<DocumentSnapshot> snapshot){
    if (snapshot.hasError) {
     debugPrint('Something went wrong');
    }else if(snapshot.hasData){
      debugPrint('hasData');
      onlineMatch = DominoMatch.fromJson(snapshot.data!.data()! as Map<String, dynamic>);
      myPlayer = findMyPlayer(onlineMatch)!;
      if(onlineMatch.state == MatchState.ONGOING){
        if(onTurnPlayer(onlineMatch).iD == myPlayer.iD && onlineMatch.dominoBoard.inBoardPieces.isNotEmpty){
          findWhereOpponentPlaceHisPiece(onlineMatch);
        }
      }
      streamOnMatchStates(onlineMatch);
      listenOnOpponentLeftMatchCase() ;
    }

  }

  void streamOnMatchStates(DominoMatch match){
    //
    if(myPlayer.pieces.isNotEmpty){
      if(match.state == MatchState.PAUSED || match.state == MatchState.GAMEOVER ){
        debugPrint('checking match state');
        DomPlayer winner ;
        if(match.playerOne.iD != myPlayer.iD){
          winner = match.playerOne ;
        }else{
          winner = match.playerTwo ;
        }
        winnerChecker(player: winner, match: match);

        if(match.state == MatchState.PAUSED){
          initScreenSettings(width: matchScreenSettings.screenWidth, height: matchScreenSettings.screenHeight) ;
        }
      }
    }

  }

  void playerQuitMatch(DominoMatch match){
    myPlayer.status = UserStatus.leftMatch ;
    myPlayer.isPlaying = false ;
    updateMatchInFireStore(match);
    UserFireBaseServices().updateUserStatus(status: 'online');
    emit(PlayerLeftMatch());
  }

  void listenOnOpponentLeftMatchCase()async{
    DomPlayer opponent ;
    if(onlineMatch.playerOne.iD != uId){
      opponent = onlineMatch.playerOne  ;
    }else{
      opponent = onlineMatch.playerTwo ;
    }
    if(opponent.status == UserStatus.leftMatch){
      onlineMatch.state = MatchState.GAMEOVER ;
      myPlayer.pieces = [];
      showToast(message: '${opponent.name} has surrendered' );
      await Future.delayed(
          const Duration(seconds: 2),
              ()=> emit(FoundWinner(loser: opponent, winner: myPlayer))
      )  ;
    }

  }

  ///////////////////////////////// screen settings //////////////
  late MatchScreenSettings matchScreenSettings ;
  void initScreenSettings({
    required double width,
    required double height
  }){
    matchScreenSettings = MatchScreenSettings(width: width, height: height) ;
    matchScreenSettings.setPieceHeight() ;
    matchScreenSettings.initializedTargets() ;
    debugPrint('piece height: ${matchScreenSettings.pieceHeight}');
  }

  void findWhereOpponentPlaceHisPiece(DominoMatch match){
    if(matchScreenSettings.firstPiece.iD != match.dominoBoard.inBoardPieces.first.iD){
      debugPrint('add left');
      matchScreenSettings.addPieceToLeftTarget(
          match: match,
          draggedPiece: match.dominoBoard.inBoardPieces.first
      );
      moveTarget(matchScreenSettings.leftTarget,match) ;
      emit(OpponentPlayedPieceLoaded());
    }else if(matchScreenSettings.lastPiece.iD != match.dominoBoard.inBoardPieces.last.iD){
      debugPrint('add right');
       matchScreenSettings.addPieceToRightTarget(
           match: match,
           draggedPiece: match.dominoBoard.inBoardPieces.last
       );
      moveTarget(matchScreenSettings.rightTarget,match) ;
      emit(OpponentPlayedPieceLoaded());
    }

    if(match.dominoBoard.inBoardPieces.length == 1){
      matchScreenSettings.firstPiece = matchScreenSettings.lastPiece = onlineMatch.dominoBoard.inBoardPieces[0] ;
    }

  }

  void moveTarget(BoardTarget target,DominoMatch match){
    // if listA is Open both targets moves the same
    if(target.mode == ListsOpenMode.lsitA_isOpen){
      matchScreenSettings.rightTarget.move(matchScreenSettings,match);
      matchScreenSettings.leftTarget.move(matchScreenSettings,match);
    }else{
      target.move(matchScreenSettings,match);
    }
  }

/////////////////////////////////////////// play piece  code ////////////////////////////////////////////////

  void playOnLeftTarget({
    required DominoMatch match,
    required DomPiece draggedPiece,
  }){
    debugPrint('${draggedPiece.iD}');
    DomPlayer player = onTurnPlayer(match);
    // insert in match object list
    match.dominoBoard.inBoardPieces.insert(0, draggedPiece) ;
    match.dominoBoard.leftTarget = match.dominoBoard.inBoardPieces[0].leftHalf.value ;

    player.pieces.remove(draggedPiece);
    //updateMatchInFireStore(match);

    // insert in UI list
    matchScreenSettings.addPieceToLeftTarget(match: match, draggedPiece: draggedPiece) ;
    moveTarget(matchScreenSettings.leftTarget,match);

    winnerChecker(player: player, match: match);

  }

  void playOnRightTarget({
    required DominoMatch match,
    required DomPiece draggedPiece,
  }){
    debugPrint('${draggedPiece.iD}');
    DomPlayer player = onTurnPlayer(match);
    match.dominoBoard.inBoardPieces.add(draggedPiece);
    match.dominoBoard.rightTarget =
        match.dominoBoard.inBoardPieces[match.dominoBoard.inBoardPieces.length-1].rightHalf.value ;

    player.pieces.remove(draggedPiece);
    //updateMatchInFireStore(match);

    matchScreenSettings.addPieceToRightTarget(match: match, draggedPiece: draggedPiece) ;
    moveTarget(matchScreenSettings.rightTarget,match);

    winnerChecker(player: player, match: match);

  }

  void dragPieceInLeftTarget({
    required DominoMatch match,
    required DomPiece draggedPiece,
  }){
    // add this in determine()
    // check if its first play in after ( round 1 ) winner can add any piece
    if(match.dominoBoard.inBoardPieces.isNotEmpty ){
      if(draggedPiece.leftHalf.value == match.dominoBoard.leftTarget){
        draggedPiece.reshapeDom();
        playOnLeftTarget(
          match: match,
          draggedPiece: draggedPiece,
        );
      }else if(draggedPiece.rightHalf.value == match.dominoBoard.leftTarget){
        playOnLeftTarget(
          match: match,
          draggedPiece: draggedPiece,
        );
        // add to board ;
      }else{
        showToast(message: 'can not play this');
      }
    }
    else{
       firstPlayInRound(piece: draggedPiece, match: match) ;
       //firstPlayInRoundAfterFirstRound(piece: draggedPiece, match: match);
    }

  }

  void dragPieceInRightTarget({
    required DominoMatch match,
    required DomPiece draggedPiece,
  }){
    if(draggedPiece.leftHalf.value == match.dominoBoard.rightTarget){
      playOnRightTarget(
        match: match,
        draggedPiece: draggedPiece,
      );
    }else if(draggedPiece.rightHalf.value == match.dominoBoard.rightTarget){
      draggedPiece.reshapeDom();
      playOnRightTarget(
        match: match,
        draggedPiece: draggedPiece,
      );
      // add to board ;
    }else{
      showToast(message: 'can not play this');
    }

  }

  void firstPlayInRound({
    required DomPiece piece,
    required DominoMatch match,
  }){
    // if it first play in round after first round
    if(match.dominoBoard.leftTarget == null && match.dominoBoard.rightTarget == null){
      matchScreenSettings.rightTarget.value = match.dominoBoard.rightTarget = piece.rightHalf.value ;
      debugPrint('target val ${matchScreenSettings.rightTarget.value}');
      playOnLeftTarget(
        match: match,
        draggedPiece: piece,
      );
    }
    // if it first play in the first round (must be p6_6)
    else if(piece.iD == 'p6_6'){
      matchScreenSettings.lastPiece.iD = 'p6_6' ;
      playOnLeftTarget(match: match, draggedPiece: piece) ;
    }else if(matchScreenSettings.leftTarget.value == 6){
      showToast(message: 'Must Start With [6][6]') ;
    }
  }


  ////////////////////////////////// game play code ////////////////////////////////////////////

  DomPlayer onTurnPlayer(DominoMatch match){
    if(match.playerOne.isPlaying){
      return match.playerOne ;
    }else{
      return match.playerTwo ;
    }
  }

  void changePlayerTurn({required DomPlayer player,required DominoMatch match}){
    debugPrint('changePlayerTurn');
    if(player.iD == match.playerOne.iD){
      match.playerOne.isPlaying = false ;
      match.playerTwo.isPlaying = true ;
      debugPrint('Now Turn For ${match.playerTwo.name}');
    }else{
      match.playerTwo.isPlaying = false ;
      match.playerOne.isPlaying = true ;
      debugPrint('Now Turn For  ${match.playerOne.name}');
    }
    emit( OnTurnPlayerChanged());
    updateMatchInFireStore(match);
  }

  int roundPoints = 0 ;
  void calculateScore({
    required DomPlayer winner,
    required DominoMatch match,
    required DomPlayer loser ,
  }){
    // for onlineMatch just winner use this function
    if(winner.iD == uId || !match.isOnline){
      roundPoints = 0 ;
      for(DomPiece piece in loser.pieces ){
        roundPoints += ( piece.rightHalf.value + piece.leftHalf.value );
        debugPrint('roundPoints $roundPoints');
      }
      winner.score += roundPoints ;
      updateMatchInFireStore(match);
      debugPrint('score ${winner.score}');
      if(winner.score >= 101){
        match.state = MatchState.GAMEOVER ;
        debugPrint('Game Over winner is: ${winner.name}');
      }
    }

  }

  void changeMatchStateWhenFoundWinner(DominoMatch match,DomPlayer winner){
    // (in online )just winner update match state
    if(winner.iD == uId || !match.isOnline){
      if(match.mode == MatchMode.ROUND ){
        match.state = MatchState.GAMEOVER ;
        winner.isPlaying = false ;
      }else{
        //FULLMATCH
        match.state = MatchState.PAUSED ;
      }
      updateMatchInFireStore(match);
    }

  }

  // if player already played all his dominoes list so he won the round
  // mode: full match => pause game until create new match for the second round
  // mode: one round match => Game is Over
  void winnerChecker({required DomPlayer player, required DominoMatch match}){
    if(player.pieces.isEmpty){
     // player.isPlaying = false ;
      changeMatchStateWhenFoundWinner(match,player);
      DomPlayer loser ;
      if(match.playerOne.iD != player.iD ){
        loser = match.playerOne ;
      }else{
        loser = match.playerTwo ;
      }
      calculateScore(winner: player, match: match, loser: loser);
      emit(FoundWinner(loser: loser, winner: player));
    }else{
      // if no winner give turn to the opponent
      changePlayerTurn( player: player, match: match);
    }

  }

  bool checkIfPlayerHasAvailablePieceToPlay({
    required Board board,
    required DomPlayer player
  }){
    for(var piece in player.pieces){
      if(piece.leftHalf.value == board.leftTarget || piece.leftHalf.value == board.rightTarget){
        return true ;
      }
      else if(piece.rightHalf.value == board.leftTarget || piece.rightHalf.value == board.rightTarget){
        return true ;
      }
    }
    return false ;
  }


  bool playerPulledPiece = false ;
  void pullFromOutBoardList({
    required DominoMatch match,
  })async{
    var player = onTurnPlayer(match);
    bool canPlay = checkIfPlayerHasAvailablePieceToPlay(board: match.dominoBoard, player: player) ;
    if(canPlay){
      isOutBoardListShown = false ;

      emit(OutBoardListIsShown()) ;
      if(!playerPulledPiece){
        showToast(message: 'you have available piece to play');
      }
    }else{
      showOutBoardList();
      playerPulledPiece = false ;
      if(pulled(match, player)){
        playerPulledPiece = true ;
        await Future.delayed(
          const Duration(milliseconds: 500),
          ()=> pullFromOutBoardList(match: match),
        );

      }
    }

  }

  bool isOutBoardListShown = false ;
  void showOutBoardList(){
    isOutBoardListShown = true ;
    emit(OutBoardListIsShown()) ;
  }


  //////////// bot

  bool isFirstPlayInRound = false ;
  void checkIfBotIsTakingTheFirstPlayInRound({
    required BotPlayer bot,
    required DominoMatch match
  }){
    // if bot plays first(in new round) he add the first piece in his list to the availablePieces
    // else go get all available pieces for both targets
    if(match.dominoBoard.inBoardPieces.isEmpty ) {
      bot.availablePieces.add(bot.pieces.first)  ;
      isFirstPlayInRound = true ;
      //matchScreenSettings.rightTarget.value = offlineMatch.dominoBoard.rightTarget = botPlayer.pieces.first.rightHalf.value  ;
    }else{
      bot.getAllAvailablePieces(match.dominoBoard);
      isFirstPlayInRound = false ;
    }

  }

  bool pulled(DominoMatch match, DomPlayer player ){
    if(match.dominoBoard.outBoardPieces.isEmpty){
      isOutBoardListShown = false ;
      playerPulledPiece = false ;
      allSevenValuesIIsPlayed.addAll({player.iD: true,'outBoardList':true}) ;
      if(checkAllSevenValuesIsPlayedCase(match)){
        calculateCaseScores(match);
      }else{
        changePlayerTurn(player: player, match: match) ;
      }

      return false ;
    }else{
      var pulledPiece = match.dominoBoard.outBoardPieces[0];
      player.pieces.add(pulledPiece);
      match.dominoBoard.outBoardPieces.remove(pulledPiece);
      emit(PlayerPulledNewPiece());
      debugPrint('You pulled : ${player.pieces.last.iD}');
      return true ;

    }
  }

  void checkIfBotNeedToPull({
    required BotPlayer bot,
    required DominoMatch match
  }){
    debugPrint('bot is pulling') ;
    if(pulled(match, bot)){
      if(bot.checkIfPieceCanBePlayed(bot.pieces.last, match.dominoBoard)){
        bot.availablePieces.add(bot.pieces.last) ;
      }else{
        checkIfBotNeedToPull(bot: bot, match: match) ;
      }
    }
  }

  void dominoBotPlays({
    required BotPlayer bot,
    required DominoMatch match
  }){
    debugPrint('bot is playing');
    DomPiece pickedPiece ;
    checkIfBotIsTakingTheFirstPlayInRound(bot: bot, match: match) ;
    if(isFirstPlayInRound){
      pickedPiece = bot.availablePieces[0];
      dragPieceInLeftTarget(match: match, draggedPiece: pickedPiece);
    }else{
      if(bot.availablePieces.isEmpty){
        // check pull and fill in availablePieces list
        checkIfBotNeedToPull(bot: bot, match: match) ;
      }
      if(bot.availablePieces.isNotEmpty){
        pickedPiece =  bot.pickPieceToPlay();
        if(match.dominoBoard.leftTarget == pickedPiece.leftHalf.value
            || match.dominoBoard.leftTarget == pickedPiece.rightHalf.value){
          dragPieceInLeftTarget(match: match, draggedPiece: pickedPiece) ;
        }else{
          dragPieceInRightTarget(match: match, draggedPiece: pickedPiece);
        }

      }
    }

  }

  ///////////////////////////////////////// allSevenIn Case ///////////////////////////////////////////////
  // each number in the game exists in different 7 pieces
  // allSevenValuesIsPlayedCase is when all pieces that have targets value is already played
  // so both players and outList cant play
  // game pause and calculate both player pieces values to find the winner

  bool allSevenIn = false;
  Map<String,bool> allSevenValuesIIsPlayed = {};

  void initAllSevenInCase(DominoMatch match){
    allSevenIn = false;
    for(var id in [match.playerOne.iD,match.playerTwo.iD,'outBoardList']){
      allSevenValuesIIsPlayed.addAll({id:false}) ;
    }
  }

  bool checkAllSevenValuesIsPlayedCase(DominoMatch match){
    for(var id in [match.playerOne.iD,match.playerTwo.iD,'outBoardList']){
      debugPrint(allSevenValuesIIsPlayed.values.toString());
      if(allSevenValuesIIsPlayed[id]! == false){
        return false ;
      }
    }
    return true ;
  }

  void calculateCaseScores(DominoMatch match){
    debugPrint('findCaseWinner');
    List<int> scores =[];
    for(var player in [match.playerOne,match.playerTwo]){
      int score =0;
      for(var piece in player.pieces){
        score += ( piece.rightHalf.value + piece.leftHalf.value );
      }
      scores.add(score);
    }
    allSevenIn = true;
    findCaseWinner(match: match, scores: scores) ;
    ////
    /*
    await Future.delayed(
        const Duration(seconds: 2),
            ()=> findCaseWinner(match: match, scores: scores)
    ) ;
*/
  }

  void findCaseWinner({
    required DominoMatch match ,
    required List<int> scores ,
  }){
    if(scores[0] < scores[1]){
      //playerOne Is Winner
      changeMatchStateWhenFoundWinner(match,match.playerOne);
      calculateScore(winner: match.playerOne, match: match, loser: match.playerTwo) ;
      emit(FoundWinner(loser: match.playerTwo, winner: match.playerOne));
    }else if(scores[0] > scores[1]){
      //playerTwo Is Winner
      changeMatchStateWhenFoundWinner(match,match.playerTwo);
      calculateScore(winner: match.playerTwo, match: match, loser: match.playerOne) ;
      emit(FoundWinner(loser: match.playerOne, winner:  match.playerTwo));
    }else{
      // case both are equals
      initializeNextRound(match);
    }
  }

  //////////////////////////////////////////////   ///////////////////////////////////////////////////

  void updateMatchInFireStore(DominoMatch match) async{
    if(match.isOnline){
      try{
        debugPrint('match updated');
        await MatchFirebaseServices().updateMatchFireStore(match: match);
        // emit(MatchUpdated());
      }catch(e){
        //   emit(MatchUpdatingError());
        debugPrint('$e');
      }
    }

  }
///////////////////////////

  bool showRoundOver = false ;
  bool showMatchOver = false ;
  void checkGameOverCases(DominoMatch match){
    showRoundOver = false ;
    showMatchOver = false ;
    // fullMatch ended
    if(match.state == MatchState.GAMEOVER && match.mode == MatchMode.FULLMATCH){
      showMatchOver = true ;
    }
    // one round mode ended
    else if(match.state == MatchState.GAMEOVER && match.mode == MatchMode.ROUND){
      showMatchOver = true ;
    }
    // one round ended in a fullMatchMode
    else if(match.state == MatchState.PAUSED && match.mode == MatchMode.FULLMATCH){
       showRoundOver = false ;
    }
  }

  void cancelState(){
    emit(CancelingCubitState()) ;
  }

}