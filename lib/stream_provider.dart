import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ---------- Firebase --------------
class MyUserModel {}

class FirebaseService {
  FirebaseAuth _auth = FirebaseAuth.instance;
}

// ---------- Firestore --------------
// define data model class
class FavoriteDataModel {
  final String id;
  final String message;
  final String name;
  final int timestamp;

  FavoriteDataModel(
      {required this.id,
      required this.message,
      required this.name,
      required this.timestamp});

  // keyが文字列で値がdynamicなMapオブジェクトを FavoriteDataModel に変換
  FavoriteDataModel.fromJson(String documentId, Map<String, dynamic> parsedJson)
      : id = documentId,
        // : message = parsedJson['message'], // catchErrorの動作確認
        message = parsedJson['text'] ?? "",
        name = parsedJson['name'] ?? "",
        timestamp = parsedJson['timestamp'];
}

class FavoriteDataDetailModel {
  final String id;
  final String message;
  final String name;
  final int timestamp;
  final String email;
  final bool isPrivate;
  final bool isFavorite;

  FavoriteDataDetailModel(
      {required this.id,
      required this.message,
      required this.name,
      required this.timestamp,
      required this.email,
      required this.isPrivate,
      required this.isFavorite});

  // keyが文字列で値がdynamicなMapオブジェクトを FavoriteDataModel に変換
  FavoriteDataDetailModel.fromJson(
      String documentId, bool favorite, Map<String, dynamic> parsedJson)
      : id = documentId,
        email = parsedJson['email'] ?? "",
        message = parsedJson['text'] ?? "",
        name = parsedJson['name'] ?? "",
        timestamp = parsedJson['timestamp'],
        isPrivate = parsedJson['isPrivate'],
        isFavorite = favorite;
}

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

  // Future<List<FavoriteDataDetailModel>> getFirestoreData() async {
  //   return _db
  //       .collection("favorite_word2")
  //       .orderBy('timestamp', descending: true)
  //       .get()
  //       .then(
  //           (querySnapshot) => querySnapshot.docs
  //               .map((doc) =>
  //                   FavoriteDataDetailModel.fromJson(doc.id, false, doc.data()))
  //               .toList(),
  //           onError: (e) => print("Error completing: $e"));
  // }

  Future<FavoriteDataDetailModel> getIndivFirestoreData(String id) async {
    print('calling getDoc Firestore ID: $id');
    return _db.collection("favorite_word2").doc(id).get().then(
        (DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      return FavoriteDataDetailModel.fromJson(doc.id, false, data);
    }, onError: (e) => throw "Error completing: $e");
  }

  Future<DeleteProcessModel> deleteDocument(String id) async {
    print('calling deleteDaocument Firestore ID: $id');
    return FirebaseFirestore.instance
        .collection("favorite_word2")
        .doc(id)
        .delete()
        .then(
            (doc) => DeleteProcessModel(
                isSucceed: true, message: '$id was successfully deleted'),
            onError: (e) => DeleteProcessModel(
                isSucceed: true, message: 'Error while deleting $id: $e'));
  }
}

class DeleteProcessModel {
  final bool isSucceed;
  final String message;

  DeleteProcessModel({required this.isSucceed, required this.message});
}

class DeleteData extends ChangeNotifier {
  DeleteProcessModel deleteProcessModel =
      DeleteProcessModel(isSucceed: false, message: "");

  Future<void> deleteDocument(String id) async {
    print('calling deleteDaocument Firestore ID: $id');
    await FirebaseFirestore.instance
        .collection("favorite_word2")
        .doc(id)
        .delete()
        .then(
            (doc) => deleteProcessModel = DeleteProcessModel(
                isSucceed: true, message: '$id was successfully deleted'),
            onError: (e) => deleteProcessModel = DeleteProcessModel(
                isSucceed: true, message: 'Error while deleting $id: $e'));

    notifyListeners();
  }
}

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
