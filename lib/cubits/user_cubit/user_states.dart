import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

import '../../data/models/user.dart';

abstract class UserStates {}

class UserInitialState extends UserStates {}

class InterNetState extends UserStates {}

class UserCreated extends UserStates {}

class UserSigningOut extends UserStates {}

class UserSignedOut extends UserStates {}

class UserAccountDeleted extends UserStates {}

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

class AddingFriendRequestDeclined extends UserStates {}

class AddingFriendRequestAccepted extends UserStates {}

class AcceptingFriendRequestError extends UserStates {}

class WidgetShowed extends UserStates {}

class MatchRequestCreated extends UserStates {}

class MatchRequestCreatingError extends UserStates {}

class DeletingMatchRequest extends UserStates {}

class MatchRequestDeleted extends UserStates {}

class MatchDeletingRequestError extends UserStates {}

class MatchRequestDeclined extends UserStates {}

class MatchRequestUpdated extends UserStates {}

class MatchRequestUpdatingError extends UserStates {}

class LoadingMatchRequests extends UserStates {}

class AllMatchRequestsLoaded extends UserStates {}

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
