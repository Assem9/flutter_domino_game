import 'package:domino_game/constants/components.dart';
import 'package:domino_game/constants/my_colors.dart';
import 'package:domino_game/cubits/auth_cubit/auth_cubit.dart';
import 'package:domino_game/cubits/auth_cubit/auth_states.dart';
import 'package:domino_game/presentation/widgets/app_loader.dart';
import 'package:domino_game/presentation/widgets/default_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../constants/strings.dart';
import '../widgets/app_logo_widget.dart';

class VerifyingEmailScreen extends StatelessWidget {
  const VerifyingEmailScreen({
    Key? key,
    required this.userName,
    required this.password,
    required this.email
  }) : super(key: key);
  final String userName ;
  final String password ;
  final String email ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              _buildSvgPhoto(context),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Align(
                        alignment:AlignmentDirectional.topStart,
                        child: AppLogoWidget(radius: 50)
                    ),
                    const SizedBox(height: 15,),
                    _buildRichTextMessage(context),
                    _buildTextButtonsRow(context),
                    const SizedBox(height: 15,),
                    _buildNextButton(),
                   // const AppLoader(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRichTextMessage(context){
    return RichText(
      text: TextSpan(
          text: 'We have sent a verification link to this email address ',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: MyColors.lightBeige),
          children: [
            TextSpan(
              text: email,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: MyColors.lemon),
            ),
            TextSpan(
              text: ' please go click on the link to verify your account',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: MyColors.lightBeige),
            )
          ]
      ),

    );
  }

  Widget _buildTextButtonsRow(context){
    return BlocListener<AuthCubit,AuthStates>(
      listener: (context,state){
        if(state is VerificationLinkReSent){
          showToast(message: 'Verification Link Sent Successfully') ;
        }
        if(state is AuthenticatedEmailDeleted){
          Navigator.pushNamedAndRemoveUntil(context, firstScreen, (route) => false);
        }
      },
      child: Row(
        children: [
          TextButton(
              onPressed: ()=> AuthCubit.get(context).deleteAuthenticatedEmail(),
              child: Text(
                'Change email Address ?',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    decoration: TextDecoration.underline,
                    color: MyColors.light
                ),
              )
          ),
          const Spacer(),
          TextButton(
              onPressed: ()=> AuthCubit.get(context).reSendVerificationLink(),
              child: Text(
                'Resend verification link ?',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    decoration: TextDecoration.underline,
                    color: MyColors.lemon
                ),
              )
          ),

        ],
      ),
    );
  }

  Widget _buildNextButton(){
    return BlocConsumer<AuthCubit,AuthStates>(
        listener: (context,state){
          if(state is UserEmailVerified){
            SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
            Navigator.pushNamedAndRemoveUntil(context, home, (route) => false);
          }
        },
        builder:(context,state){
          return !AuthCubit.get(context).dataLoading?
            DefaultButton(
              title: 'NEXT',
              buttonColor: MyColors.lemon,
              width: 100,
              onTap: ()=>AuthCubit.get(context).checkIfEmailIsVerified(
                  name: userName,
                  password: password,
                  emailAddress: email
              )
          ) :
          const Align(alignment:AlignmentDirectional.centerEnd,child: AppLoader(size: 25,));
    }
    );
  }

  Widget _buildSvgPhoto(context){
    return Positioned(
      top: 30,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return  const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomRight,
              colors: [
                MyColors.white,
                //MyColors.lightBeige,
                MyColors.lemon ,
                MyColors.sky,

              ]
          ).createShader(bounds);
        },
        child: SvgPicture.asset(
          'assets/images/authentication.svg',
          // width: MediaQuery.of(context).size.height ,
          height: MediaQuery.of(context).size.height/3 ,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

