import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user.dart';


//-ktx
class AuthServices{

  FirebaseFirestore firesStore = FirebaseFirestore.instance ;
  FirebaseAuth firebaseAuth =FirebaseAuth.instance ;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument({
    required String userId
  }) async{
    return firesStore.collection('users').doc(userId).get() ;
  }

  Future<void> createUserDocInFireStore(AppUser user)async{
    return await firesStore
        .collection('users')
        .doc(user.iD)
        .set(user.toMap());
  }

///////////////////////////////// Sign in With Facebook ///////////////////////////////////////////////

  Future<UserCredential> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    final OAuthCredential facebookAuthCredential =
    FacebookAuthProvider.credential(loginResult.accessToken!.token);

    return firebaseAuth.signInWithCredential(facebookAuthCredential) ;
  }

  Future<void> signOutFacebook() async {
    await FacebookAuth.instance.logOut();
    await firebaseAuth.signOut();
  }


  ///////////////////////////////// Sign in With Email And Password ///////////////////////////////////////////////

  Future<UserCredential> signInWithEmail({
    required String email ,
    required String password
  }) async {
    return firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
    ) ;
  }

  Future<UserCredential> userSignUpWithEmail({
    required String email,
    required String password
  })async{
    return await firebaseAuth.
    createUserWithEmailAndPassword(
        email:email,
        password:password
    );
  }

  Future<void> sendVerificationLink()async{
    User? user = firebaseAuth.currentUser;
    if (user!= null) {
      debugPrint('link sent');
      await user.sendEmailVerification();
    }
  }

  Future<void> deleteUserAccount()async{
    return  await FirebaseAuth.instance.currentUser!.delete();
  }
///////////////////////////////// Sign in With Google ///////////////////////////////////////////////
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

}