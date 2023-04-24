import 'package:domino_game/cubits/game_cubit/game_cubit.dart';
import 'package:domino_game/cubits/game_cubit/game_states.dart';
import 'package:domino_game/presentation/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/strings.dart';

class OnlineMatchDataLoadingScreen extends StatelessWidget {
  const OnlineMatchDataLoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit,GameStates>(
      listener: (context ,state){
        if(state is MatchLoaded){
          Navigator.of(context).pushNamedAndRemoveUntil(onlineMatchScreen, (route) => false);
        }
      },
      builder: (context ,state){
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Loading your match data',style: Theme.of(context).textTheme.bodyLarge,),
                  const SizedBox(height: 30,),
                  const AppLoader(title: 'Loading',)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
