import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domino_game/cubits/game_cubit/game_cubit.dart';
import 'package:domino_game/cubits/game_cubit/game_states.dart';
import 'package:domino_game/presentation/widgets/app_life_cycle.dart';
import 'package:domino_game/presentation/widgets/board_with_darg_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:lottie/lottie.dart';
import '../../constants/constants.dart';
import '../../constants/strings.dart';
import '../../data/models/match_enums.dart';
import '../widgets/disconnected_widget.dart';
import '../widgets/round_over_widget.dart';

class OnlineMatchScreen extends StatelessWidget {
  const OnlineMatchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OfflineBuilder(
        connectivityBuilder: (BuildContext context, ConnectivityResult connectivity, Widget child,) {
          final bool connected = connectivity != ConnectivityResult.none;
          if(connected){
            return _buildOnlineMatchScreen(context);
          }else{
            return const DisconnectedWidget();
          }
        },
        child: const Text(''),
      ),
    );
  }

  Widget _buildOnlineMatchScreen(context){
    return StreamBuilder(
        stream: FirebaseFirestore
            .instance
            .collection('matches')
            .doc(GameCubit.get(context).onlineMatch.iD)
            .snapshots(),
        builder: (context, snapshot) {
          GameCubit.get(context).streamMatchData(snapshot);
          return BlocConsumer<GameCubit,GameStates>(
            listener: (context ,state)async{
              var gameCubit  = GameCubit.get(context);
              if(state is FoundWinner && gameCubit.onlineMatch.mode == MatchMode.FULLMATCH && gameCubit.onlineMatch.state != MatchState.GAMEOVER){
                //
                if(state.winner.iD == uId) {
                  await Future.delayed(
                    const Duration(seconds: 7),
                        ()=> gameCubit.initializeNextRound(gameCubit.onlineMatch),
                  );
                }
              }

            },
            builder: (context ,state){
              var gameCubit = GameCubit.get(context);
              return SafeArea(
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    const LifeCycle(inMatch: true) ,
                    BoardWithDragTargetWidget(
                      match: gameCubit.onlineMatch,
                      screenSettings: gameCubit.matchScreenSettings,
                    ),
                    state is FoundWinner
                        ? OverMessageWidget(
                        match: gameCubit.onlineMatch,
                        loser: state.loser,
                        winner: state.winner
                    )
                        : Container(),

                    state is FoundWinner ?
                    Align(
                      alignment: state.winner.iD == gameCubit.onlineMatch.playerOne.iD
                          ? AlignmentDirectional.topStart
                          : AlignmentDirectional.topEnd,
                      child: SizedBox(
                        height: 155,
                        width: 155,
                        child: Lottie.network(
                            'https://assets4.lottiefiles.com/packages/lf20_a8czjo3v.json'
                        ),
                      ),
                    ) : Container(),
                  ],
                ),
              );
            },

          );
        }
    );
  }


}
