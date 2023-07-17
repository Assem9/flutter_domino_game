import 'package:domino_game/constants/strings.dart';
import 'package:domino_game/cubits/game_cubit/game_cubit.dart';
import 'package:domino_game/cubits/game_cubit/game_states.dart';
import 'package:domino_game/data/models/match_enums.dart';
import 'package:domino_game/presentation/widgets/board_with_darg_target.dart';
import 'package:domino_game/presentation/widgets/round_over_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../constants/constants.dart';
import '../../constants/my_colors.dart';
import '../widgets/app_life_cycle.dart';

class OfflineMatchScreen extends StatelessWidget {
  const OfflineMatchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<GameCubit,GameStates>(
        listener: (context, state)async{
          var cubit  = GameCubit.get(context);
          if(state is FoundWinner &&
              cubit.offlineMatch.mode == MatchMode.FULLMATCH &&
              cubit.offlineMatch.state != MatchState.GAMEOVER){
            await Future.delayed(
              const Duration(seconds: 5),
              ()=> cubit.initializeNextRound(cubit.offlineMatch),
            );
          }

          if(state is NewRoundInitialized){
            if(state.winnerFromLastIsBot!){
              await Future.delayed(
                const Duration(milliseconds: 2250),
                    ()=> cubit.dominoBotPlays(bot: cubit.botPlayer, match: cubit.offlineMatch)
              );
            }
          }

        },
        builder: (context, state){
          var gameCubit = GameCubit.get(context) ;
          return SafeArea(
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                uId !=null
                    ? const LifeCycle(inMatch: true)
                    : Container() ,
                Container(
                  decoration:  BoxDecoration(
                    color: MyColors.sky,
                    border: Border.all(width: 4,color: MyColors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                BoardWithDragTargetWidget(
                  match: gameCubit.offlineMatch,
                  screenSettings: gameCubit.matchScreenSettings,
                ),
                state is FoundWinner
                    ? OverMessageWidget(
                    match: gameCubit.offlineMatch,
                    loser: state.loser,
                    winner: state.winner
                )
                    : Container(),

                state is FoundWinner
                    ? Align(
                  alignment: state.winner.iD == gameCubit.offlineMatch.playerOne.iD
                      ? AlignmentDirectional.topStart
                      : AlignmentDirectional.topEnd,
                  child: SizedBox(
                    height: 155,
                    width: 155,
                    child: Lottie.network(
                        'https://assets4.lottiefiles.com/packages/lf20_a8czjo3v.json'
                    ),
                  ),
                )
                    : Container(),


                /*Container(
                  alignment: AlignmentDirectional.topEnd,
                  child: DefaultButton(
                      title: 'title',
                      onTap: ()=> GameCubit.get(context).testFunc()
                  ),
                )*/
              ],
            ),
          );
        },
      ),
    );
  }





}
