import 'package:device_information/device_information.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/components.dart';

class UnExpectedError{
  late String iD ;
  late String errorData ;
  late String userComplain ;
  late String date ;
  late String platformVersion ;
  late String deviceName ; //modelName - manufacturer
  late String cpuType ;

  UnExpectedError({
    required this.errorData,
    required this.userComplain,
    required this.date,
  });

  Future<void> getDeviceInfo()async{
    platformVersion = await DeviceInformation.platformVersion;
    cpuType = await DeviceInformation.cpuName;
    var modelName = await DeviceInformation.deviceModel;
    var manufacturer = await DeviceInformation.deviceManufacturer;
    deviceName =  '$manufacturer - $modelName';
  }

  UnExpectedError.fromJson(Map<String,dynamic> json){
    errorData = json['errorData'];
    userComplain = json['userComplain'];
    date = json['date'];
    platformVersion = json['platformVersion'];
    deviceName = json['deviceName'];
    cpuType = json['cpuType'];
  }

  Map<String, dynamic> toMap(){
    return {
      'errorData': errorData,
      'userComplain': userComplain,
      'date': date,
      'platformVersion': platformVersion,
      'deviceName':deviceName ,
      'cpuType': cpuType,
    };
  }

}