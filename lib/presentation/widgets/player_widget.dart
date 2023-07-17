import 'package:domino_game/presentation/widgets/app_loader.dart';
import 'package:domino_game/presentation/widgets/user_pic.dart';
import 'package:flutter/material.dart';
import '../../constants/my_colors.dart';
import '../../data/models/player.dart';
import '../../data/models/user.dart';

class PlayerDataWidget extends StatelessWidget {
  const PlayerDataWidget({Key? key, required this.player, required this.isOnline}) : super(key: key);
  final DomPlayer player ;
  final bool isOnline ;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: MediaQuery.of(context).size.width /5,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: player.isPlaying && player.status != UserStatus.autoPlay
            ? MyColors.lemon
            : player.status == UserStatus.leftMatch || player.status == UserStatus.away
            ? MyColors.red1
            : null,
          borderRadius: BorderRadius.circular(10),
          border: player.isPlaying ?
          Border.all(
              color: MyColors.blue ,
              width: 2
          ) : null
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(avatarUrl: player.photoUrl, radius: 20, online: isOnline,),
          const SizedBox(width: 5,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 14),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: MyColors.darkBlue,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(15), )
                  ),
                  child: player.status != UserStatus.autoPlay ?
                  Text(
                    player.name,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MyColors.lemon),
                  ):
                  Row(
                    children: [
                      const AppLoader(size: 7,loaderColor: MyColors.red1,),
                      const SizedBox(width: 5,),
                      Text(
                          'auto',
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MyColors.red1),
                        ),
                    ],
                  ),
                ),
                Container(
                  //alignment: AlignmentDirectional.topStart,
                 padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: const BoxDecoration(
                    color: MyColors.blue,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomLeft: Radius.circular(10),)
                  ),
                  child: Text(
                    'score: ${player.score}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: MyColors.lemon),
                  ),
                ),
                player.status == UserStatus.away
                    ? Text(
                  '${player.name} is Away',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey),
                )
                    : Container()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
