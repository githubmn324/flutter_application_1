import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'models/favorite_word.dart';
import 'models/favorite_word_details.dart';
import 'models/delete_result.dart';

// function that returns stream
class FirestoreService with ChangeNotifier {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  final initialData = FavoriteDataDetailModel(
      id: "-",
      email: "",
      message: "fetching",
      name: "-",
      timestamp: 999999,
      isPrivate: false,
      isFavorite: false);

  // ストリーム
  Stream<List<FavoriteDataModel>> fetchFirestoreData() {
    return _db
        .collection('favorite_word2')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FavoriteDataModel.fromJson(doc.id, doc.data()))
            .toList());
  }

  // ストリームサブスクリプション
  StreamSubscription<QuerySnapshot> createStreamSubscription() {
    return _db
        .collection('favorite_word2')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) => snapshot.docs
            .map((doc) => FavoriteDataModel.fromJson(doc.id, doc.data())));
  }

  Future<void> sendToFirestore(String message) async {
    print('sending message to Firestore: $message');
    print('Current User: ${FirebaseAuth.instance.currentUser!}');
    // create document
    // _db.collection('favorite_word2').add(<String, dynamic>{
    //   'text': message,
    //   'timestamp': DateTime.now().millisecondsSinceEpoch,
    //   'name': FirebaseAuth.instance.currentUser!.displayName,
    //   'userId': FirebaseAuth.instance.currentUser!.uid,
    // }).then((docRef) => {
    //       _db
    //           .collection('favorite_word2')
    //           .doc(docRef.id)
    //           .collection('private')
    //           .add(<String, dynamic>{
    //         'email': FirebaseAuth.instance.currentUser!.email,
    //       })
    //     });
    // update document to create subcollection
    await _db.collection('favorite_word2').add(<String, dynamic>{
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      // 'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'email': FirebaseAuth.instance.currentUser!.email,
      'isPrivate': false,
    });
  }

  Future<FavoriteDataDetailModel> getIndivFirestoreData(String id) async {
    print('calling getDoc Firestore ID: $id');
    return _db.collection("favorite_word2").doc(id).get().then(
        (DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      return FavoriteDataDetailModel.fromJson(doc.id, false, data);
    }, onError: (e) => throw "Error completing: $e");
  }

  Future<DeleteResultModel> deleteDocument(String id) {
    print('calling deleteDocument Firestore ID: $id');
    return FirebaseFirestore.instance
        .collection("favorite_word2")
        .doc(id)
        .delete()
        .then(
            (doc) => DeleteResultModel(
                isSucceed: true, message: '$id was successfully deleted'),
            onError: (e) => DeleteResultModel(
                isSucceed: true, message: 'Error while deleting $id: $e'));
  }
}

// Future<DeleteResultModel> deleteDocument(String id) {
//   print('calling deleteDocument Firestore ID: $id');
//   return FirebaseFirestore.instance
//       .collection("favorite_word2")
//       .doc(id)
//       .delete()
//       .then(
//           (doc) => DeleteResultModel(
//               isSucceed: true, message: '$id was successfully deleted'),
//           onError: (e) => DeleteResultModel(
//               isSucceed: true, message: 'Error while deleting $id: $e'));
// }

// Firestoreからデータ一覧を取得して、MyAppStateのfavorites情報を
class FirestoreFavoriteList extends ChangeNotifier {
  final firestoreDataList = <FavoriteDataDetailModel>[];

  void getFirestoreData(favorites) async {
    print('favorites: $favorites');
    var docs = await FirebaseFirestore.instance
        .collection("favorite_word2")
        .orderBy('timestamp', descending: true)
        .get()
        .then((querySnapshot) => querySnapshot.docs);
    firestoreDataList.clear();
    if (favorites.isEmpty) {
      for (var doc in docs) {
        firestoreDataList
            .add(FavoriteDataDetailModel.fromJson(doc.id, false, doc.data()));
      }
      print('firestoreDataList: $firestoreDataList');
    } else {
      for (var doc in docs) {
        var message = doc.data()['text'];
        var favoriteToLower =
            favorites.map((favorite) => favorite.toString().toLowerCase());
        if (favoriteToLower.contains(message)) {
          print(
              'message: $message is favorite: ${favorites.contains(message)}');
          firestoreDataList
              .add(FavoriteDataDetailModel.fromJson(doc.id, true, doc.data()));
        } else {
          print(
              'message: $message is not favorite: ${favorites.contains(message)}');
          firestoreDataList
              .add(FavoriteDataDetailModel.fromJson(doc.id, false, doc.data()));
        }
      }
    }
    notifyListeners();
  }
}
