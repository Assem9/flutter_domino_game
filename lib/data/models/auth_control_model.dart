class AuthControlSettings{
  late bool facebookAuth ;
  late bool googleAuth ;
  late bool sendVerificationLinkFirst ;
  late bool resetPassword ;

  AuthControlSettings({
    required this.facebookAuth,
    required this.googleAuth,
    required this.sendVerificationLinkFirst
  });

  AuthControlSettings.fromJson(Map<String, dynamic> json){
    facebookAuth = json['facebookAuth'] ;
    googleAuth = json['googleAuth'];
    sendVerificationLinkFirst = json['sendVerificationLinkFirst'];
    resetPassword = json['resetPassword'];
  }
}