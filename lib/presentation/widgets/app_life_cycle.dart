import 'package:domino_game/data/firestore_services/user_firebase_services.dart';
import 'package:flutter/material.dart';

class LifeCycle extends StatefulWidget {

  final bool inMatch ;
  const LifeCycle({super.key, required this.inMatch});
 @override
  LifeCycleState createState() => LifeCycleState();
}

class LifeCycleState extends State<LifeCycle> with WidgetsBindingObserver {



 @override
 void initState(){
  UserFireBaseServices().updateUserStatus(status: 'online');
  super.initState();
  WidgetsBinding.instance.addObserver(this);
 }

 @override
 Widget build(BuildContext context){
  return Container();
 }

 @override
 void didChangeAppLifecycleState(AppLifecycleState state) {
  switch (state) {
   case AppLifecycleState.inactive:
    UserFireBaseServices().updateUserStatus(status: 'offline');
    break;
   case AppLifecycleState.paused:
    UserFireBaseServices().updateUserStatus(status:  widget.inMatch? 'away': 'offline');
    debugPrint('AppLifecycleState.paused');
    break;
   case AppLifecycleState.resumed:
    UserFireBaseServices().updateUserStatus(
        status: widget.inMatch? 'inMatch': 'online'
    );

    break;
    case AppLifecycleState.detached:
      // TODO: Handle this case.
      break;
  }
 }

 @override
 void dispose(){
  WidgetsBinding.instance.removeObserver(this);
  super.dispose();
 }

}