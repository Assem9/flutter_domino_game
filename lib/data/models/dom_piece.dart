import 'package:flutter/cupertino.dart';

class DomPiece{
  late String iD;
  late double verticalPosition ;
  late HalfDom leftHalf;
  late HalfDom rightHalf;
  //for controlling position in ui
  double? leftPosition ;
  double? rightPosition ;
  late int rotateTurn ;

  DomPiece(this.iD, this.leftHalf, this.rightHalf){
    verticalPosition = 0;
    rotateTurn = 4 ;
  }
  
  void reshapeDom(){
    HalfDom substitution = leftHalf;
    leftHalf = rightHalf ;
    rightHalf = substitution ;
    debugPrint('Reshaped');
  }
  DomPiece.fromJson(Map<String,dynamic> json){
    iD = json['iD'];
    verticalPosition = json['verticalPosition'];
    leftPosition = json['leftPosition'];
    rightPosition = json['rightPosition'];
    rotateTurn = json['rotateTurn'];
    leftHalf = HalfDom.fromJson(json['leftHalf']);
    rightHalf = HalfDom.fromJson(json['rightHalf']);
  }

  Map<String, dynamic> toMap(){
    return {
      'iD': iD,
      'verticalPosition': verticalPosition,
      'leftPosition': leftPosition,
      'rightPosition': rightPosition,
      'rotateTurn': rotateTurn,
      'leftHalf': leftHalf.toMap(),
      'rightHalf': rightHalf.toMap(),
    };
  }

}
class HalfDom{
  late String iD;
  late int value ;
  HalfDom(this.iD, this.value);

  HalfDom.fromJson(Map<String,dynamic> json){
    iD = json['iD'];
    value = json['value'];
  }

  Map<String, dynamic> toMap(){
    return {
      'iD': iD,
      'value': value
    };
  }
}