import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domino_game/cacheHelper.dart';
import 'package:domino_game/constants/constants.dart';
import 'package:domino_game/constants/strings.dart';
import 'package:domino_game/cubits/user_cubit/user_states.dart';
import 'package:domino_game/data/firestore_services/user_firebase_services.dart';
import 'package:domino_game/presentation/screens/stream_on_myrequest_screen.dart';
import 'package:domino_game/presentation/screens/stream_on_received_request_screen.dart';
import 'package:domino_game/presentation/widgets/app_life_cycle.dart';
import 'package:domino_game/presentation/widgets/app_loader.dart';
import 'package:domino_game/presentation/widgets/app_logo_widget.dart';
import 'package:domino_game/presentation/widgets/friends_match_requests.dart';
import 'package:domino_game/presentation/widgets/user_pic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/components.dart';
import '../../constants/my_colors.dart';
import '../../cubits/user_cubit/user_cubit.dart';
import '../../data/models/user.dart';
import '../widgets/default_button.dart';
import '../widgets/disconnected_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.sky,
      body: SafeArea(
        child: OfflineBuilder(
            connectivityBuilder: (BuildContext context, ConnectivityResult connectivity, Widget child,) {
              final bool connected = connectivity != ConnectivityResult.none;
              if(connected){
                return Row(
                  children: [
                    Expanded(child: buildHomePageLeftHalf()),
                    Expanded(child: buildHomePageRightHalf()),
                    uId != null ? const LifeCycle(inMatch: false,) : Container(),
                  ],
                );
              }else{
                return const DisconnectedWidget();
              }
            },
          child: const Text(''),
        ),
      ),
    );
  }

  Widget buildHomePageLeftHalf(){
    return StreamBuilder<QuerySnapshot>(
        stream: UserFireBaseServices().streamOnFriendRequestsCollection(),
        builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          UserCubit.get(context).listenOnMyFriendRequestsListStream(snapshot);
          return BlocConsumer<UserCubit,UserStates>(
            listener: (context, state){},
            builder: (context,state){
              return UserCubit.get(context).user == null
                  ? const Center(child: AppLoader(title: 'loading..',))
                  :
              Stack(
                children: [
                  buildLeftScreenWidget(context),
                  UserCubit.get(context).requestSent
                      ? buildStreamingOnSentRequestToFriendWidget(context)
                      : Container(),
                  UserCubit.get(context).requestAccepted
                      ? const StreamOnReceivedRequestScreen(isFriendRequest: true,)
                      : Container(),
                ],
              ) ;
            },

          );
        }
    );
  }

  Widget buildHomePageRightHalf(){
    return StreamBuilder<QuerySnapshot>(
        stream: UserFireBaseServices().streamOnMyMatchRequests(),
        builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          UserCubit.get(context).listenOnMyMatchRequestsListStream(snapshot);
          return BlocConsumer<UserCubit,UserStates>(
            listener: (context, state){
              if(state is RequestDeleted){
                showToast(message: 'Request is deleted') ;
              }
              if(state is UserFriendsListLoaded){
                UserCubit.get(context).showFriendsAndRequestsScreen() ;
              }
            },
            builder: (context,state){
              return UserCubit.get(context).user == null
                  ? const Center(child: AppLoader(title: 'loading..',))
                  : _buildScreenRight(context) ;
            },

          );
        }
    );
  }

  Widget buildUserDataWidget(context){
    AppUser user = UserCubit.get(context).user! ;
    return InkWell(
      onTap: ()=> Navigator.pushNamed(context, profileScreen),
      child: Stack(
        alignment: AlignmentDirectional.topStart,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              UserAvatar(avatarUrl: user.photoUrl, radius: 20, online: true,),
              const SizedBox(width: 10,),
              Text(
                user.name.toUpperCase(),
                style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.clip,
                maxLines: 2,
              ),
            ],
          ),
          UserCubit.get(context).friendRequestsList.isNotEmpty ?
          CircleAvatar(
              backgroundColor: MyColors.red1,
              radius: 10,
              child: Text(
                  '${UserCubit.get(context).friendRequestsList.length}',
                style: Theme.of(context).textTheme.bodySmall,
              )
          ) : Container()
        ],
      ),
    );
  }

  Widget buildButtonsColum(context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DefaultButton(
            title: 'Play Offline',
            buttonColor: MyColors.lemon ,
            width: MediaQuery.of(context).size.width /4,
            height: 40,
            onTap: ()=>  Navigator.pushNamed(
                context,
                creatingMatchScreen,
                arguments: {
                  'players':[UserCubit.get(context).user!,],
                  'isOnline': false ,
                  'request': null,
                }
            )
        ),
        const SizedBox(height: 15,),
        DefaultButton(
          title: 'Play Online',
          buttonColor: MyColors.lemon ,
          width: MediaQuery.of(context).size.width /4,
          height: 40,
          onTap: ()=> Navigator.pushNamed(context, searchGameScreen),
        ),
        /*
        DefaultButton(
          title: 'TEST',
          width: 180,
          textColor: Colors.white,
          //  color: MyColors.light ,
          onTap: ()=>UserRepository(UserFireBaseServices()).updateUserPresence()//searchGameScreen
        ),*/
      ],
    );
  }

  Widget buildChoseMatchModeWidget(context){
    return SizedBox(
      width: 320,
      child: Column(
        children: [
          DefaultButton(
              title: 'One Round',
              buttonColor: MyColors.lemon ,
              width: MediaQuery.of(context).size.width /4,
              height: 40,
              onTap: ()=>  Navigator.pushNamed(
                  context,
                  creatingMatchScreen,
                  arguments: {
                    'players':[UserCubit.get(context).user!,],
                    'isOnline': false ,
                    'request': null,
                  }
              )
          ),
          const SizedBox(width: 10,),
          DefaultButton(
              title: '101 S Match',
              buttonColor: MyColors.lemon ,
              width: MediaQuery.of(context).size.width /4,
              height: 40,
              onTap: ()=>  Navigator.pushNamed(
                  context,
                  creatingMatchScreen,
                  arguments: {
                    'players':[UserCubit.get(context).user!,],
                    'isOnline': false ,
                    'request': null,
                  }
              )
          ),
        ],
      ),
    );
  }

  Widget buildLeftScreenWidget(context){
    return Padding(
      padding: const EdgeInsets.only(left: 22.0,top: 12),
      child: Stack(
        children: [
          SvgPicture.asset(
            'assets/images/selfie_svg.svg',
            width: MediaQuery.of(context).size.height/2,
            height: MediaQuery.of(context).size.height ,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             // DefaultButton(title: 'Test', onTap: ()=>UserFireBaseServices().updateUserStatus(status: 'inMatch')),
              const SizedBox(height: 10,),
              buildUserDataWidget(context),
              const Spacer(),
              buildButtonsColum(context),
              const SizedBox(height: 30,),
            ],
          ),

        ],
      ),
    );
  }

  Widget buildStreamingOnSentRequestToFriendWidget(context){
    return Container(
      color: MyColors.sky,
      child: Column(
        children: const [
           Expanded(
              child: StreamOnMyRequestScreen(isFriendRequest: true,)
          ),
        ],
      ),
    );
  }

  Widget _buildScreenRight(context){
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogoWidget(radius: MediaQuery.of(context).size.height/8),
            const SizedBox(height: 49,),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.displaySmall!.copyWith(color: MyColors.lemon, fontSize: 40),
              child: AnimatedTextKit(
                  repeatForever: true,
                  animatedTexts: [
                    WavyAnimatedText('DOMINO GAME',),
                    ColorizeAnimatedText(
                        'DOMINO GAME',
                        textStyle: Theme.of(context).textTheme.displaySmall!.copyWith(color: MyColors.lemon, fontSize: 40),
                        colors: [MyColors.lemon, MyColors.blue, MyColors.sky]
                    )
                  ]
              ),
            ),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.displayMedium!.copyWith(color: MyColors.lightBeige, fontSize: 15),
              child: AnimatedTextKit(
                repeatForever: true,
              //  pause: const Duration(seconds: 5),
                animatedTexts: [
                  TyperAnimatedText('Invite Your friends'),
                  TyperAnimatedText('and start playing now!!'),
                ],

              ),
            ),

          ],
        ),
        Align(
            alignment: AlignmentDirectional.topEnd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                buildFriendsAndRequestsButton(context),
                UserCubit.get(context).friendsAndRequestsScreenIsShown?
                const Expanded(child: FriendsAndMatchRequestsScreen()): Container(),
              ],
            )
        ),

      ],
    );
  }

  Widget buildFriendsAndRequestsButton(context){
    return SizedBox(
      width: 170,
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          InkWell(
            onTap: (){
              UserCubit.get(context).getFriends();
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric( vertical: 8),
              alignment: AlignmentDirectional.center,
              decoration:  BoxDecoration(
                color: MyColors.light.withOpacity(0.8),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), )
              ),
              child: Text(
                UserCubit.get(context).friendsAndRequestsScreenIsShown?
                'Hide' :'Friends & Requests' ,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          UserCubit.get(context).friendsMatchRequests.isNotEmpty ?
          Positioned(
            left: 4,
            child: CircleAvatar(
              backgroundColor: MyColors.red1,
              radius: 11,
              child: Text(
                '${UserCubit.get(context).friendsMatchRequests.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ) : Container()
        ],
      ),
    );
  }


}
