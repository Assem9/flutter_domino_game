
abstract class AuthStates {}

class AuthInitialState extends AuthStates {}

class DataLoadingState extends AuthStates {}

class UserEmailVerified extends AuthStates {}

class EmailVerifyingError extends AuthStates {}

class VerificationLinkReSent extends AuthStates {}

class AuthenticatedEmailDeleted extends AuthStates {}

class UserSignedIn extends AuthStates {}

class UserSigningInError extends AuthStates {}

class ChangePasswordVisibilityState extends AuthStates{}

class UserSignedOut extends AuthStates {}

class UserSigningOutError extends AuthStates {}

class SwappedBetweenLoginAndRegister extends AuthStates {}

class UserSignedUp extends AuthStates {}

class UserSigningUpError extends AuthStates {}

class UserSignedWithFacebookOrGoogle extends AuthStates {}

class UserAuthenticationError extends AuthStates {}

class FireBaseUnExpectedError extends AuthStates {
  final String errorData ;
  FireBaseUnExpectedError(this.errorData);
}

class FireBaseUnExpectedErrorSentToApi extends AuthStates {}

class UnExpectedErrorDocumentUpdated extends AuthStates {}

