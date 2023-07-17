import 'package:domino_game/constants/components.dart';
import 'package:domino_game/constants/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../constants/strings.dart';
import '../../cubits/user_cubit/user_cubit.dart';
import '../../cubits/user_cubit/user_states.dart';
import '../../data/firestore_services/user_firebase_services.dart';
import '../widgets/app_loader.dart';
import '../widgets/default_button.dart';

class StreamOnMyRequestScreen extends StatelessWidget {
  const StreamOnMyRequestScreen({
    Key? key,
    required this.isFriendRequest
  }) : super(key: key);
  final bool isFriendRequest ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<UserCubit,UserStates>(
            listener: (context ,state){
              if(state is RequestPlayerListIsComplete){
                Navigator.pushReplacementNamed(
                    context,
                    creatingMatchScreen,
                    arguments: {
                      'isOnline': true ,
                      'players': state.joiners,
                      'isFriendRequest': isFriendRequest,
                      'request': !isFriendRequest ? UserCubit.get(context).matchRequest : null,
                      'friendMatchRequest': isFriendRequest ? UserCubit.get(context).friendMatchRequest : null
                    }) ;
              }

              if(state is MatchRequestDeclined){
                UserCubit.get(context).cancelFriendMatchRequest() ;
                showToast(message: '${UserCubit.get(context).myFriend.name} declined your request') ;
              }

            },
            child: isFriendRequest
                ? buildFriendMatchRequestStream(context)
                : buildPublicMatchRequestStream(context)
        )
      ),
    );
  }


  Widget buildPublicMatchRequestStream(context){
    return StreamBuilder (
      stream: UserFireBaseServices()
          .streamMyPublicMatchRequest(UserCubit.get(context).matchRequest!.iD),
      builder: (context ,snapshot) {
        UserCubit.get(context).listenOnMyPublicMatchRequestStream(context,snapshot);
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Waiting For Opponent ',style: Theme.of(context).textTheme.bodyLarge,),
              const SizedBox(height: 20,),
              const AppLoader(title: 'Waiting',),
              const SizedBox(height: 20,),
              DefaultButton(
                  buttonColor: MyColors.lemon,
                  width: 150,
                  title: 'Cancel',
                  onTap: ()=> UserCubit.get(context).cancelPublicMatchRequest(context)
              ),
            ],
          ),
        );
      },

    );
  }

  Widget buildFriendMatchRequestStream(context){
    return StreamBuilder (
      stream: UserFireBaseServices()
          .streamOnFriendMatchRequest(
          requestId: UserCubit.get(context).friendMatchRequest.iD,
          friendId: UserCubit.get(context).myFriend.iD,
      ),
      builder: (context ,snapshot) {
        UserCubit.get(context).listenOnSentMatchRequestStream(context,snapshot);
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SvgPicture.asset(
              'assets/images/game_day.svg',
            ),
            Positioned(
              top: 20,
              child: Text(
                'Waiting For ${UserCubit.get(context).myFriend.name} To Accept',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Center(
              child: AppLoader(title: 'Waiting',loaderColor: MyColors.light,),
            ),
            Positioned(
              bottom: 25,
              child: DefaultButton(
                  buttonColor: MyColors.lemon,
                  width: MediaQuery.of(context).size.width/4,
                  title: 'Cancel Request',
                  onTap: ()=> UserCubit.get(context).cancelFriendMatchRequest()
              ),
            ),
          ],
        );
      },

    );
  }
/*
  // joiner
  Widget _receivedRequestWidgetBuilder(context){
    return BlocListener<UserCubit,UserStates>(
      listener: (context ,state){
        if(state is OpponentInitializedMatch && !isRequestCreator){
          Navigator.pushReplacementNamed(
              context,
              onlineMatchLoadingDataScreen,
              arguments: isFriendRequest
                  ? UserCubit.get(context).friendMatchRequest.matchId
                  : UserCubit.get(context).joinedRequest!.matchId
          ) ;
        }
      },
      child: isFriendRequest
          ? buildStreamerOnAcceptedFriendMatchRequest(context)
          : buildStreamerOnReceivedPublicRequest(context)
    );
  }

  Widget buildStreamerOnReceivedPublicRequest(context){
    return StreamBuilder (
      stream: UserFireBaseServices()
          .streamOnCreatedRequest(UserCubit.get(context).joinedRequest!.iD),
      builder: (context ,snapshot) {
        UserCubit.get(context).streamOnFoundedRequest(context,snapshot);
        return _buildStreamOnReceivedRequestWidget(context, 'Founded Match');
      },

    );
  }

  Widget buildStreamerOnAcceptedFriendMatchRequest(context){
    var request = UserCubit.get(context).friendMatchRequest ;
    return StreamBuilder (
      stream: UserFireBaseServices()
          .streamOnFriendMatchRequest(
          requestId: request.iD,
          friendId: uId!,
      ),
      builder: (context ,snapshot) {
        UserCubit.get(context).listenOnAcceptedMatchRequestStream(context,snapshot);
        return _buildStreamOnReceivedRequestWidget(context, 'Starting Match Vs ${request.requestCreator}');
      },

    );
  }

  Widget _buildStreamOnReceivedRequestWidget(context,String text){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20,),
          const AppLoader(title: 'Loading Data',),
        ],
      ),
    );
  }*/

}
