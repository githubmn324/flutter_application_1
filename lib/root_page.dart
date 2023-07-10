import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/stream_provider.dart';
import 'package:flutter_application_1/models/favorite_word.dart';

class RootPage extends StatefulWidget {
  RootPage({required this.auth});
  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => _RoutePageState();
}

enum AuthStatus { notSignedIn, signedIn }

class _RoutePageState extends State<RootPage> {
  AuthStatus _authStatus = AuthStatus.notSignedIn;

  // stateが初回作成される際に実行する処理を initState()でoverrideできる
  @override
  initState() {
    super.initState();
    setState(() {
      // _authStatus = widget.auth.currentUser() == null
      _authStatus = FirebaseAuth.instance.currentUser == null
          ? AuthStatus.notSignedIn
          : AuthStatus.signedIn;
    });
  }

  void _signedIn() {
    print('setState _authStatus = signedIn');
    setState(() {
      _authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut() {
    print('setState _authStatus = signedOut');
    setState(() {
      _authStatus = AuthStatus.notSignedIn;
    });
  }

  final _firestoreService = FirestoreService();
  FavoriteDataModel createErrorMessage(error) {
    return FavoriteDataModel(
        id: "", message: error, name: "error", timestamp: 999999);
  }

  @override
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatus.notSignedIn:
        return LoginPage(auth: widget.auth, onSignedIn: _signedIn);
      case AuthStatus.signedIn:
        return StreamProvider<List<FavoriteDataModel>>(
            create: (BuildContext context) =>
                _firestoreService.fetchFirestoreData(),
            initialData: [],
            catchError: (context, error) =>
                [createErrorMessage(error.toString())],
            child: MyHomePage(auth: widget.auth, onSignedOut: _signedOut));
      // return MyHomePage(auth: widget.auth, onSignedOut: _signedOut);
    }
  }
}
