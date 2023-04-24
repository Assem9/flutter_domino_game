import 'package:domino_game/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/user_cubit/user_cubit.dart';
import '../../cubits/user_cubit/user_states.dart';
import '../widgets/app_loader.dart';

class SearchForMatchScreen extends StatefulWidget {
  const SearchForMatchScreen({Key? key}) : super(key: key);

  @override
  State<SearchForMatchScreen> createState() => _SearchForMatchScreenState();
}

class _SearchForMatchScreenState extends State<SearchForMatchScreen> {

  @override
  void initState() {
    var userCubit = UserCubit.get(context);
    // start timer for 15 sec to stream on request collection
    //****
    if(!userCubit.durationEnded){
       Future.delayed(const Duration(seconds: 2),()=> userCubit.getFireStoreMatchRequests() );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserStates>(
      listener: (context, state){
        if(state is RequestCreated){
          Navigator.pushReplacementNamed(
            context,
            streamOnMyRequestScreen,
            arguments: true
          );
        }
        if(state is UserJoinedRequest){
          Navigator.pushReplacementNamed(
              context,
              streamOnReceivedRequestScreen,
              arguments: false
          );
        }

        if(state is SearchDurationEnded){
          if(!UserCubit.get(context).requestFound){
              UserCubit.get(context).addMatchRequest();
          }
        }
      },
      builder: (context, state){
        return Scaffold(
          body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30,) ,
                    state is SearchDurationWorking
                        ? searchForRequest(context)
                        : Container(),
                    // userCubit.durationEnded && !userCubit.requestFound
                    //  ? startingNewRequestWidget(context)
                    //   : Container()

                  ],
                ),
              )
          ),
        );
      },
    );
  }

  Widget searchForRequest(context){
    return Column(
      children: [
        Text(
          'Searching for Game....',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 15,),
        AppLoader(title: '${UserCubit.get(context).myDuration.inSeconds}',),

      ],
    );
  }

}

