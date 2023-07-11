import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/view_models/firestore_favorite_view_model.dart';
import 'package:flutter_application_1/models/firestore_favorite_model.dart';

class FirestoreFavoriteListViewModel extends ChangeNotifier {
  List<FirestoreFavoriteViewModel> _firestoreFavoriteList = [];

  // List<FirestoreFavoriteViewModel> get _firestoreFavoriteList;

  void getFirestoreData(favorites) async {
    var docs = await FirebaseFirestore.instance
        .collection("favorite_word2")
        .orderBy('timestamp', descending: true)
        .get()
        .then((querySnapshot) => querySnapshot.docs);
    _firestoreFavoriteList.clear();
    if (favorites.isEmpty) {
      for (var doc in docs) {
        _firestoreFavoriteList.add(
            FirestoreFavoriteDataModel.fromJson(doc.id, false, doc.data()));
      }
      print('_firestoreFavoriteList: $_firestoreFavoriteList');
    } else {
      for (var doc in docs) {
        var message = doc.data()['text'];
        var favoriteToLower =
            favorites.map((favorite) => favorite.toString().toLowerCase());
        if (favoriteToLower.contains(message)) {
          print(
              'message: $message is favorite: ${favorites.contains(message)}');
          _firestoreFavoriteList.add(
              FirestoreFavoriteDataModel.fromJson(doc.id, true, doc.data()));
        } else {
          print(
              'message: $message is not favorite: ${favorites.contains(message)}');
          _firestoreFavoriteList.add(
              FirestoreFavoriteDataModel.fromJson(doc.id, false, doc.data()));
        }
      }
    }
  }

  setFavoriteWordList() {
    // _firestoreFavoriteList = ;
    notifyListeners();
  }
}
