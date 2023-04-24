
import 'package:domino_game/presentation/screens/creating_match_screen.dart';
import 'package:domino_game/presentation/screens/home_Screen.dart';
import 'package:domino_game/presentation/screens/loadin_online_match_sceen.dart';
import 'package:domino_game/presentation/screens/offline_normal_match.dart';
import 'package:domino_game/presentation/screens/online_match_screen.dart';
import 'package:domino_game/presentation/screens/profile_screen.dart';
import 'package:domino_game/presentation/screens/search_for_match_screen.dart';
import 'package:domino_game/presentation/screens/settings_screen.dart';
import 'package:domino_game/presentation/screens/sign_in_screen.dart';
import 'package:domino_game/presentation/screens/stream_on_myrequest_screen.dart';
import 'package:domino_game/presentation/screens/stream_on_received_request_screen.dart';
import 'package:domino_game/presentation/screens/test_screen.dart';
import 'package:domino_game/presentation/screens/verifying_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'constants/constants.dart';
import 'constants/strings.dart';
import 'cubits/auth_cubit/auth_cubit.dart';
import 'cubits/game_cubit/game_cubit.dart';
import 'cubits/user_cubit/user_cubit.dart';
import 'data/firestore_services/auth_services.dart';
import 'data/firestore_services/match_firebase_services.dart';
import 'data/firestore_services/user_firebase_services.dart';
import 'data/repository/auth_repository.dart';
import 'data/repository/match_repository.dart';
import 'data/repository/user_repository.dart';

/*
MaterialPageRoute(
          builder: (_) =>  BlocProvider.value(
              value: userCubit..getUser(uId),
              child: uId!= null
                  ? const HomeScreen() : const SignInScreen()
          ),
        )
*/

class AppRouter{

  late UserRepository userRepository;
  late MatchRepository matchRepository;
  late AuthRepository authRepository ;
  late UserCubit userCubit;
  late GameCubit matchCubit ;
  late AuthCubit authCubit ;

  AppRouter(){
    matchRepository = MatchRepository(MatchFirebaseServices());
    userRepository = UserRepository(UserFireBaseServices());
    authRepository = AuthRepository(AuthServices());
    authCubit = AuthCubit(authRepository) ;
    userCubit = UserCubit(userRepository);
    matchCubit = GameCubit(matchRepository) ;
  }

  Route? generateRoute(RouteSettings settings){
    switch (settings.name){
      case firstScreen:
        //const SignInScreen()
        return MaterialPageRoute(
          builder: (_) => uId!= null ?
          BlocProvider.value(
              value: userCubit..getUser(uId),
              child: const HomeScreen()
          ):
          BlocProvider.value(
              value: authCubit,
              child: const SignInScreen()
          )
        );
      case verifyingEmailScreen:
        final userData = settings.arguments as Map<String,String>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
              value: authCubit,
              child: VerifyingEmailScreen(
                userName: userData['name']!,
                password: userData['password']!,
                email: userData['email']!,
              )
          ),
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
          value: userCubit..getUser(uId),
          child: const HomeScreen()),
        );
      case profileScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
              value: userCubit ,
              child: AccountScreen()),
        );
      case searchGameScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
              value: userCubit..startTimer(),//..getFireStoreRequests() ,
          child: const SearchForMatchScreen()),
        );
      case streamOnMyRequestScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
              value: userCubit,
              child: const StreamOnMyRequestScreen(isFriendRequest: false,)
          ),
        );
      case streamOnReceivedRequestScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
              value: userCubit,
              child: const StreamOnReceivedRequestScreen(isFriendRequest: false)
          ),
        );
      case creatingMatchScreen:
        final  arg = settings.arguments as Map<String,dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
              value: matchCubit..initScreenSettings(
                  width: widthWithNoNotch!,//widthWithNoNotch!
                  height: MediaQuery.of(_).size.height
              ),
              child: CreatingMatchScreen(
                isOnline: arg['isOnline'],
                players: arg['players'],
                request: arg['request'],
                isFriendRequest: arg['isFriendRequest'],
                friendMatchRequest: arg['friendMatchRequest'],
              )
          ),
        );
      case onlineMatchLoadingDataScreen:
        final  matchId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
              value: matchCubit..initScreenSettings(
                  width: widthWithNoNotch!,
                  height: MediaQuery.of(_).size.height
              )..getOnlineMatchData(matchId),
              child: const OnlineMatchDataLoadingScreen()
          ),
        );
      case onlineMatchScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
              value: matchCubit,
              child: const OnlineMatchScreen()),
        );
        ////////////////////
      case offlineMatchScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
              value: matchCubit,
              child: const OfflineMatchScreen()),
        );
      case test:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
              create: (BuildContext context)=> GameCubit(matchRepository),
          child: const TestScreen()),
        );

      default:
    }
    return null;
  }
}