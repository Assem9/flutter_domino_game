import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:domino_game/constants/components.dart';
import 'package:domino_game/constants/my_colors.dart';
import 'package:domino_game/cubits/auth_cubit/auth_cubit.dart';
import 'package:domino_game/data/models/user.dart';
import 'package:domino_game/presentation/widgets/app_animated_title.dart';
import 'package:domino_game/presentation/widgets/app_loader.dart';
import 'package:domino_game/presentation/widgets/app_logo_widget.dart';
import 'package:domino_game/presentation/widgets/default_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../cacheHelper.dart';
import '../../constants/constants.dart';
import '../../constants/strings.dart';
import '../../cubits/auth_cubit/auth_states.dart';
import '../widgets/textfield.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if(widthWithNoNotch == null ){
      setWithNoNotch(context);
    }
    super.initState();
  }
  @override
  void dispose() {
    //SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    super.dispose();
  }
  void setWithNoNotch(context)async{
    // in mobiles with notches => safeArea take the notch space as padding
    // this could ruin our ui in match screen so we need to send the widthWithNoNotch
    // to the initScreenSettings() method instead of mediaQuery.size.width
    final mediaQuery = MediaQuery.of(context);
    final rightPadding = mediaQuery.padding.top;
    final leftPadding = mediaQuery.padding.bottom;
    widthWithNoNotch = mediaQuery.size.height - (rightPadding + leftPadding);
    print('widthWithNoNotch $widthWithNoNotch');
    await CacheHelper.saveData(key: 'widthWithNoNotch', value: widthWithNoNotch) ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.sky,
      body: BlocConsumer<AuthCubit,AuthStates>(
        listener: (context, state){
          if(state is UserSignedIn || state is UserSignedWithFacebookOrGoogle){
            SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]).then((value){
              Navigator.pushNamedAndRemoveUntil(context, home, (route) => false) ;
            });
          }
          if(state is UserSignedUp){
            Navigator.pushNamedAndRemoveUntil(
                context,
                verifyingEmailScreen,
                    (route) => false,
                arguments: {
                  'name':nameController.text,
                  'password':passwordController.text,
                  'email':emailController.text,
                },
            )
            ;
          }
        },
        builder: (context, state){

          return SafeArea(
            child: !AuthCubit.get(context).dataLoading ?
            Stack(
              children: [
                Positioned(
                  top: 20,
                 // alignment: AlignmentDirectional.topCenter,
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
                      'assets/images/login.svg',
                     // width: MediaQuery.of(context).size.height ,
                      height: MediaQuery.of(context).size.height/4 ,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: _buildOfflineModeButton(context),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const AppLogoWidget(radius: 50),
                            Expanded(
                              child: AppAnimatedTitle(
                                  titleTextStyle: Theme.of(context).textTheme.displaySmall!.copyWith(color: MyColors.lemon, fontSize: 22),
                                  subtitleTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: MyColors.lightBeige, fontSize: 15),
                                  subtitleTextsList: [
                                    TyperAnimatedText(
                                        AuthCubit.get(context).showRegister? 'Sign Up Now'  : 'Sign In Now '
                                    ),
                                    TyperAnimatedText('and start beating people online '),
                                    //and let the fun starts!!
                                  ]
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        AuthCubit.get(context).showRegister
                            ? buildRegisterForm(context)
                            : buildSignInForm(context),
                      ],
                    )
                  ),
                ),
              ],
            ):
            const Center(
                child: AppLoader(title: 'Loading...',)),
          );
        },
      ),
    );
  }

  Widget _buildOfflineModeButton(context){
    AppUser fakeUser = AppUser(
        name: 'Offline User',
        iD: 'fakeUser',
        email: 'fake email',
        photoUrl: 'ss',
        friendsIds: [],
        status: UserStatus.online
    );
    return DefaultButton(
        title: 'Offline Mode',
        buttonColor: MyColors.lemon ,
        width: 122,
        height: 40,
        onTap: (){
          SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]).then((value){
            Navigator.pushNamed(
                context,
                creatingMatchScreen,
                arguments: {
                  'players':[fakeUser,],
                  'isOnline': false ,
                  'request': null,
                }
            );
          });

        }
    );
  }

  Widget swapBetweenForms(context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AuthCubit.get(context).showRegister? Container()
            :
        Text(
            'Don\'t have an account?',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white)
        ),
        TextButton(
            onPressed: ()=> AuthCubit.get(context).swapLoginRegister(),
            child: Text(
              AuthCubit.get(context).showRegister
                  ? 'Back to Sign in Page'
                  : 'Register Now ',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                decoration: TextDecoration.underline,
                color: MyColors.lemon
              ),
            )
        ),
      ],
    ) ;
  }

  Widget buildContinueWithWidget(context){
    return Column(
      children: [
        Text(
          'Or',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(color: MyColors.white),
        ),
        Text(
          'Continue With:',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(color: MyColors.white),
        ),
        const SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              child: DefaultButton(
                  title: 'Google',
                  buttonColor: MyColors.red1,// Colors.red,
                  textColor: MyColors.white,
                  onTap: ()=> AuthCubit.get(context).continueWithGoogle(),
              ),
            ),
            const SizedBox(width: 10,),
            Expanded(
              child: DefaultButton(
                  title: 'Facebook',
                  buttonColor: MyColors.blue2, //Colors.blueAccent,
                  textColor: MyColors.white,
                  onTap: ()=> AuthCubit.get(context).continueWithFacebook(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  final signInFormKey = GlobalKey<FormState>();
  Widget buildSignInForm(context ){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: signInFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          //  Text('Sign In',style: Theme.of(context).textTheme.displaySmall,),
            const SizedBox(height: 20,),
            DefaultTextField(
                controller: emailController,
                hint: 'Write Email',
                type: TextInputType.text,
            ),
            DefaultTextField(
              controller: passwordController,
              hint: 'Write password',
              type: TextInputType.visiblePassword,
              suffixIcon: IconButton(
                icon: Icon(AuthCubit.get(context).suffix),
                onPressed: AuthCubit.get(context).changePasswordVisibility,
              ),
              obscureText: AuthCubit.get(context).isPasswordShown,
            ),
            TextButton(
                onPressed: ()=> AuthCubit.get(context).swapLoginRegister(),
                child: Text(
                  'Forgotten password?',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      decoration: TextDecoration.underline,
                      color: MyColors.lemon
                  ),
                )
            ),
            swapBetweenForms(context),
            DefaultButton(
              title: 'SIGN IN',
              buttonColor: MyColors.lemon,
              onTap: (){
                if(signInFormKey.currentState!.validate()){
                  AuthCubit.get(context).signInWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text
                  ) ;
                }
              },
            ),
            const SizedBox(height: 10,),
            buildContinueWithWidget(context,),

          ],
        ),
      ),
    );
  }

  final signUpFormKey = GlobalKey<FormState>();
  Widget buildRegisterForm(context){
    return Form(
      key: signUpFormKey,
      child: Column(
        children: [
          const SizedBox(height: 20,),
          DefaultTextField(
              controller: nameController,
              hint: 'Write Your Name',
              type: TextInputType.text,
          ),
          DefaultTextField(
            controller: emailController,
            hint: 'Write Your Email',
            type: TextInputType.text,
          ),
          DefaultTextField(
              controller: passwordController,
              hint: 'Write Password',
            type: TextInputType.visiblePassword,
            suffixIcon: IconButton(
              icon: Icon(AuthCubit.get(context).suffix),
              onPressed: AuthCubit.get(context).changePasswordVisibility,
            ),
            obscureText: AuthCubit.get(context).isPasswordShown,
          ),
          DefaultTextField(
            controller: confirmPasswordController,
            hint: 'Write Password Again',
            type: TextInputType.visiblePassword,
            suffixIcon: IconButton(
              icon: Icon(AuthCubit.get(context).suffix),
              onPressed: AuthCubit.get(context).changePasswordVisibility,
            ),
            obscureText: AuthCubit.get(context).isPasswordShown,
          ),
          swapBetweenForms(context),
          DefaultButton(
            title: 'SIGN UP',
            buttonColor: MyColors.lemon,
            onTap: (){
              if(passwordController.text == confirmPasswordController.text){
                if(signUpFormKey.currentState!.validate()){
                  AuthCubit.get(context).createUserWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text
                  ) ;
                }
              }else{
                showToast(message: 'passwords does not match');
              }

            },

          ),
          const SizedBox(height: 10,),
          buildContinueWithWidget(context),

        ],
      ),
    );
  }


}
