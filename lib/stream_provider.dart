import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

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
  final String email;
  final int timestamp;

  FavoriteDataDetailModel(
      {required this.id,
      required this.message,
      required this.name,
      required this.email,
      required this.timestamp});

  // keyが文字列で値がdynamicなMapオブジェクトを FavoriteDataModel に変換
  FavoriteDataDetailModel.fromJson(
      String documentId, Map<String, dynamic> parsedJson)
      : id = documentId,
        email = parsedJson['email'] ?? "",
        message = parsedJson['text'] ?? "",
        name = parsedJson['name'] ?? "",
        timestamp = parsedJson['timestamp'];
}

// function that returns stream
class FirestoreService {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  final initialData = FavoriteDataDetailModel(
      id: "-", email: "", message: "fetching", name: "-", timestamp: 999999);

  Stream<List<FavoriteDataModel>> fetchFirestoreData() {
    return _db
        .collection('favorite_word2')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FavoriteDataModel.fromJson(doc.id, doc.data()))
            .toList());
  }

  Future<DocumentReference> sendToFirestore(String message) {
    print('sending message to Firestore: $message');
    print('Current User: ${FirebaseAuth.instance.currentUser!}');
    return _db.collection('favorite_word2').add(<String, dynamic>{
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      // 'name': FirebaseAuth.instance.currentUser!.displayName,
      'email': FirebaseAuth.instance.currentUser!.email,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  Future<List<FavoriteDataModel>> getFirestoreData() {
    return _db
        .collection("favorite_word2")
        .orderBy('timestamp', descending: true)
        .get()
        .then(
            (querySnapshot) => querySnapshot.docs
                .map((doc) => FavoriteDataModel.fromJson(doc.id, doc.data()))
                .toList(),
            onError: (e) => print("Error completing: $e"));
  }

  Future<FavoriteDataDetailModel> getIndivFirestoreData(String id) async {
    return _db.collection("favorite_word2").doc(id).get().then(
        (DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      return FavoriteDataDetailModel.fromJson(doc.id, data);
    }, onError: (e) => throw "Error completing: $e");
  }
}
