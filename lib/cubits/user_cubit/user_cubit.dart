import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domino_game/cacheHelper.dart';
import 'package:domino_game/constants/components.dart';
import 'package:domino_game/constants/strings.dart';
import 'package:domino_game/cubits/user_cubit/user_states.dart';
import 'package:domino_game/data/firestore_services/auth_services.dart';
import 'package:domino_game/data/firestore_services/user_firebase_services.dart';
import 'package:domino_game/data/models/add_friend_request.dart';
import 'package:domino_game/data/repository/auth_repository.dart';
import 'package:domino_game/data/repository/user_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/constants.dart';
import '../../data/models/match_request.dart';
import '../../data/models/user.dart';

class UserCubit extends Cubit<UserStates> {
  UserCubit(this.userRepository) : super(UserInitialState());
  static UserCubit get(context) => BlocProvider.of(context) ;
  final UserRepository userRepository ;

  AppUser? user ;
  bool userSigningOut = false ;
  void signOut(){
    userSigningOut = true ;
    emit(UserSigningOut());
    AuthRepository(AuthServices()).signOut().then((value)async{
      uId = null ;
      await CacheHelper.clearData(key: 'uId');
      user = null ;
      await Future.delayed(const Duration(seconds: 2),(){

        emit(UserSignedOut());
      });

    }).catchError((e){
      debugPrint('sihn out $e') ;
      emit(UserSigningOutError());
    });
  }

  void getUser(String? userId){
    if(userId != null){
      userRepository.getUserData(userId).then((value){
        user = value ;
        debugPrint(user!.name) ;
        uId = user!.iD;
        userSigningOut = false ;
        emit(UserDataLoaded());
      }).catchError((e){
        debugPrint('get user error $e') ;
        emit(UserDataLoadingError());
      });
    }

  }
 ////////////////////////////// edit User Data /////////////////////////////////////
  void updateUserData(AppUser updatedUser)async{
    try{
      await UserFireBaseServices().createUserDocInFireStore(updatedUser) ;
      emit(UserDataUpdated());
    }catch(e){
      debugPrint('$e');
      emit(UserDataUpdatingError());
    }

  }

  void updateUserName(String newName){
    user!.name = newName ;
    updateUserData(user!);
  }

  void updateUserPhoto()async{
    try{
      String newPhoto = await userRepository.getImageLink(profileImage!) ;
      user!.photoUrl = newPhoto ;
      updateUserData(user!);
    }catch(e){
      debugPrint('$e') ;
    }

  }

  void cancelEditingImage(){
    profileImage = null ;
    emit(EditProfileImageCanceled());
  }

  var picker = ImagePicker();

