import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../constants/constants.dart';
import '../../constants/strings.dart';
import '../models/add_friend_request.dart';
import '../models/match_request.dart';
import '../models/user.dart';

class UserFireBaseServices{

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

  Future<void> deleteUserDocument()async{
    return await firesStore.collection('users').doc(uId).delete() ;
  }

  Future<TaskSnapshot> uploadImageInStorage(File profileImage)async{
    return await FirebaseStorage.instance
        .ref()
        .child('users/${Uri.file(profileImage.path).pathSegments.last}')
        .putFile(profileImage);
  }

  Future<String> getStorageURL(TaskSnapshot taskSnapshot)async{
    return await taskSnapshot.ref.getDownloadURL() ;
  }

  Future<void> updateUserStatus({required String status})async{
    return await firesStore
        .collection('users')
        .doc(uId)
        .update({'status':status});
  }
  //////////////////////////////////// Add Friend Request ////////////////////////////////////////////////
  Future<AppUser?> getUserByHisEmail({required String userEmail})async{
    AppUser? user;
    await firesStore.collection('users').get().then((value){
      for(var doc in value.docs){
        if(AppUser.fromJson(doc.data()).email == userEmail){
          user = AppUser.fromJson(doc.data());
          break;
        }
      }

    });
    return user ;

  }

  Future<void> sendFriendRequestToFireStore({
    required AddingFriendRequest request,
    required String friendId ,
  })async{
    return await firesStore
        .collection('users')
        .doc(friendId).collection('friend_requests')
        .doc(request.iD)
        .set(request.toMap());
  }

  Stream<QuerySnapshot<Map<String ,dynamic>>> streamOnFriendRequestsCollection(){
    return firesStore
        .collection('users')
        .doc(uId)
        .collection('friend_requests')
        .where('accepted',isEqualTo: false)
        .snapshots();
  }

  Future<void> updateFriendRequestDoc(AddingFriendRequest request){
    return firesStore
        .collection('users')
        .doc(uId)
        .collection('friend_requests')
        .doc(request.iD)
        .update(request.toMap());
  }

  Future<void> deleteFriendRequestDoc(String reqId){
    return firesStore
        .collection('users')
        .doc(uId)
        .collection('friend_requests')
        .doc(reqId)
        .delete();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamOnMyFriendData(String id){
    return firesStore
        .collection('users')
        .doc(id)
        .snapshots();
  }

  //////////////////////////////////// Public Match Request //////////////////////////////////////////////

  Future<void> addNewRequestToFireStore(MatchRequest request)async{
    return await firesStore.collection('requests').doc(request.iD).set(request.toMap());
  }

  Future<void> updateMatchRequestDoc(MatchRequest request)async{
    await firesStore
        .collection('requests')
        .doc(request.iD)
        .update(request.toMap());
  }

  Future<void> deletePublicMatchRequestDoc({
    required String requestId,
  })async{
    await firesStore
        .collection('requests')
        .doc(requestId)
        .delete();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamMyPublicMatchRequest(String id){
    return firesStore
        .collection('requests')
        .doc(id)
        .snapshots() ;
  }

  Stream<QuerySnapshot<Map<String ,dynamic>>> streamOnRequestsCollection(){
    return firesStore.collection('requests')
        .where('completed',isEqualTo: false)
        .snapshots() ;
  }

//////////////////////////////////// Friend Match Request //////////////////////////////////////////////

  Future<void> sendMatchRequestToFriend({
    required MatchRequest request,
    required String friendId
  })async{
    return await firesStore.collection('users')
        .doc(friendId)
        .collection('match_requests')
        .doc(request.iD)
        .set(request.toMap());
  }

  Future<void> updateFriendMatchRequestDoc({
    required FriendMatchRequest request,
    required String userId
  })async{
    await firesStore
        .collection('users')
        .doc(userId)
        .collection('match_requests')
        .doc(request.iD)
        .update(request.toMap());
  }

  Future<void> deleteFriendMatchRequestDoc({
    required String requestId,
    required String friendId
  })async{
    await firesStore
        .collection('users')
        .doc(friendId)
        .collection('match_requests')
        .doc(requestId)
        .delete();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamOnFriendMatchRequest({
  required String requestId,
  required String friendId
  }){
    return firesStore
        .collection('users')
        .doc(friendId)
        .collection('match_requests')
        .doc(requestId)
        .snapshots() ;
  }

  Stream<QuerySnapshot<Map<String ,dynamic>>> streamOnMyMatchRequests(){
    return firesStore
        .collection('users')
        .doc(uId)
        .collection('match_requests')
        .where('completed',isEqualTo: false)
        .snapshots() ;
  }
  //////////////////////////////////////////////////////////////

}