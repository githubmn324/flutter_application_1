import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/firestore_data_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDataListViewModel extends ChangeNotifier {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<FirestoreDataModel>> getFavoriteWords() {
    return _db
        .collection('favorite_word2')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FirestoreDataModel.fromJson(doc.id, doc.data()))
            .toList());
  }

  // List<FirestoreDataModel> firestoreData = [];

  // List<FavoriteWordsViewModel> get _favoriteWordsList;

  // setFavoriteWordList() {
  //   notifyListeners();
  // }
}
