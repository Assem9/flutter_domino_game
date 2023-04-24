import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import '../../constants/constants.dart';
import '../../constants/strings.dart';
import '../firestore_services/user_firebase_services.dart';
import '../models/add_friend_request.dart';
import '../models/match_request.dart';
import '../models/user.dart';

class UserRepository {
  final UserFireBaseServices userFireBaseServices ;

  UserRepository(this.userFireBaseServices);

  Future<AppUser> getUserData(String userId)async{
    final user = await userFireBaseServices.getUserDocument(userId: userId);

    return AppUser.fromJson(user.data() as Map<String,dynamic>)  ;
  }

  Future<String> getImageLink(File profileImage)async{
    TaskSnapshot value = await userFireBaseServices.uploadImageInStorage(profileImage) ;
    String url = await userFireBaseServices.getStorageURL(value) ;
    return url ;

  }

  Future<Map<String, AppUser>> getUserFriends(List<String> iDs)async{
   // List<AppUser> friends = [];
    Map<String,AppUser> friendsMap ={};
    for(String id in iDs){
     // friends.add(await getUserData(id));
      AppUser user = await getUserData(id) ;
      friendsMap.addAll({id:user}) ;
    }
    return friendsMap;
  }

  AppUser? listenOnFriendData(AsyncSnapshot<DocumentSnapshot> snapshot){
    if (snapshot.hasError) {
      debugPrint('Something went wrong');
      return null;
    } else if(snapshot.hasData){
      AppUser friend = AppUser.fromJson(snapshot.data!.data() as Map<String, dynamic>) ;
      debugPrint(friend.status.toString() );
      return friend ;
    }else{
      return null ;
    }


  }

  //////////////////////////////////// Add Friend Request ////////////////////////////////////////////////

  Future<void> sendFriendRequest({
    required AppUser requestCreator,
    required String friendId,
  }) async{
    AddingFriendRequest newRequest = AddingFriendRequest(
        iD: 'from: ${requestCreator.email}', // so cant send more than one request to the same person
        date: DateTime.now().toString(),
        requestSender: requestCreator,
        accepted: false
    ) ;
    await userFireBaseServices.sendFriendRequestToFireStore(request: newRequest, friendId: friendId);
  }

  Future<void> acceptFriendRequest(AddingFriendRequest request)async{
    request.accepted = true ;
    await userFireBaseServices.updateFriendRequestDoc(request);
  }

  Future<void> addUsersIdsToFireStore({
    required String requestSenderId,
    required AppUser user
  })async{
    // add requestSender to my doc
    user.friendsIds.add(requestSenderId);
    await userFireBaseServices.createUserDocInFireStore(user);
    // add my id to the requestSender List
    AppUser requestSender = await getUserData(requestSenderId) ;
    requestSender.friendsIds.add(user.iD);
    await userFireBaseServices.createUserDocInFireStore(requestSender);
  }


  //////////////////////////////////////////////// Public Requests ///////////////////////////////////////

  String generateUniqueId(String text ){
    // email cus its unique to each user and the exact Date time
    String month = DateTime.now().month.toString();
    String day = DateTime.now().day.toString();
    String hour = DateTime.now().hour.toString();
    String second = DateTime.now().second.toString();
    String id = text + month + day + hour + second;
    return id ;
  }

  Future<MatchRequest> createNewRequest({required AppUser requestCreator}) async{
    MatchRequest newRequest = MatchRequest(
      completed: false,
      matchIsInitialized: false,
      date: '${DateTime.now()}',
      iD: generateUniqueId(requestCreator.email),
      matchId: null,
      isTeamMatch: false,
      playersIds: [],
      //requestCreator: requestCreator.name,

    ) ;
    await userFireBaseServices.addNewRequestToFireStore(newRequest);
    return newRequest ;
  }

  void addMatchIdToCreatedRequest({
    required MatchRequest request,
    required String matchId,
  }) async{
    request.matchId = matchId ;
    request.matchIsInitialized = true ;
    await userFireBaseServices.updateRequestDoc(request);
  }


//////////////////////////////////////////////// Friends Match Requests ///////////////////////////////////////
  Future<FriendMatchRequest> sendMatchRequestToFriend({
    required AppUser requestCreator,
    required String friendId,
  }) async{
    FriendMatchRequest newRequest = FriendMatchRequest(
      completed: false,
      matchIsInitialized: false,
      date: '${DateTime.now()}',
      iD: generateUniqueId(requestCreator.email),
      matchId: null,
      isTeamMatch: false,
      playersIds: [friendId],
      requestCreator: requestCreator.name,
      declined: false,
    ) ;
    await userFireBaseServices.sendMatchRequestToFriend(request: newRequest, friendId: friendId);
    return newRequest ;
  }

  Future<void> declineFriendMatchRequest({
    required FriendMatchRequest request,
  }) async{
    request.declined = true ;
    await userFireBaseServices.updateFriendMatchRequestDoc(
        request: request,
        userId: uId!
    );
  }

  void addMatchIdToFriendMatchRequest({
    required FriendMatchRequest request,
    required String matchId,
  }) async{
    request.matchId = matchId ;
    request.matchIsInitialized = true ;
    await userFireBaseServices.updateFriendMatchRequestDoc(
        request: request,
        userId: request.playersIds[0]
    );
  }
  ////////////////////////////////////////////////



}

