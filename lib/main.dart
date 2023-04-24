import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'app_router.dart';
import 'cacheHelper.dart';
import 'constants/constants.dart';
import 'constants/strings.dart';
import 'constants/themes.dart';
import 'cubits/bloc_observer.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []) ;
  await CacheHelper.init();
  Bloc.observer = MyBlocObserver();
  uId = await CacheHelper.getData(key: 'uId');
  widthWithNoNotch = CacheHelper.getData(key: 'widthWithNoNotch');

  if(uId != null){
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }else{
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  await Firebase.initializeApp();
  runApp(MyApp(appRouter: AppRouter(),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appRouter});
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Domino Game',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      onGenerateRoute: appRouter.generateRoute,
      //home: TestScreen(),
    );
  }
}
/*
class MainApp extends StatefulWidget {
  const MainApp({Key? key,required this.appRouter}) : super(key: key);
  final AppRouter appRouter ;

  @override
  State<MainApp> createState() => _MainAppState();
}


class _MainAppState extends State<MainApp> with WidgetsBindingObserver{
 late final AppRouter appRouter ;
  @override
  void initState(){
    appRouter = widget.appRouter ;
    UserFireBaseServices().updateUserStatus(status: 'online');
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Online Domino',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      onGenerateRoute: appRouter.generateRoute,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        UserFireBaseServices().updateUserStatus(status: 'offline');
        break;
      case AppLifecycleState.paused:
        UserFireBaseServices().updateUserStatus(status: 'offline');
        print('AppLifecycleState.paused');
        break;
      case AppLifecycleState.resumed:
        UserFireBaseServices().updateUserStatus(status: 'online');
        print('AppLifecycleState.resumed');
        break;
      case AppLifecycleState.detached:
      // TODO: Handle this case.
        break;
    }
  }

  @override
  void dispose(){
    //UserFireBaseServices().updateUserStatus(status: 'offline');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}*/

