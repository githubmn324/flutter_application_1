import 'package:flutter/material.dart';
import '../auth.dart';
import '../main.dart';
import './favorite_word.dart';
import './fetch_proxy.dart';
import 'value_listenable.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/models/favorite_word.dart';
import '../providers/stream_provider.dart';
import '../providers/app_state.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.auth, required this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  void _onSignedOut() async {
    try {
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  final _firestoreService = FirestoreService();
  FavoriteDataModel createErrorMessage(error) {
    return FavoriteDataModel(
        id: "", message: error, name: "error", timestamp: 999999);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = StreamProvider<List<FavoriteDataModel>>(
            create: (BuildContext context) =>
                _firestoreService.fetchFirestoreData(),
            initialData: [],
            catchError: (context, error) =>
                [createErrorMessage(error.toString())],
            child: StreamFirestoreDataPage());

        break;
      case 3:
        page = ProxyTest();
        break;
      case 4:
        page = ValueListenableTest();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                      icon: Icon(Icons.home), label: Text('Home')),
                  NavigationRailDestination(
                      icon: Icon(Icons.favorite), label: Text('Favorites')),
                  NavigationRailDestination(
                      icon: Icon(Icons.filter_drama),
                      label: Text('StreamFirestore')),
                  NavigationRailDestination(
                      icon: Icon(Icons.portable_wifi_off_sharp),
                      label: Text('ProxyTest')),
                  NavigationRailDestination(
                      icon: Icon(Icons.telegram),
                      label: Text('ValueListenableTest')),
                ],
                trailing: IconButton(
                  onPressed: widget._onSignedOut,
                  icon: Icon(Icons.logout),
                ),
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}
