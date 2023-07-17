import 'package:domino_game/constants/components.dart';
import 'package:domino_game/constants/my_colors.dart';
import 'package:domino_game/constants/strings.dart';
import 'package:domino_game/cubits/auth_cubit/auth_cubit.dart';
import 'package:domino_game/cubits/auth_cubit/auth_states.dart';
import 'package:domino_game/presentation/widgets/app_logo_widget.dart';
import 'package:domino_game/presentation/widgets/default_button.dart';
import 'package:domino_game/presentation/widgets/textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';


class UnExpectedErrorDataScreen extends StatefulWidget {
  const UnExpectedErrorDataScreen({Key? key, required this.errorData}) : super(key: key);
  final String errorData ;

  @override
  State<UnExpectedErrorDataScreen> createState() => _UnExpectedErrorDataScreenState();
}

class _UnExpectedErrorDataScreenState extends State<UnExpectedErrorDataScreen> {

  final TextEditingController userFeedbackController = TextEditingController();
  final formKey = GlobalKey<FormState>() ;

  @override
  void initState() {
    getPermission();
    super.initState();
  }


  void getPermission()async{
    final status = await Permission.phone.request();
    if (status.isGranted) {
      AuthCubit.get(context).onUnExpectedError(widget.errorData) ;
    }else{
      showToast(message: 'Permission is not granted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: BlocConsumer<AuthCubit,AuthStates>(
              listener: (context,state){
                if(state is UnExpectedErrorDocumentUpdated){
                  showToast(message: 'Your Feedback is sent successfully');
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    firstScreen, (route) => false,
                  );

                }
              },
              builder: (context,state) {
                return Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    SvgPicture.asset(
                      'assets/images/error_warning.svg',
                      fit: BoxFit.contain,
                    ),
                    Align(
                      alignment: AlignmentDirectional.topCenter,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppLogoWidget(radius: 50),
                              const SizedBox(height: 30),
                              Text(
                                'UnKnown Error Happened',
                                style: Theme.of(context).textTheme.displaySmall!.copyWith(color: MyColors.lemon),
                              ),
                              Text(
                                'This problem is sent to the developers, will be fixed soon as possible',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: MyColors.lightBeige),
                              ),
                              const SizedBox(height: 15,),
                              _buildFeedbackForm(context),
                              
                               
                            ],
                          )
                      ),
                    ),
                  ],
                );
              }
          )
      ),
    );
  }

  Widget _buildFeedbackForm(context){
    return Form(
        key: formKey,
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width  ,
              child: DefaultTextField(
                controller: userFeedbackController,
                hint: 'feel free to send us any feedback related to that',
                type: TextInputType.text,
              ),
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                  child: DefaultButton(
                      title: 'Send',
                      width: MediaQuery.of(context).size.width /2,
                      onTap:(){
                        if(formKey.currentState!.validate()){
                          AuthCubit.get(context).addUserNoteToTheErrorDoc(userFeedbackController.text) ;
                        }
                      }
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: DefaultButton(
                      title: 'Back to home',
                      buttonColor: MyColors.blue,
                      onTap: ()=> Navigator.pushNamedAndRemoveUntil(
                        context,
                        firstScreen, (route) => false,
                      )
                  ),
                ) 
              ],
            ),
          ],
        )
    );
  }

}