  File? profileImage;
  Future getProfileImage() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery
    );

    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
       emit(UserUploadedPhoto());
    }
  }

  void updateUserStatus(UserStatus status){
    user!.status = status  ;
    updateUserData(user!) ;
  }

  ////////////////////////////// Friends Data /////////////////////////////////////

  Map<String,AppUser> myFriendsListWithId = {};
  void getFriends(){
    myFriendsListWithId = {} ;
    userRepository.getUserFriends(user!.friendsIds).then((value){
      //myFriendsList = value ;
      myFriendsListWithId = value ;
      emit(UserFriendsListLoaded());
    }).catchError((e){
      debugPrint('$e') ;
      emit(UserFriendsListLoadingError());
    });
  }

  void listenFriendData(AsyncSnapshot<DocumentSnapshot> snapshot){
    if (snapshot.hasError) {
      debugPrint('Something went wrong');
    } else if(snapshot.hasData){
      AppUser friend = AppUser.fromJson(snapshot.data!.data() as Map<String, dynamic>) ;
      myFriendsListWithId[friend.iD]  = friend ;
      //emit(UserDataLoaded());
      debugPrint(friend.status.toString() );
    }

  }

  bool friendsAndRequestsScreenIsShown = false ;
  void showFriendsAndRequestsScreen(){
    friendsAndRequestsScreenIsShown = !friendsAndRequestsScreenIsShown;
    emit(WidgetShowed());
  }

  bool friendsListIsShown = true ;
  void showFriendsList(bool value){
    friendsListIsShown = value;
    emit(WidgetShowed());
  }

  ///////////////////////////////////////////////// Add Friend Request Logic //////////////////////////////////////

  void sendFriendRequest({required String email})async{
    AppUser? chosenUser ;
    chosenUser = await UserFireBaseServices().getUserByHisEmail(userEmail: email);
    if(chosenUser !=null){
      if(!checkIfUserAlreadyIsFriend(chosenUser.iD)){
        await userRepository.sendFriendRequest(requestCreator: user!, friendId: chosenUser.iD ) ;
        showToast(message: 'Request Sent');
        emit(AddFriendRequestSent());
      }else{
        showToast(message: '${chosenUser.email } is Already in your friends ');
      }

    }else{
      showToast(message: 'There are no user with that email ');
      emit(WrongEmail());
    }


  }

  void acceptFriendRequest(AddingFriendRequest request){
    userRepository.addUsersIdsToFireStore(requestSenderId: request.requestSender.iD, user: user!).then((value)async{
      await userRepository.acceptFriendRequest(request);
      emit(AddingFriendRequestAccepted());
    }).catchError((e){
      debugPrint('$e');
      emit(AcceptingFriendRequestError());
    }) ;

  }

  void declineFriendRequest(String reqId)async{
    await UserFireBaseServices().deleteFriendRequestDoc(reqId).then((value) {
      emit(AddingFriendRequestDeclined()) ;
    });
  }

  bool checkIfUserAlreadyIsFriend(friendId){
    if(user!.friendsIds.contains(friendId)){
      return true ;
    }else{
      return false ;
    }
  }

  List<AddingFriendRequest> friendRequestsList = [] ;
  void listenOnMyFriendRequestsListStream( AsyncSnapshot<QuerySnapshot> snapshot){
    friendRequestsList = [] ;
    emit(LoadingRequests()) ;
    if(snapshot.hasData){
      for(var element in snapshot.data!.docs){
        friendRequestsList.add(AddingFriendRequest.fromJson(element.data() as Map<String ,dynamic>));
      }
      emit(AllRequestsLoaded());
    }
  }

  //////////////////////////////// ( request - Join ) Hosting logic //////////////////////////////////////////////
  MatchRequest? matchRequest ;

  void addMatchRequest()async{
    try{
      matchRequest = await userRepository.createNewRequest(requestCreator: user!);
      emit(RequestCreated());
    }catch(e){
      debugPrint('$e');
      emit(RequestCreatingError());
    }
  }

  void listenOnMyPublicMatchRequestStream(context,AsyncSnapshot<DocumentSnapshot> snapshot)async{
    if (snapshot.hasError) {
      debugPrint('Something went wrong');
    } else if (snapshot.connectionState == ConnectionState.waiting) {
      debugPrint("Loading");
    } else if(snapshot.hasData){
      matchRequest = MatchRequest.fromJson(snapshot.data!.data()! as Map<String, dynamic>);
      checkIfMatchRequestIsCompleted(matchRequest!) ;
      debugPrint(matchRequest!.completed.toString() );
    }

  }

  void checkIfMatchRequestIsCompleted(MatchRequest request)async{
    if(request.completed){
      List<AppUser> joiners =[user!,];
      for(String userId in request.playersIds){
        AppUser opponent = await userRepository.getUserData(userId);
        joiners.add(opponent);
      }
      requestSent = false ;
      emit(RequestPlayerListIsComplete(joiners));
      //  createOnline
    }
  }

  void cancelPublicMatchRequest(context)async{
    try{
      emit(DeletingRequest());
      await UserFireBaseServices().deletePublicMatchRequestDoc(requestId: matchRequest!.iD) ;
      Navigator.pop(context) ;
      emit(RequestDeleted());
    }catch(e){
      debugPrint('$e') ;
      emit(DeletingRequestError()) ;
    }

  }

  void streamOnFoundedRequest(context,AsyncSnapshot<DocumentSnapshot> snapshot){
    if (snapshot.hasError) {
      debugPrint('Something went wrong');
    } else if (snapshot.connectionState == ConnectionState.waiting) {
      debugPrint("Loading");
    } else if(snapshot.hasData){
      joinedRequest = MatchRequest.fromJson(snapshot.data!.data()! as Map<String, dynamic>);
      // joiner(who find request and join)
      // stream only while matchId = null
      if(joinedRequest!.matchId != null){
        emit(OpponentInitializedMatch());
      }
      debugPrint(joinedRequest!.completed.toString() );
    }

  }

  void updateRequest(MatchRequest request)async{
    try{
      await UserFireBaseServices().updateRequestDoc(request);
      emit(RequestUpdated());
    }catch(e){
      debugPrint('$e');
      emit(RequestUpdatingError());
    }

  }

  void joinRequest() {
    if(!joinedRequest!.isTeamMatch){
      joinedRequest!.completed = true ;
      joinedRequest!.playersIds.add(user!.iD);
      updateRequest(joinedRequest!);
    }else{
      // check if list length is 4 if true => update complete else just add your id
    }
    emit(UserJoinedRequest());

  }

  bool requestFound = false ;
  MatchRequest? joinedRequest ;
  late StreamSubscription subscription ;
  void getFireStoreMatchRequests()async{
    emit(LoadingRequests()) ;
    requestFound = false ;
    subscription =
    UserFireBaseServices().streamOnRequestsCollection().listen((event) {
      for (var element in event.docs) {
        joinedRequest = MatchRequest.fromJson(element.data());
        joinRequest();
        requestFound = true ;
        debugPrint(joinedRequest?.iD);
        subscription.cancel();

        emit(AllRequestsLoaded());
        break ;
      }
    });

  }
  // countDown code ;
  Duration myDuration = const Duration(seconds: 10);
  Timer? countDownTimer ;
  bool durationEnded = false;
  void startTimer(){
    durationEnded = false;
    myDuration = const Duration(seconds: 10);
    countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer)=> setCountDown ());
  }

  void stopTimer(){
    countDownTimer!.cancel();
  }

  void setCountDown (){
    const reduceSecondsBy = 1 ;
    if(requestFound && joinedRequest != null){
      durationEnded = true ;
      stopTimer();
    }
    int seconds =  myDuration.inSeconds - reduceSecondsBy ;
    debugPrint('myDuration $myDuration');
     if(seconds < 0){
       durationEnded = true ;
       stopTimer();
       subscription.cancel() ;
       emit(SearchDurationEnded());
     }else{
       myDuration = Duration(seconds: seconds);
       emit(SearchDurationWorking());
     }
  }

   /////////////////////////// Friend Match Request ////////////////////////////////

  bool requestSent = false ;
  late AppUser myFriend ;
  late FriendMatchRequest friendMatchRequest ;
  void sendMatchRequest(AppUser friend){
    userRepository.sendMatchRequestToFriend(requestCreator: user!, friendId: friend.iD).then((value) {
      friendMatchRequest = value ;
      myFriend = friend ;
      requestSent = true ;
      emit(RequestCreated());
    }).catchError((e){
      debugPrint('$e');
      emit(RequestCreatingError());
    });
  }

  void cancelFriendMatchRequest()async{
    try{
      requestSent = false ;
      emit(DeletingRequest());
      await UserFireBaseServices().deleteFriendMatchRequestDoc(
          friendId: myFriend.iD,
          requestId: friendMatchRequest.iD
      ) ;
      emit(RequestDeleted());
    }catch(e){
      debugPrint('$e') ;
      emit(DeletingRequestError()) ;
    }

  }

  // Not Tested
  void declineMatchRequest({required FriendMatchRequest request})async{
    try{
      await userRepository.declineFriendMatchRequest(request: request);
      emit(RequestDeleted());
    }catch(e){
      debugPrint('$e') ;
    }

  }

  // Not Tested
  void checkIfFriendDeclinedMatchRequest(){
    if(friendMatchRequest.declined){
      emit(RequestDeclined()) ;
    }
  }

  List<FriendMatchRequest> friendsMatchRequests = [] ;
  void listenOnMyMatchRequestsListStream( AsyncSnapshot<QuerySnapshot> snapshot){
    friendsMatchRequests = [] ;
    emit(LoadingRequests()) ;
    if(snapshot.hasData){
      for(var element in snapshot.data!.docs){
        friendsMatchRequests.add(FriendMatchRequest.fromJson(element.data() as Map<String ,dynamic>));
      }
      emit(AllRequestsLoaded());
    }
  }

  bool requestAccepted = false ;
  void acceptMatchRequest({required FriendMatchRequest acceptedRequest})async{
    friendMatchRequest = acceptedRequest ;
    friendMatchRequest.completed = true ;
    friendMatchRequest.playersIds.add(user!.iD);
    requestAccepted = true ;
    updateFriendMatchRequest(request: friendMatchRequest, userId: uId) ;
    debugPrint(friendMatchRequest.iD);
  }

  void listenOnAcceptedMatchRequestStream(context,AsyncSnapshot<DocumentSnapshot> snapshot){
    if (snapshot.hasError) {
      debugPrint('Something went wrong');
    } else if (snapshot.connectionState == ConnectionState.waiting) {
      debugPrint("Loading");
    } else if(snapshot.hasData){
      friendMatchRequest = FriendMatchRequest.fromJson(snapshot.data!.data()! as Map<String, dynamic>);
      if(friendMatchRequest.matchId!= null){
        requestAccepted = false ;
        emit(OpponentInitializedMatch());
      }
      debugPrint(friendMatchRequest.completed.toString() );
    }

  }

  void updateFriendMatchRequest({
    required FriendMatchRequest request,
    required userId
  })async{
    try{
      await UserFireBaseServices().updateFriendMatchRequestDoc(request: request, userId: userId);
      emit(RequestUpdated());
    }catch(e){
      debugPrint('$e');
      emit(RequestUpdatingError());
    }

  }

  void listenOnSentMatchRequestStream(context,AsyncSnapshot<DocumentSnapshot> snapshot)async{
    if (snapshot.hasError) {
      debugPrint('Something went wrong');
    } else if (snapshot.connectionState == ConnectionState.waiting) {
      debugPrint("Loading");
    } else if(snapshot.hasData){
      friendMatchRequest = FriendMatchRequest.fromJson(snapshot.data!.data()! as Map<String, dynamic>);
      checkIfMatchRequestIsCompleted(friendMatchRequest) ;
      checkIfFriendDeclinedMatchRequest() ;
      debugPrint(friendMatchRequest.completed.toString() );
    }

  }

  void addMatchIdToFriendRequest({required String matchId}) async{
    try{
      friendMatchRequest.matchId = matchId ;
      friendMatchRequest.matchIsInitialized = true ;
      updateFriendMatchRequest(request: friendMatchRequest, userId: myFriend.iD);
      emit(MatchIdAddedToRequestDocument());
    }catch(e){
      debugPrint('$e');
      emit(MatchIdAddingErrorToRequestDocument());
    }

  }

  void streamOnAcceptedRequest(){
    UserFireBaseServices()
        .streamOnFriendMatchRequest(
        requestId: friendMatchRequest.iD,
        friendId: myFriend.iD
    );
  }

}
