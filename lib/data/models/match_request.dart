class MatchRequest{
  late String iD ;
  String? matchId ;
  late String date ;
  List<String> playersIds = [];
  late bool completed ;
  late bool isTeamMatch ; // false is (1 v 1) true is (2 v 2)
  late bool matchIsInitialized ;

  MatchRequest({
    required this.iD ,
    required this.matchId ,
    required this.completed,
    required this.isTeamMatch,
    required this.date,
    required this.matchIsInitialized,
    required this.playersIds
  });
  MatchRequest.fromJson(Map<String,dynamic> json){
    json['playersIds'].forEach((element)
    {
      playersIds.add(element.toString());
    });
    completed = json['completed'];
    isTeamMatch = json['isTeamMatch'];
    matchIsInitialized = json['matchIsInitialized'];
    iD = json['iD'];
    matchId = json['matchId'];
    date = json['date'];
  }

  Map<String, dynamic> toMap(){
    return {
      'playersIds': playersIds,
      'completed': completed,
      'isTeamMatch': isTeamMatch,
      'matchIsInitialized': matchIsInitialized,
      'iD': iD,
      'matchId': matchId,
      'date': date,
    };
  }

}

////////////

class FriendMatchRequest extends MatchRequest{
  late bool declined ;
  late String requestCreator ;
  FriendMatchRequest({
    required super.iD,
    required super.matchId,
    required super.completed,
    required super.isTeamMatch,
    required super.date,
    required super.matchIsInitialized,
    required super.playersIds,
    required  this.requestCreator,
    required this.declined
  });

  FriendMatchRequest.fromJson(Map<String,dynamic> json) : super.fromJson(json){
    declined = json['declined'];
    requestCreator = json['requestCreator'];
  }


  @override
  Map<String, dynamic> toMap() {
   return {
     'playersIds': playersIds,
     'completed': completed,
     'isTeamMatch': isTeamMatch,
     'matchIsInitialized': matchIsInitialized,
     'iD': iD,
     'matchId': matchId,
     'date': date,
     'declined': declined,
     'requestCreator': requestCreator
    } ;
    //return super.toMap();
  }
}
