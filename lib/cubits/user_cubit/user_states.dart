import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

import '../../data/models/user.dart';

abstract class UserStates {}

class UserInitialState extends UserStates {}

class InterNetState extends UserStates {}

class UserCreated extends UserStates {}

class UserCreatingError extends UserStates {}

class UserSigningIn extends UserStates {}

class UserSignedIn extends UserStates {}

class UserSigningInError extends UserStates {}

class UserSigningOut extends UserStates {}

class UserSignedOut extends UserStates {}

class UserSigningOutError extends UserStates {}

class SwappedBetweenLoginAndRegister extends UserStates {}

class UserCreatedWithFacebook extends UserStates {}

class UserDataLoaded extends UserStates {}

class UserDataUpdated extends UserStates {}

class UserDataUpdatingError extends UserStates {}

class UserDataLoadingError extends UserStates {}

class UserUploadedPhoto extends UserStates {}

class EditProfileImageCanceled extends UserStates {}

class UserFriendsListLoaded extends UserStates {}

class UserFriendsListLoadingError extends UserStates {}

class AddFriendRequestSent extends UserStates {}

class WrongEmail extends UserStates {}

class AddingFriendRequestDeclined extends UserStates {}

class AddingFriendRequestAccepted extends UserStates {}

class AcceptingFriendRequestError extends UserStates {}

class WidgetShowed extends UserStates {}

class RequestCreated extends UserStates {}

class RequestCreatingError extends UserStates {}

class DeletingRequest extends UserStates {}

class RequestDeleted extends UserStates {}

class DeletingRequestError extends UserStates {}

class RequestDeclined extends UserStates {}

class RequestUpdated extends UserStates {}

class RequestUpdatingError extends UserStates {}

class LoadingRequests extends UserStates {}

class AllRequestsLoaded extends UserStates {}

class RequestPlayerListIsComplete extends UserStates {
  final List<AppUser> joiners ;

  RequestPlayerListIsComplete(this.joiners);
}

class UserJoiningRequestError extends UserStates {}

class SearchDurationEnded extends UserStates {}

class SearchDurationWorking extends UserStates {}

class OpponentJoinedRequest extends UserStates {}

class OpponentInitializedMatch extends UserStates {}

class UserJoinedRequest extends UserStates {}

class MatchIdAddedToRequestDocument extends UserStates {}

class MatchIdAddingErrorToRequestDocument extends UserStates {}
