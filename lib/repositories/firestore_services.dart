import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import '../models/favorite_word.dart';
import '../models/firestore_favorite_model.dart';
import '../models/delete_result.dart';

// function that returns stream
class FirestoreService {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  final initialData = FirestoreFavoriteDataModel(
      id: "-",
      email: "",
      message: "fetching",
      timestamp: 999999,
      isFavorite: false);

  // /* ストリームデータ取得 */
  // Stream<List<FirestoreDataModel>> fetchFirestoreData() {
  //   return _db
  //       .collection('favorite_word2')
  //       .orderBy('timestamp', descending: true)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs
  //           .map((doc) => FirestoreDataModel.fromJson(doc.id, doc.data()))
  //           .toList());
  // }

  /* POST */
  Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    await _db.collection(collection).add(data);
  }

  /* GET */
  Future<Map<String, dynamic>> getDocument(String collection, String id) async {
    return _db
        .collection(collection)
        .doc(id)
        .get()
        .then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data;
    }).catchError((e) => throw "Error completing: $e");
  }

  Future<FirestoreFavoriteDataModel> getIndivFirestoreData(String id) async {
    return _db.collection("favorite_word2").doc(id).get().then(
        (DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      return FirestoreFavoriteDataModel.fromJson(doc.id, false, data);
    }, onError: (e) => throw "Error completing: $e");
  }

  Future<void> sendToFirestore(String message) async {
    print('sending message to Firestore: $message');
    print('Current User: ${FirebaseAuth.instance.currentUser!}');
    await _db.collection('favorite_word2').add(<String, dynamic>{
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      // 'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'email': FirebaseAuth.instance.currentUser!.email,
      'isPrivate': false,
    });
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
