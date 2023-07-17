
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_states.dart';

class AppCubit extends Cubit<AppStates>{
  //AppCubit() : super(AppInitialState());
  static AppCubit get(context) => BlocProvider.of(context) ;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _connectivityStreamSubscription;

  AppCubit() : super(AppInitialState()) {
    _connectivityStreamSubscription = _connectivity.onConnectivityChanged.listen(
              (result) {
            if (result == ConnectivityResult.none) {
             // emit(InternedDisConnected());
            } else {
              getInternetState() ;
            }
          },
        );
  }

 //void emitNetConnected() => emit(NetConnected());
 // void emitNetDisConnected() => emit(NetDisconnected());

  @override
  Future<void> close() {
    _connectivityStreamSubscription.cancel();
    return super.close();
  }


  bool isDeviceConnected = true ;
  void getInternetState()async{
    //isDeviceConnected = await InternetConnectionChecker().hasConnection;
    if(isDeviceConnected){
      debugPrint('isDeviceConnected');
      emit(InternedConnected());
    }else{
      debugPrint('disconnect');
      emit(InternedDisConnected());
    }

  }

}