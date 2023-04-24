import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper{
  static  SharedPreferences? sharedPreferences ;

  static init() async {
    try{
      sharedPreferences = await SharedPreferences.getInstance() ;
      debugPrint('INIT Sucess');
    }catch(e){
      debugPrint('INIT $e');
    }

  }

  static dynamic  getData({required String key}) {
    return sharedPreferences!.get(key);
  }

  static Future<bool> saveData({
    required String key,
    required dynamic value,
  })async {
    if(value is String) return await sharedPreferences!.setString(key, value);
    if(value is int) return await sharedPreferences!.setInt(key, value);
    if(value is bool) return await sharedPreferences!.setBool(key, value);

    return await sharedPreferences!.setDouble(key, value);
  }

  static Future<bool>  saveList({
    required String key,
    required List<String> strings
  })async{
    return await sharedPreferences!.setStringList(key, strings);
  }

  static getList(String key){
    return sharedPreferences!.getStringList(key);
  }

  static Future<bool> clearData({required String key})
  {
    return sharedPreferences!.remove(key);
  }

}