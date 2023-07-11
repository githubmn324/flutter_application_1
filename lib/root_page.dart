import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/login_page.dart';
import 'package:flutter_application_1/views/home_page.dart';
import 'auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'view_models/firestore_data_list_view_model.dart';
import 'package:flutter_application_1/models/firestore_data_model.dart';

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

  final _firestoreDataListViewModel = FirestoreDataListViewModel();
  FirestoreDataModel createErrorMessage(error) {
    return FirestoreDataModel(
        id: "", email: "", message: error, name: "error", timestamp: 999999);
  }

  @override
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatus.notSignedIn:
        return LoginPage(auth: widget.auth, onSignedIn: _signedIn);
      case AuthStatus.signedIn:
        return StreamProvider<List<FirestoreDataModel>>(
            create: (BuildContext context) =>
                _firestoreDataListViewModel.getFavoriteWords(),
            initialData: [],
            catchError: (context, error) =>
                [createErrorMessage(error.toString())],
            child: MyHomePage(auth: widget.auth, onSignedOut: _signedOut));
      // return MyHomePage(auth: widget.auth, onSignedOut: _signedOut);
    }
  }
}
