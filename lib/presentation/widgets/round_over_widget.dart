import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:domino_game/cubits/game_cubit/game_cubit.dart';
import 'package:domino_game/data/firestore_services/user_firebase_services.dart';
import 'package:domino_game/data/models/match.dart';
import 'package:domino_game/data/models/match_enums.dart';
import 'package:domino_game/data/models/player.dart';
import 'package:domino_game/data/repository/user_repository.dart';
import 'package:domino_game/presentation/widgets/player_widget.dart';
import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../constants/my_colors.dart';
import '../../constants/strings.dart';
import 'default_button.dart';
import 'domino_piece_widget.dart';


class OverMessageWidget extends StatefulWidget {
  const OverMessageWidget({
    Key? key,
    required this.match,
    required this.loser,
    required this.winner
  }) : super(key: key);

  final DominoMatch match ;
  final DomPlayer loser ;
  final DomPlayer winner ;

  @override
  State<OverMessageWidget> createState() => _OverMessageWidgetState();
}

class _OverMessageWidgetState extends State<OverMessageWidget> {

  Duration myDuration = const Duration(seconds: 7);
  Timer? countDownTimer ;
  void startTimer(){
    myDuration = const Duration(seconds: 7);
    countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer)=> setCountDown ());
  }

  void setCountDown (){
    const reduceSecondsBy = 1 ;
    int seconds =  myDuration.inSeconds - reduceSecondsBy ;
    if(seconds < 0){
      countDownTimer!.cancel();
    }else{
      setState(() {
        debugPrint('setState');
        myDuration = Duration(seconds: seconds);
      });

    }
  }
  @override

  void initState() {
    GameCubit.get(context).checkGameOverCases(widget.match) ;
    if(widget.match.mode == MatchMode.FULLMATCH ){
      startTimer() ;
    }
    super.initState();
  }

  @override
  void dispose() {
    if(widget.match.mode == MatchMode.FULLMATCH ){
      countDownTimer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameCubit.get(context).showMatchOver
        ? buildMatchOverMessage(context)
        : buildRoundOverMsg(context) ;
  }

  Widget buildRoundOverMsg(context){
    return myDuration.inSeconds >0 ?
      Container(
      margin: const EdgeInsets.symmetric(vertical: 25),
      width: MediaQuery.of(context).size.width /2,
      height: MediaQuery.of(context).size.height  ,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          color: MyColors.darkBlue ,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 5,color: MyColors.blue),
          boxShadow: const [
            BoxShadow(
              color: MyColors.darkBlue,
              blurRadius: 2,
              spreadRadius:1 ,
              offset: Offset( 1, 1.5),
            ),
            BoxShadow(
              color: MyColors.darkBlue,
              blurRadius: 1,
              spreadRadius:0.5 ,
              offset: Offset(0, -1.5),
            ),
          ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildAnimatedTitleText(context),
          const SizedBox(height: 5,),
          GameCubit.get(context).allSevenIn
              ? buildAllSevenInCaseMessageWidget()
              : Row(
                children: [
                  Expanded(child: buildPlayerDominoesGridView(context, widget.loser)),
                  Expanded(child: Container()),
                ],
              ),
          const SizedBox(height: 10,),
          Text(
            '${widget.winner.name} got: ${GameCubit.get(context).roundPoints} point from this round',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 15,),
         DefaultButton(
             buttonColor: MyColors.lemon,
             title: "Next Round Starts in ( ${myDuration.inSeconds} )",
             onTap: (){}//=> GameCubit.get(context).cancelState()
         )
         // buildTimerWidget(),
        ],
      ),
    ): Container();
  }

  Widget buildAnimatedTitleText(context){
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.titleLarge! ,
      child: AnimatedTextKit(
        repeatForever: true,
        animatedTexts: [
          TyperAnimatedText('Round Over'),
          ColorizeAnimatedText(
              'Round Over',
              textStyle: Theme.of(context).textTheme.titleLarge!,
              colors: MyColors.colorizeColors // [MyColors.lemon,MyColors.darkBlue,MyColors.blue]
          ),
        ],
      ),
    );
  }

  Widget buildPlayerDominoesGridView(context,DomPlayer player){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          '${player.name} left dominoes:',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 5,),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            childAspectRatio:1/1.8 ,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemBuilder: (context, index)=> DominoPieceWidget(
            piece: player.pieces[index],
            match: widget.match,
            height: GameCubit.get(context).matchScreenSettings.pieceHeight,
          ),
          itemCount: player.pieces.length,
        ),
      ],
    ) ;
  }

  Widget buildAllSevenInCaseMessageWidget(){
    return Column(
      children: [
        Text(
          'since all ${widget.match.dominoBoard.leftTarget} are played the player who has the least total dominoes value is the winner',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
                child: buildPlayerDominoesGridView(
                    context,
                    widget.loser,
                )
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 2,
              height: GameCubit.get(context).matchScreenSettings.pieceHeight *2,
              color: MyColors.lemon,
            ),
            // const SizedBox(width: 5,),
            Expanded(
                child: buildPlayerDominoesGridView(
                    context,
                    widget.winner,
                )
            ),
          ],
        ),
      ],
    );
  }

  ////
  Widget buildMatchOverMessage(context){
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: AlignmentDirectional.center ,
      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 20),
      decoration: BoxDecoration(
          color: MyColors.sky,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 15,color: MyColors.blue)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedTextKit(
                    repeatForever: true,
                    animatedTexts: [
                      ColorizeAnimatedText(
                        'Match Over',
                        textStyle: Theme.of(context).textTheme.displaySmall!.copyWith(color: MyColors.lemon, fontSize: 35),
                        colors: MyColors.colorizeColors,
                      ),
                      ColorizeAnimatedText(
                        GameCubit.get(context).myPlayer.iD == widget.winner.iD
                            ? 'YOU WON !!'
                            : 'YOU LOST !!' ,
                        textStyle: Theme.of(context).textTheme.displaySmall!.copyWith(color: MyColors.lemon, fontSize: 30),
                        colors: MyColors.colorizeColors,
                      ),
                    ]
                ),
                const SizedBox(height: 20,),
                buildPlayersDataWidget(context, widget.match),
                const SizedBox(height: 20,),
                DefaultButton(
                    width: MediaQuery.of(context).size.width /3,
                    title: 'Back to Home',
                    buttonColor: MyColors.lemon,
                    onTap: ()=> Navigator.pushNamedAndRemoveUntil(context, home, (route) => false)
                ),
                TextButton(
                    onPressed: ()=>GameCubit.get(context).cancelState(),
                    child: Text(
                      'back to Board',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: MyColors.lemon,
                        decoration: TextDecoration.underline,
                      ),
                    )
                ),
              ],
            ),
          ),
          GameCubit.get(context).allSevenIn
              ? Expanded(
                child: buildAllSevenInCaseMessageWidget(),
              )
              : Expanded(
                child: Row( 
            children: [
                Expanded(child: buildPlayerDominoesGridView(context, widget.loser)),
                Expanded(child: Container()),
            ],
          ),
              )

        ],
      ),

    );
  }

  Widget buildPlayersDataWidget(context,DominoMatch match){
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      margin: const EdgeInsets.symmetric(horizontal: 6,vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: buildPlayerWidget(context,player: match.playerOne),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 5),
            child: AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  ColorizeAnimatedText(
                    'VS',
                    textStyle: Theme.of(context).textTheme.displaySmall!,
                    colors: MyColors.colorizeColors,
                  ),
                ]
            ),
          ),
          // const SizedBox(width: 20,), //SizedBox(width: 20,),
          Expanded(
            child: buildPlayerWidget(context,player: match.playerTwo),
          ), 
        ],
      ),
    );
  }

  Widget buildPlayerWidget(context,{required DomPlayer player}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlayerDataWidget(player: player, isOnline: widget.match.isOnline,),
        player.iD != uId && !GameCubit.get(context).myPlayer.friendsIds.contains(player.iD)?
        DefaultButton(
            height: 20,
            width: 55,
            icon: Icons.person_add_rounded,
            textStyle: Theme.of(context).textTheme.bodySmall,
            title: '',
            buttonColor: MyColors.blue,
            onTap: ()=> UserRepository(UserFireBaseServices())
                .sendFriendRequest(
                requestCreator: GameCubit.get(context).myPlayer,
                friendId: player.iD
            ),
        ): Container(),
      ],
    );
  }

}
