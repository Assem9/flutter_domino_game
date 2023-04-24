import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/match.dart';

class MatchFirebaseServices{

  //firesStoreMatches
  FirebaseFirestore firesStore = FirebaseFirestore.instance ;

  Future<void> addNewMatchFireStore ({required DominoMatch match})async{
    return await firesStore.collection('matches').doc(match.iD).set(match.toMap());
  }
  Future<void> updateMatchFireStore ({required DominoMatch match})async{
    return await firesStore.collection('matches').doc(match.iD).update(match.toMap());
  }

  Future<DocumentSnapshot<Map<String, dynamic>>>  getMatchDocument({
    required String matchID
  }) async{
   return await firesStore.collection('matches').doc(matchID).get();
  }

}