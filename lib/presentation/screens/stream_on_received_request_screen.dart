import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/constants.dart';
import '../../constants/strings.dart';
import '../../cubits/user_cubit/user_cubit.dart';
import '../../cubits/user_cubit/user_states.dart';
import '../../data/firestore_services/user_firebase_services.dart';
import '../widgets/app_loader.dart';

class StreamOnReceivedRequestScreen extends StatelessWidget {
  const StreamOnReceivedRequestScreen({Key? key, required this.isFriendRequest}) : super(key: key);
  final bool isFriendRequest ;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<UserCubit,UserStates>(
            listener: (context ,state){
              if(state is OpponentInitializedMatch){
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
        ),
      ),
    );
  }


  Widget buildStreamerOnReceivedPublicRequest(context){
    return StreamBuilder (
      stream: UserFireBaseServices()
          .streamMyPublicMatchRequest(UserCubit.get(context).joinedRequest!.iD),
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
  }
}
