import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

// data model class
class FavoriteDataModel {
  final String message;
  final String name;
  final int timestamp;

  FavoriteDataModel(
      {required this.message, required this.name, required this.timestamp});

  FavoriteDataModel.fromJson(Map<String, dynamic> parsedJson)
      : message = parsedJson['text'] ?? "",
        name = parsedJson['name'] ?? "",
        timestamp = parsedJson['timestamp'];
}

// function that returns stream
class FirestoreService {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<FavoriteDataModel>> fetchFirestoreData() {
    return _db
        .collection('favorite_word2')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FavoriteDataModel.fromJson(doc.data()))
            .toList());
  }

  Future<DocumentReference> sendToFirestore(String message) {
    print('sending message to Firestore: $message');
    print('Current User: ${FirebaseAuth.instance.currentUser!}');
    return FirebaseFirestore.instance
        .collection('favorite_word2')
        .add(<String, dynamic>{
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      // 'name': FirebaseAuth.instance.currentUser!.displayName,
      'email': FirebaseAuth.instance.currentUser!.email,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  Future<void> getFirestoreData() {
    return _db
        .collection("favorite_word2")
        .orderBy('timestamp', descending: true)
        .get()
        .then(
      (querySnapshot) {
        print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          print('${docSnapshot.id} => ${docSnapshot.data()}');
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }
}
