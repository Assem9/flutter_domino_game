class AppUser {
  late String name ;
  late String iD;
  late String email ;
  late String photoUrl;
  late UserStatus status;
  List<String> friendsIds = [];
  AppUser({
    required this.name,
    required this.iD,
    required this.email,
    required this.photoUrl,
    required this.friendsIds,
    required this.status,
  });

  AppUser.fromJson(Map<String, dynamic> json){
    name = json['name'];
    iD = json['iD'];
    email = json['email'];
    photoUrl = json['photo_url'] ;
    status = StatusX.fromJson(json['status']);
    json['friendsIds'].forEach((element)
    {
      friendsIds.add(element);
    });
  }

  Map<String, dynamic> toMap(){
    return {
      'name': name,
      'iD': iD,
      'email': email,
      'photo_url': photoUrl,
      'friendsIds': friendsIds,
      'status': status.toJson(),
    };
  }
}

enum UserStatus{
  online,
  offline,
  leftMatch,
  inMatch,
  away,
  autoPlay
}

extension StatusX on UserStatus {
  String toJson() {
    switch(this){
      case UserStatus.online:
        return 'online';
      case UserStatus.offline:
        return 'offline';
      case UserStatus.leftMatch:
        return 'left';
      case UserStatus.inMatch:
        return 'inMatch';
      case UserStatus.away:
        return 'away';
      case UserStatus.autoPlay:
        return 'autoPlay';
    }
  }

  static UserStatus fromJson(String json){
    switch(json){
      case 'online':
        return UserStatus.online;
      case 'offline':
        return UserStatus.offline;
      case 'left':
        return UserStatus.leftMatch;
      case 'inMatch':
        return UserStatus.inMatch;
      case 'away':
        return UserStatus.away;
      case 'autoPlay':
        return UserStatus.away;
      default:
        return UserStatus.offline;
    }
  }
}