import 'package:domino_game/cubits/auth_cubit/auth_states.dart';
import 'package:domino_game/data/models/unKnown_error.dart';
import 'package:domino_game/data/models/user.dart';
import 'package:domino_game/data/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cacheHelper.dart';
import '../../constants/components.dart';
import '../../constants/constants.dart';
import '../../constants/strings.dart';
import '../../data/firestore_services/auth_services.dart';

class AuthCubit extends Cubit<AuthStates>{
  AuthCubit(this.authRepository) : super(AuthInitialState());
  static AuthCubit get(context) => BlocProvider.of(context);
  final AuthRepository authRepository ;

  bool showRegister = false ;
  void swapLoginRegister(){
    showRegister = !showRegister;
    emit(SwappedBetweenLoginAndRegister());
  }

  IconData suffix = Icons.visibility_outlined ;
  bool isPasswordShown = true ;
  void changePasswordVisibility() {
    isPasswordShown = !isPasswordShown;
    suffix =isPasswordShown ? Icons.visibility_outlined : Icons.visibility_off_outlined;
    emit(ChangePasswordVisibilityState());
  }

  late UnExpectedError unExpectedError ;
  void onUnExpectedError(String error)async {
    authRepository.createUnExpectedError(errorData: error).then((value){
      unExpectedError = value;
      emit(FireBaseUnExpectedErrorSentToApi()) ;
    }) ;
  }

  void addUserNoteToTheErrorDoc(String userNote)async{
    unExpectedError.userComplain = userNote;
    await AuthServices().addErrorDataDocToFireStore(unExpectedError) ;
    emit(UnExpectedErrorDocumentUpdated());
  }

  ////////////
  bool dataLoading = false ;

  void continueWithFacebook()async{
    dataLoading = true ;
    emit(DataLoadingState());
    try{
      AppUser? user = await authRepository.signUpWithFacebook() ;
      uId = user!.iD ;
      CacheHelper.saveData(key: 'uId', value: user.iD);
      dataLoading = false ;
      emit(UserSignedWithFacebookOrGoogle());

    } on FirebaseAuthException catch (e) {
      dataLoading = false ;
      if (e.code == 'account-exists-with-different-credential') {
        showToast(message:'this account already signed in but different platform ');
        emit(UserAuthenticationError());
      }else{
        emit(FireBaseUnExpectedError(e.toString()));
      }

    }
  }

  void continueWithGoogle()async{
    dataLoading = true ;
    emit(DataLoadingState());
    try{
      AppUser? user = await authRepository.signUpWithGoogle() ;
      uId = user!.iD ;
      await CacheHelper.saveData(key: 'uId', value: user.iD);
      dataLoading = false ;
      emit(UserSignedWithFacebookOrGoogle());

    }on FirebaseAuthException catch (e) {
      dataLoading = false ;
      if (e.code == 'account-exists-with-different-credential') {
        showToast(message:'this account already signed in but different platform ');
        emit(UserAuthenticationError());
      }else{
        emit(FireBaseUnExpectedError(e.toString()));
      }
    }
  }

  Future<void> signInDelay()async{
    await Future.delayed(
        const Duration(seconds: 2), (){
          dataLoading = false ;
          emit(UserSignedIn());
        }
    );
  }
  ////////////////////
  void signInWithEmailAndPassword({
    required String email,
    required String password,
  })async{
    dataLoading = true ;
    emit(DataLoadingState());
    try{
      final userCredential =
      await authRepository.signInWithEmailAndPassword(email: email, password: password);
      await CacheHelper.saveData(key: 'uId', value: userCredential.user!.uid);
      uId = userCredential.user!.uid;
      await signInDelay() ;
    }on FirebaseAuthException catch (e) {
      dataLoading = false ;
      if (e.code == 'user-not-found') {
        showToast(message:'No user found for that email.');
        emit(UserSigningInError());
      }else if(e.code == 'invalid-email'){
        showToast(message:'The email address is badly formatted');
        emit(UserSigningInError());
      }
      else if (e.code == 'wrong-password') {
        showToast(message:'Wrong password provided for that user.');
        emit(UserSigningInError());
      }else{
        emit(FireBaseUnExpectedError(e.toString()));
      }

    }
  }

  void createUserWithEmailAndPassword({
    required String email,
    required String password,
  })async{
    dataLoading = true ;
    emit(DataLoadingState());
    try{
      await authRepository.signUpWithEmail(email: email, password: password);
      dataLoading = false ;
      emit(UserSignedUp());
    }on FirebaseAuthException catch (e) {
      dataLoading = false ;
      if (e.code == 'weak-password') {
        showToast(message:'The password provided is too weak.');
        emit(UserSigningInError());
      } else if (e.code == 'email-already-in-use') {
        showToast(message:'The account already exists for that email.');
        emit(UserSigningInError());
      }else{
        emit(FireBaseUnExpectedError(e.toString()));
      }

    }
  }

  void checkIfEmailIsVerified({
    required String name,
    required String password,
    required String emailAddress ,
  })async{
    dataLoading = true;
    emit(DataLoadingState());
    await authRepository.signInWithEmailAndPassword(
        email: emailAddress,
        password: password
    ).then((value) async{
      final signedUser = FirebaseAuth.instance.currentUser ;
      debugPrint('email is:  ${signedUser!.email}');
      if(signedUser.emailVerified){
        await authRepository.createUserDocument(userCredential: value, name: name) ;
        dataLoading = false;
        emit(UserEmailVerified());
      }else{
        dataLoading = false;
        emit(EmailVerifyingError());
        showToast(message: 'Email Not Verified Yet (Please go to your email and verify your account)') ;
      }
    }) ;

  }

  void deleteAuthenticatedEmail()async{
    await AuthServices().deleteUserAccount().then((value){
      emit(AuthenticatedEmailDeleted());
    }) ;
  }

  void reSendVerificationLink(){
    AuthServices().sendVerificationLink().then((value) {
      emit(VerificationLinkReSent());
    });
  }
  ////////////////

}