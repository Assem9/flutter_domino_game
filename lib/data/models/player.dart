

import 'package:domino_game/data/models/user.dart';

import 'dom_piece.dart';

class DomPlayer extends AppUser{
  late bool isPlaying ;
  late int score ;
  List<DomPiece> pieces = [] ;

  DomPlayer({
    required super.name,
    required super.iD,
    required super.email,
    required super.photoUrl,
    required super.friendsIds,
    required super.status
  }){
    pieces = [] ;
    score = 0;
    isPlaying = false ;
  }

  DomPlayer.fromJson(Map<String,dynamic> json) : super.fromJson(json){
    isPlaying = json['isPlaying'];
    score = json['score'];
    json['pieces'].forEach((element)
    {
      pieces.add(DomPiece.fromJson(element as Map<String,dynamic> ));
    });
  }

  @override
  Map<String, dynamic> toMap(){
    return {
      'name': name,
      'iD': iD,
      'email': email,
      'photo_url': photoUrl,
      'status':status.toJson() ,
      'isPlaying': isPlaying,
      'score': score,
      'pieces': pieces.map((x) => x.toMap()).toList(),
      'friendsIds': friendsIds
    };
  }
}