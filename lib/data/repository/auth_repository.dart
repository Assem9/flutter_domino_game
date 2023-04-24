import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../../cacheHelper.dart';
import '../../constants/constants.dart';
import '../../constants/strings.dart';
import '../firestore_services/auth_services.dart';
import '../models/user.dart';

class AuthRepository {
  final AuthServices authServices;

  AuthRepository(this.authServices);

  Future<AppUser?> getUserData(String userId) async {
    try{
      final user = await authServices.getUserDocument(userId: userId) ;
      return AppUser.fromJson(user.data() as Map<String, dynamic>) ;
    }catch(e){
      return null ;
    }
  }

////////////////////////////////
  Future<dynamic> signInWithFacebook() async {
    return await authServices.signInWithFacebook() ;
  }
  Future<AppUser?> signUpWithFacebook() async {
    var userCredential = await authServices.signInWithFacebook();
    // check if this facebook account already has account in fireStore ?
    AppUser? userFromApi = await getUserData(userCredential.user!.uid);
    if(userFromApi != null){
      debugPrint('This Email Already SignedUp');
      return userFromApi;
    }else{
      // if does not exist create new user doc
      AppUser newUser = AppUser(
        name: userCredential.user!.displayName!,
        iD: userCredential.user!.uid,
        email: userCredential.user!.email!,
        photoUrl: userCredential.user!.photoURL!,
        status: UserStatus.online,
        friendsIds: [],
      );
      await authServices.createUserDocInFireStore(newUser);
      return newUser ;
    }
  }

  Future<void> signOut() async {
    authServices.signOutFacebook().then((value) {
      CacheHelper.clearData(key: 'uId');
    });
  }

   ////////////////////////////////////
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  })async{

    await authServices.userSignUpWithEmail(
        email: email,
        password: password
    );
    await authServices.sendVerificationLink() ;
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await
    authServices.signInWithEmail(email: email, password: password);

  }

  Future<void> createUserDocument({
    required UserCredential userCredential,
    required String name,
  }) async {
    AppUser user = AppUser(
      name: name,
      iD: userCredential.user!.uid,
      email: userCredential.user!.email!,
      photoUrl: 'https://firebasestorage.googleapis.com/v0/b/domino-8023b.appspot.com/o/default_avatar.png?alt=media&token=8c9161e4-9e27-464f-9caa-1bdd31065c44',
      status: UserStatus.online,
      friendsIds: [],
    );
    await CacheHelper.saveData(key: 'uId', value: userCredential.user!.uid);
    uId = userCredential.user?.uid;
    debugPrint(user.email);
    return await authServices.createUserDocInFireStore(user);
  }


//////////////////////////////////// Sign in With google ////////////////////////////////////////////////

  Future<UserCredential> signInWithGoogle() async {
    return await authServices.signInWithGoogle() ;
  }
  Future<AppUser?> signUpWithGoogle() async {
    var userCredential = await authServices.signInWithGoogle();
    // check if this facebook account already has account in fireStore ?
    AppUser? userFromApi = await getUserData(userCredential.user!.uid);
    if(userFromApi != null){
      debugPrint('This Email Already SignedUp');
      return userFromApi;
    }else{
      // if does not exist create new user doc
      AppUser newUser = AppUser(
        name: userCredential.user!.displayName!,
        iD: userCredential.user!.uid,
        email: userCredential.user!.email!,
        photoUrl: userCredential.user!.photoURL!,
        status: UserStatus.online,
        friendsIds: [],
      );
      await authServices.createUserDocInFireStore(newUser);
      return newUser ;
    }
  }

}