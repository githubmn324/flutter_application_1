import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

// abstract is a way of define interface for classes to implement
abstract class BaseAuth {
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  // String currentUser();
}

// create interfate
class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      /// メールアドレスが無効の場合
      if (e.code == 'invalid-email') {
        print('メールアドレスが無効です');
        throw ('メールアドレスが無効です');
      }

      /// ユーザーが存在しない場合
      else if (e.code == 'user-not-found') {
        print('ユーザーが存在しません');
        throw ('ユーザーが存在しません');
      }

      /// パスワードが間違っている場合
      else if (e.code == 'wrong-password') {
        print('パスワードが間違っています');
        throw ('パスワードが間違っています');
      }

      /// その他エラー
      else {
        print('サインインエラー: $e');
        throw ('サインインエラー');
      }
    }
  }

  @override
  Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user!.uid;
    } catch (e) {
      print(e);
      throw ('error: $e');
    }
  }

  // @override
  // String currentUser() {
  //   final user! = _firebaseAuth.currentUser;
  //   if (user == null) {
  //     return "";
  //   } else {
  //     return user.uid;
  //   }
  // }
  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}
