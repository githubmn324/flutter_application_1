import 'package:flutter/material.dart';
import '../auth.dart';
import '../main.dart';
import 'firestore_stream_page.dart';
import 'firestore_get_page.dart';
import 'package:flutter_application_1/models/firestore_data_model.dart';

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

  FirestoreDataModel createErrorMessage(error) {
    return FirestoreDataModel(
        id: "", email: "", message: error, name: "error", timestamp: 999999);
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = FirestoreStreamPage();
        break;
      case 3:
        page = FirestoreGetPage();
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
                      label: Text('Firestore Stream Page')),
                  NavigationRailDestination(
                      icon: Icon(Icons.portable_wifi_off_sharp),
                      label: Text('Firestore Get Page')),
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
