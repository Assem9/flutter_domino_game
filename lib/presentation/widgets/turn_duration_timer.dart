import 'dart:async';
import 'package:domino_game/constants/my_colors.dart';
import 'package:domino_game/cubits/game_cubit/game_cubit.dart';
import 'package:flutter/material.dart';

class PlayerTurnDuration extends StatefulWidget {
  const PlayerTurnDuration({Key? key}) : super(key: key);

  @override
  State<PlayerTurnDuration> createState() => _PlayerTurnDurationState();
}

class _PlayerTurnDurationState extends State<PlayerTurnDuration> {
  Duration turnDuration = const Duration(seconds: 110);
  Timer? awayCountDownTimer ;
  bool closeToEnd = false;
  void startTurnTimer(){
    GameCubit.get(context).awayTimerStopped = false;
    closeToEnd = false;
    turnDuration = const Duration(seconds: 110);
    awayCountDownTimer = Timer.periodic(const Duration(seconds: 1), (timer)=> countDownTurnDuration());
  }

  void stopTurnTimer(){
    awayCountDownTimer!.cancel();
  }

  void countDownTurnDuration(){
    const reduceSecondsBy = 1 ;
    int seconds =  turnDuration.inSeconds - reduceSecondsBy ;
    if(seconds < 0){
      GameCubit.get(context).checkIfPlayingDurationEnded(GameCubit.get(context).onlineMatch);
      awayCountDownTimer!.cancel();
    }else{
      setState(() {
        if(turnDuration.inSeconds < 20){
          closeToEnd = true ;
        }
        turnDuration = Duration(seconds: seconds);
        debugPrint(turnDuration.inSeconds.toString());
      });

    }
  }

  @override
  void initState() {
    startTurnTimer() ;
    super.initState();
  }

  @override
  void dispose() {
    stopTurnTimer() ;
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return !closeToEnd
        ? _buildPlayerTurnDurationCounter()
        : _buildDurationCloseToEndMessage();

  }

  Widget _buildDurationCloseToEndMessage(){
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: MyColors.red1.withOpacity(0.5),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: MyColors.darkBlue)
      ),
      child: Text(
        'auto mode will start in ${turnDuration.inSeconds} sec' ,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildPlayerTurnDurationCounter(){
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: MyColors.lemon.withOpacity(0.5),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: MyColors.darkBlue)
      ),
      child: Text(
        '${turnDuration.inSeconds} sec' ,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

}
