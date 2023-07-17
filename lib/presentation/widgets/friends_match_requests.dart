import 'package:domino_game/constants/components.dart';
import 'package:domino_game/cubits/user_cubit/user_states.dart';
import 'package:domino_game/data/firestore_services/user_firebase_services.dart';
import 'package:domino_game/presentation/widgets/user_pic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/my_colors.dart';
import '../../cubits/user_cubit/user_cubit.dart';
import '../../data/models/match_request.dart';
import '../../data/models/user.dart';
import 'default_button.dart';

class FriendsAndMatchRequestsScreen extends StatelessWidget {
  const FriendsAndMatchRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: MediaQuery.of(context).size.width/2.5,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: MyColors.darkBlue.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: MyColors.light)
      ),
      child: BlocBuilder<UserCubit,UserStates>(
        builder: (context,state){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTopBar(context),
              myDivider(),
              const SizedBox(height: 5,),
              Expanded(
                child: UserCubit.get(context).friendsListIsShown
                    ? buildFriendsList(context)
                    : buildMatchRequestsList(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildFriendsList(context){
    var myFriendsList = UserCubit.get(context).myFriendsListWithId.values.toList() ;
    return myFriendsList.isNotEmpty ?  Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          itemCount: myFriendsList.length,
          separatorBuilder: (BuildContext context, int index)=> myDivider(),
          itemBuilder: (context, index)=> _buildStreamBuilderForFriendData(
              id:myFriendsList[index].iD,
              index:index
          ),
        ),
      ],
    ): Container();
  }

  Widget buildTopBar(context){
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: ()=> UserCubit.get(context).showFriendsList(true),
              child: Container(
                alignment: AlignmentDirectional.center,
                  height: 40,
                  color: UserCubit.get(context).friendsListIsShown
                      ? MyColors.blue
                      : MyColors.blue.withOpacity(0.3),
                  child: Text(
                    'Friends',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 15,
                      color: UserCubit.get(context).friendsListIsShown
                          ? MyColors.lemon
                          : Colors.white,
                    ),
                  ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: (){
                UserCubit.get(context).showFriendsList(false) ;

              },
              child: Container(
                alignment: AlignmentDirectional.center,
                height: 40,
                color: UserCubit.get(context).friendsListIsShown
                      ? MyColors.blue.withOpacity(0.3)
                      : MyColors.blue ,
                child: Text(
                  'Match Requests',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 15,
                      color: UserCubit.get(context).friendsListIsShown
                          ? MyColors.white
                          : MyColors.lemon
                    ),
                  ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget buildFriendDataWidget(context,{required AppUser friend}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        UserAvatar(
          avatarUrl: friend.photoUrl,
          radius: MediaQuery.of(context).size.height/24,
          online: true,
        ),
        const SizedBox(width: 10,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                friend.name,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.clip,
                maxLines: 1,
              ),
              friend.status == UserStatus.online ?
              Text(
                '- Online',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MyColors.lemon),
              ):Container(),
              friend.status == UserStatus.offline ?
              Text(
                '- Offline',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MyColors.red1),
              ): Container(),
              friend.status == UserStatus.inMatch ?
              Text(
                '- is playing',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MyColors.light),
              ): Container(),
              friend.status == UserStatus.away ?
              Text(
                '- Away',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MyColors.light),
              ): Container()
            ],
          ),
        ),
        !UserCubit.get(context).requestSent ?
        DefaultButton(
            width: MediaQuery.of(context).size.width/14,
            //height: MediaQuery.of(context).size.height/14,
            title: 'PLAY',
            buttonColor: friend.status == UserStatus.online
                ? MyColors.light
                : MyColors.light.withOpacity(0.3),
            textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),
            onTap: (){
              if(friend.status == UserStatus.online){
                UserCubit.get(context).sendMatchRequest(friend) ;
              }else{
                showToast(message: friend.status == UserStatus.inMatch
                    ? '${friend.name } is playing another match'
                    : '${friend.name } is offline'
                ) ;
              }
            }
        ) : Container(),
      ],
    );
  }

  Widget _buildStreamBuilderForFriendData({
    required String id,
    required int index
  }){
    return StreamBuilder(
        stream: UserFireBaseServices().streamOnMyFriendData(id),
        builder: (context, snapshot){
          UserCubit.get(context).listenFriendData(snapshot) ;
          var friend = UserCubit.get(context).myFriendsListWithId.values.toList()[index] ;
          return buildFriendDataWidget(context, friend: friend);
        }
        );
  }

  Widget myDivider(){
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 1,
      color: MyColors.light,
    );
  }

  Widget buildMatchRequestsList(context){
    return UserCubit.get(context).friendsMatchRequests.isNotEmpty ?
    ListView.separated(
        shrinkWrap: true,
        itemCount: UserCubit.get(context).friendsMatchRequests.length,
        separatorBuilder: (BuildContext context, int index)=> myDivider(),
        itemBuilder: (context, index)=> buildMatchRequestWidget(
            context,
            request: UserCubit.get(context).friendsMatchRequests[index]
        )
    )
        : Center(
          child: Text(
      'No requests received' ,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MyColors.lightBeige),
    ),
        );
  }

  Widget buildMatchRequestWidget(context,{required FriendMatchRequest request}){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
      height: MediaQuery.of(context).size.height < 400 ? 70 :110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: MyColors.blue,
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                '${request.requestCreator} Sent you a Match Request',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 5,),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Expanded(
                  child: DefaultButton(
                      title: 'ACCEPT',
                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),
                     // height: MediaQuery.of(context).size.height/14,//25
                     // width: 65,
                      buttonColor: MyColors.lemon.withOpacity(0.7),
                      onTap: ()=> UserCubit.get(context).acceptMatchRequest(acceptedRequest: request)
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: DefaultButton(
                      title: 'DECLINE',
                      buttonColor: MyColors.red1,
                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),
                      onTap: ()=> UserCubit.get(context).declineMatchRequest(request: request)
                  ),
                ),

              ],
            ),
          ) 
        ],
      ),
    );
  }

}
