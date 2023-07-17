
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/my_colors.dart';
import '../../constants/strings.dart';
import '../../cubits/game_cubit/game_cubit.dart';
import '../../cubits/game_cubit/game_states.dart';
import '../../data/models/match_request.dart';
import '../../data/models/user.dart';
import '../widgets/app_loader.dart';

class CreatingMatchScreen extends StatefulWidget {
  const CreatingMatchScreen({
    Key? key,
    required this.isOnline,
    required this.players,
    this.request, this.friendMatchRequest, this.isFriendRequest
  }) : super(key: key);

  final List<AppUser> players ;
  final bool isOnline ;

  final MatchRequest? request ;
  final FriendMatchRequest? friendMatchRequest ;
  final bool? isFriendRequest ;

  @override
  State<CreatingMatchScreen> createState() => _CreatingMatchScreenState();
}

class _CreatingMatchScreenState extends State<CreatingMatchScreen> {


  @override
  void initState() {
    if(!widget.isOnline){
      GameCubit.get(context).createOfflineMatch(widget.players[0]);
    }else{
      if(widget.isFriendRequest!){
        GameCubit.get(context).createFriendsOnlineOneVsOneMatch(
            me: widget.players[0],
            opponent: widget.players[1],
            request: widget.friendMatchRequest!
        );
      }else{
        GameCubit.get(context).createPublicOnlineOneVsOneMatch(
            me: widget.players[0],
            opponent: widget.players[1],
            request: widget.request!
        );
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameCubit,GameStates>(
      listener: (context ,state){
        var cubit = GameCubit.get(context) ;
        if(state is OnlineMatchCreated){
          Navigator.pushNamedAndRemoveUntil(context, onlineMatchScreen ,(route) => false) ;
        }
        if(state is OfflineMatchCreated){
          if(state.botGotP6_6){
            Future.delayed(
                const Duration(milliseconds: 2250),
                    ()=> cubit.dominoBotPlays(bot: cubit.botPlayer, match: cubit.offlineMatch)
            );
          }
          Navigator.pushNamedAndRemoveUntil(context, offlineMatchScreen,(route) => false) ;
        }
      },
      child: SafeArea(
          child: Container(
            color: MyColors.darkBlue,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLoader(title: 'Loading',),
                  const SizedBox(height: 10,),
                  Text(
                    'Creating Match',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }
}
