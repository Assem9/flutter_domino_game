enum MatchState {
  NOTREADY ,
  ONGOING,
  PAUSED,
  GAMEOVER,
  DISCONNECTED ;
}

extension StateX on MatchState {

  String toJson() {
    switch(this){
      case MatchState.NOTREADY:
        return 'Getting Ready' ;
      case MatchState.ONGOING :
        return 'ONGOING' ;
      case MatchState.PAUSED :
        return 'Paused' ;
      case MatchState.GAMEOVER :
        return 'Game Over' ;
      case MatchState.DISCONNECTED :
        return 'Disconnected' ;
    }
  }

  static MatchState fromDbCode(String json){
    switch(json){
      case 'Getting Ready':
        return MatchState.NOTREADY ;
      case 'ONGOING':
        return MatchState.ONGOING ;
      case 'Paused' :
        return MatchState.PAUSED  ;
      case 'Game Over' :
        return MatchState.GAMEOVER ;
      case 'Disconnected' :
        return MatchState.DISCONNECTED  ;
      default:
        return MatchState.NOTREADY;

    }
  }
}

enum MatchMode {
  ROUND ,
  FULLMATCH ,
  ASHOKROUND ,
  ASHOKFULLMATCH ,
}

extension ModeX on MatchMode {

  String toJson() {
    switch(this){
      case MatchMode.ROUND:
        return 'Normal One Round' ;
      case MatchMode.FULLMATCH :
        return 'Normal Full Match' ;
      case MatchMode.ASHOKROUND :
        return 'Ashok One Round' ;
      case MatchMode.ASHOKFULLMATCH :
        return 'Ashok Full Match' ;
      default:
        return 'UnKnown' ;
    }
  }

  static MatchMode fromJson(String json){
    switch(json){
      case 'Normal One Round':
        return MatchMode.ROUND ;
      case 'Normal Full Match'  :
        return MatchMode.FULLMATCH  ;
      case 'Ashok One Round' :
        return MatchMode.ASHOKROUND  ;
      case 'Ashok Full Match' :
        return MatchMode.ASHOKFULLMATCH  ;
      default:
        return MatchMode.ROUND;

    }
  }
}