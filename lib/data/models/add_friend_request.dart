

import 'package:domino_game/data/models/user.dart';

class AddingFriendRequest {
  late String iD ;
  late String date ;
  late AppUser requestSender ;
  late bool accepted ;

  AddingFriendRequest({
    required this.iD,
    required this.date,
    required this.requestSender,
    required this.accepted
  }) ;

  AddingFriendRequest.fromJson(Map<String ,dynamic> json){
    iD = json['iD'];
    date = json['date'];
    requestSender = AppUser.fromJson(json['requestSender']);
    accepted = json['accepted'];
  }

  Map<String, dynamic> toMap(){
    return {
      'iD':iD,
      'date':date,
      'requestSender': requestSender.toMap(),
      'accepted':accepted,
    };
  }

}