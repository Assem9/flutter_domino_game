import 'package:domino_game/constants/components.dart';
import 'package:domino_game/constants/my_colors.dart';
import 'package:domino_game/cubits/user_cubit/user_cubit.dart';
import 'package:domino_game/cubits/user_cubit/user_states.dart';
import 'package:domino_game/data/models/add_friend_request.dart';
import 'package:domino_game/data/models/user.dart';
import 'package:domino_game/presentation/widgets/alert_dialog.dart';
import 'package:domino_game/presentation/widgets/app_loader.dart';
import 'package:domino_game/presentation/widgets/default_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/strings.dart';
import '../widgets/default_button.dart';
import '../widgets/textfield.dart';
import '../widgets/user_pic.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({Key? key}) : super(key: key);
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.darkBlue,
      body: BlocConsumer<UserCubit,UserStates>(
        listener: (context, state){
          if(state is UserSignedOut){
            Navigator.pushNamedAndRemoveUntil(context, firstScreen, (route) => false) ;
          }
          if(state is AddingFriendRequestDeclined){
            showToast(message: 'Request Declined');
          }
          if(state is AddingFriendRequestAccepted){
            showToast(message: 'Request Accepted');
          }
          if(state is UserDataUpdated){
            Navigator.pop(context);
            showToast(message: 'your data updated');
          }
        },
        builder: (context, state){
          final mediaQuery = MediaQuery.of(context);
          final topPadding = mediaQuery.padding.top;
          final leftPadding = mediaQuery.padding.left;
          print('leftPadding: => $leftPadding');
          print('topPadding: => $topPadding');
          return SafeArea(
            child: Builder(builder:(context){

              return !UserCubit.get(context).userSigningOut ?
              buildAccountDataWidget(context)
                  :const Center(child: AppLoader(title: 'Signing Out',)) ;
            }
            )


          );
        },
      ),
    );
  }

  Widget buildAccountDataWidget(cubitContext){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Align(
                alignment: AlignmentDirectional.topCenter,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return  const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomRight,
                        colors: [
                          MyColors.white,
                          MyColors.lightBeige,
                          MyColors.lemon ,
                          MyColors.sky,

                        ]
                    ).createShader(bounds);
                  },
                  child: Container(
                    height: MediaQuery.of(cubitContext).size.height*0.4 -30,
                    decoration: const BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/images/background.jpg'),fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.topStart,
                child: Row(
                  children: [
                    PhysicalModel(
                      color: MyColors.lemon,
                      shadowColor: MyColors.darkBlue,
                      elevation: 8,
                      shape: BoxShape.circle,
                      child: IconButton(
                        padding: const EdgeInsets.all(5),
                        constraints: const BoxConstraints(),
                          onPressed: ()=> Navigator.pop(cubitContext),
                          icon: const Icon(Icons.arrow_back_rounded,color: MyColors.darkBlue,)
                      ),
                    ),
                    const Spacer(),
                    DefaultButton(
                      title: 'Sign Out',
                      textColor: Colors.white,
                      buttonColor: MyColors.blue,
                      width: 100,
                      height: 30,
                      onTap: ()=> showDialog(
                        context: cubitContext,
                        builder: (_) => DefaultDialog(
                            title: 'Domino Game',
                            content: 'Are you sure you want to sign out ',
                            onConfirm: (){
                              Navigator.pop(cubitContext);
                              UserCubit.get(cubitContext).signOut();
                            }
                        ),
                      )

                          //UserCubit.get(cubitContext).signOut(),
                    )
                  ],
                ),
              ),
              Positioned(
                  top: 35,
                  left: 30,
                  child: buildProfileImage(cubitContext, user: UserCubit.get(cubitContext).user!)
              ) ,
            ],
          ),
        ),
        Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15,),
                        buildUserDataRow(cubitContext, user: UserCubit.get(cubitContext).user!),
                        const SizedBox(height: 5,),
                        UserCubit.get(cubitContext).profileImage == null ?
                        editDataWidget(
                            cubitContext,
                            text: '- Edit profile photo ? ',
                            onTap: ()=>UserCubit.get(cubitContext).getProfileImage()
                        ):
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DefaultButton(
                                buttonColor: MyColors.lemon ,
                                title: 'Save',
                                width: MediaQuery.of(cubitContext).size.width/5,
                                onTap: ()=> UserCubit.get(cubitContext).updateUserPhoto()
                            ),
                            const SizedBox(width: 10,),
                            DefaultButton(
                                buttonColor: MyColors.red1 ,
                                title: 'Cancel',
                                width: MediaQuery.of(cubitContext).size.width/5,
                                onTap: ()=> UserCubit.get(cubitContext).cancelEditingImage()
                            ),
                          ],
                        ),
                        //const SizedBox(height: 15,),
                        editDataWidget(
                            cubitContext,
                            text: '- Edit your name ? ',
                            onTap: ()=> showDialog(
                              context: cubitContext,
                              builder: (_) => DefaultDialog(
                                  title: 'Domino Game',
                                  content: 'content',
                                  contentWidget: DefaultTextField(
                                    controller: nameController,
                                    hint: 'write ur new name',
                                    type: TextInputType.text,
                                    border: const UnderlineInputBorder(),
                                  ),
                                  onConfirm: ()=> UserCubit.get(cubitContext).updateUserName(nameController.text)
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                ),
                const DefaultDivider(color: MyColors.lemon, isVertical: true, withMargin: true,),
                Expanded(
                    child: buildAddFriendWidget(cubitContext)
                ),
                const DefaultDivider(color: MyColors.lemon, isVertical: true, withMargin: true,),
                Expanded(
                    child: buildFriendRequestsListView(cubitContext)
                )
              ],
            )
        ),
        const SizedBox(height: 5,)
      ],
    );
  }

  Widget buildEditNameForm(context){
    return Column(
      children: [
        DefaultTextField(
          controller: nameController,
          hint: 'Want To Change It ?',
          type: TextInputType.text,
          border: const UnderlineInputBorder(),
        ),
        Center(
          child: DefaultButton(
              buttonColor: MyColors.lemon ,
              title: 'Submit Changes',
              width: MediaQuery.of(context).size.width/4,
              onTap: (){}
          ),
        ),
        const SizedBox(height: 15,),

      ],
    );
  }

  Widget buildProfileImage(context,{required AppUser user}){
    return PhysicalModel(
      color: MyColors.lightColor,
      shape: BoxShape.circle,
      elevation: 6,
      shadowColor: MyColors.darkBlue ,
      child: UserCubit.get(context).profileImage == null ?
      CircleAvatar(
          radius: MediaQuery.of(context).size.height*0.2 -20,
          backgroundImage:
          NetworkImage(user.photoUrl)
      ):
      CircleAvatar(
        radius: MediaQuery.of(context).size.height*0.2 -10,
        backgroundImage:
        FileImage(UserCubit.get(context).profileImage!),
      ),
    );
  }

  Widget buildUserDataRow(context,{required AppUser user}){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${user.name} ',
          overflow: TextOverflow.clip,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        Text(
          '${user.email} ',
          overflow: TextOverflow.clip,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MyColors.light),
        ),
      ],
    );
  }
  
  Widget editDataWidget(context,{required String text,required Function onTap}){
    return TextButton(
        onPressed: (){onTap();},
        child: Text(
          text,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Colors.white,decoration: TextDecoration.underline ),
    )
    );
  }

  final TextEditingController friendEmailController = TextEditingController(); 
  Widget buildAddFriendWidget(context){
    return Column(
      children: [
        Text(
          'Add Friends',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const DefaultDivider(color: MyColors.lemon, isVertical: false, withMargin: true,),
        //const SizedBox(height: 10,),
        Column(
          children: [
            DefaultTextField(
                controller: friendEmailController,
                hint: 'write friend email here',
                type: TextInputType.text,
            ),
            const SizedBox(height: 10,),
            Center(
              child: DefaultButton(
                  buttonColor: MyColors.lemon,
                //  width: MediaQuery.of(context).size.width/3,
                  title: 'Send Request',
                  onTap: (){
                    if(friendEmailController.text.isNotEmpty){
                      UserCubit.get(context).sendFriendRequest(email: friendEmailController.text) ;
                    }else{
                      showToast(message: 'Please write email') ;
                    }

                  }
              ),
            )
          ],
        )
      ],
    );
  }
  
  Widget buildFriendRequestsListView(context){
    return Column(
      children: [
        Text(
          'Friend Requests',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const DefaultDivider(color: MyColors.lemon, isVertical: false, withMargin: true,),
       // const SizedBox(height: 10,),
        UserCubit.get(context).friendRequestsList.isNotEmpty ?
        Expanded(
          child: ListView.separated(
            separatorBuilder:(context,index)=> const DefaultDivider(color: MyColors.lemon, isVertical: false, withMargin: true,),
            itemCount: UserCubit.get(context).friendRequestsList.length,
            itemBuilder:(context,index)=> buildFriendRequestItemWidget(
                context,
                request: UserCubit.get(context).friendRequestsList[index]
            ),

          ),
        ) :
        Text(
          'you have no friend request',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
  
  Widget buildFriendRequestItemWidget(context,{required AddingFriendRequest request}){
    return Column(
      children: [
        Row(
          children: [
            UserAvatar(avatarUrl: request.requestSender.photoUrl, radius: 14, online: true,),
            const SizedBox(width: 5,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${request.requestSender.name} ',
                    overflow: TextOverflow.clip,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    '${request.requestSender.email} ',
                    overflow: TextOverflow.clip,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: MyColors.light),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8,),
        Row(
          children: [
            Expanded(
                child: DefaultButton(
                  title: 'Accept',
                  height: 30,
                  buttonColor: MyColors.lemon,
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                  onTap: ()=> UserCubit.get(context).acceptFriendRequest(request),
                )
            ),
            const SizedBox(width: 5,),
            Expanded(
                child: DefaultButton(
                  title: 'Decline',
                  height: 30,
                  buttonColor: MyColors.red1,
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                  onTap: ()=> UserCubit.get(context).declineFriendRequest(request.iD),
                )
            ),
          ],
        )
      ],
    );
  }
}
