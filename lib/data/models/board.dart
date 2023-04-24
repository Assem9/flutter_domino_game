import 'dom_piece.dart';

class Board{
  int? leftTarget ;
  int? rightTarget ;
  List<DomPiece> inBoardPieces  = [];
  List<DomPiece> outBoardPieces = [];

  Board(){
    inBoardPieces = [];
    outBoardPieces = [];
    initializePieces();
  }
  Board.fromJson(Map<String,dynamic> json){
    leftTarget =  json['boardLeftValue']  ;
    rightTarget = json['boardRightValue']  ;
    json['inBoardPieces'].forEach((element)
    {
      inBoardPieces.add(DomPiece.fromJson(element as Map<String,dynamic> ));
    });
    json['outBoardPieces'].forEach((element)
    {
      outBoardPieces.add(DomPiece.fromJson(element as Map<String,dynamic> ));
    });
  }

  Map<String, dynamic> toMap(){
    return {
      'boardLeftValue': leftTarget ,
      'boardRightValue': rightTarget ,
      'inBoardPieces': inBoardPieces.map((x) => x.toMap()).toList(),
      'outBoardPieces': outBoardPieces.map((x) => x.toMap()).toList(),
    };
  }

  void initializePieces(){
    DomPiece p0_0 = DomPiece('p0_0', HalfDom("p0_0_l",0), HalfDom("p0_0_r",0));
    DomPiece p0_1 =  DomPiece('p0_1', HalfDom("p0_1_l",0), HalfDom("p0_1_r",1));
    DomPiece p0_2 =  DomPiece('p0_2', HalfDom("p0_2_l",0), HalfDom("p0_2_r",2));
    DomPiece p0_3 =  DomPiece('p0_3', HalfDom("p0_3_l",0), HalfDom("p0_3_r",3));
    DomPiece p0_4 =  DomPiece('p0_4', HalfDom("p0_4_l",0), HalfDom("p0_4_r",4));
    DomPiece p0_5 =  DomPiece('p0_5', HalfDom("p0_5_l",0), HalfDom("p0_5_r",5));
    DomPiece p0_6 =  DomPiece('p0_6', HalfDom("p0_6_l",0), HalfDom("p0_6_r",6));
    DomPiece p1_1 =  DomPiece('p1_1', HalfDom("p1_1_l",1), HalfDom("p1_1_r",1));
    DomPiece p1_2 =  DomPiece('p1_2', HalfDom("p1_2_l",1), HalfDom("p1_2_r",2));
    DomPiece p1_3 =  DomPiece('p1_3', HalfDom("p1_3_l",1), HalfDom("p1_3_r",3));
    DomPiece p1_4 =  DomPiece('p1_4', HalfDom("p1_4_l",1), HalfDom("p1_4_r",4));
    DomPiece p1_5 =  DomPiece('p1_5', HalfDom("p1_5_l",1), HalfDom("p1_5_r",5));
    DomPiece p1_6 =  DomPiece('p1_6', HalfDom("p1_6_l",1), HalfDom("p1_6_r",6));
    DomPiece p2_2 =  DomPiece('p2_2', HalfDom("p2_2_l",2), HalfDom("p2_2_r",2));
    DomPiece p2_3 =  DomPiece('p2_3', HalfDom("p2_3_l",2), HalfDom("p2_3_r",3));
    DomPiece p2_4 =  DomPiece('p2_4', HalfDom("p2_4_l",2), HalfDom("p2_4_r",4));
    DomPiece p2_5 =  DomPiece('p2_5', HalfDom("p2_5_l",2), HalfDom("p2_5_r",5));
    DomPiece p2_6 =  DomPiece('p2_6', HalfDom("p2_6_l",2), HalfDom("p2_6_r",6));
    DomPiece p3_3 =  DomPiece('p3_3', HalfDom("p3_3_l",3), HalfDom("p3_3_r",3));
    DomPiece p3_4 =  DomPiece('p3_4', HalfDom("p3_4_l",3), HalfDom("p3_4_r",4));
    DomPiece p3_5 =  DomPiece('p3_5', HalfDom("p3_5_l",3), HalfDom("p3_5_r",5));
    DomPiece p3_6 =  DomPiece('p3_6', HalfDom("p3_6_l",3), HalfDom("p3_6_r",6));
    DomPiece p4_4 =  DomPiece('p4_4', HalfDom("p4_4_l",4), HalfDom("p4_4_r",4));
    DomPiece p4_5 =  DomPiece('p4_5', HalfDom("p4_5_l",4), HalfDom("p4_5_r",5));
    DomPiece p4_6 =  DomPiece('p4_6', HalfDom("p4_6_l",4), HalfDom("p4_6_r",6));
    DomPiece p5_5 =  DomPiece('p5_5', HalfDom("p5_5_l",5), HalfDom("p5_5_r",5));
    DomPiece p5_6 =  DomPiece('p5_6', HalfDom("p5_6_l",5), HalfDom("p5_6_r",6));
    DomPiece p6_6 =  DomPiece('p6_6', HalfDom("p6_6_l",6), HalfDom("p6_6_r",6));
    outBoardPieces = [
      p0_0,p0_1,p0_2,p0_3,p0_4,p0_5,p0_6,p1_1,p1_2,p1_3, p1_4,p1_5, p1_6,p2_2,
      p2_3,p2_4,p2_5,p2_6,p3_3,p3_4,p3_5,p3_6,p4_4,p4_5,p4_6,p5_5,p5_6,p6_6
    ];

  }
}


