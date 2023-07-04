import 'package:date_format/date_format.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth.dart';
import 'root_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stream_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData.from(
      colorScheme: ColorScheme.dark(primary: Colors.blueGrey),
    );

    return ChangeNotifierProvider(
        create: ((context) => MyAppState()),
        child: MaterialApp(
          title: 'flutter_application_1',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          ),
          darkTheme: darkTheme,
          // home: MyHomePage(),
          // home: LoginPage(auth: Auth()),
          home: RootPage(auth: Auth()),
        ));
  }
}

class MyAppState extends ChangeNotifier {
  MyAppState() {
    // init();
  }
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  var firestoreDataList = <String>[];
  // Future<void> init() async {
  //   print('init()');
  //   final Stream<QuerySnapshot> _favoriteWordStream = FirebaseFirestore.instance
  //       .collection('favorite_word')
  //       .orderBy('timestamp', descending: true)
  //       .snapshots();
  //   _favoriteWordStream.listen((snapshot) {
  //     print('firestore changed detected!!');
  //     print('docs count: ${snapshot.docs.length}'); // 変更後のsnapshotの状態全て
  //     print('docChanges: ${snapshot.docChanges}'); // 変更のみ検知
  //     final dataList = <String>[];
  //     for (final document in snapshot.docs) {
  //       dataList.add(
  //         document.data()!['text'] as String,
  //       );
  //     }
  //     firestoreDataList = dataList;
  //     notifyListeners();
  //   });
  // }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

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
        page = FirestoreDataPage();
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
                      icon: Icon(Icons.filter_drama), label: Text('Firestore')),
                ],
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

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    final _firestoreService = FirestoreService();

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        BigCard(pair: pair),
        SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                appState.toggleFavorite();
              },
              icon: Icon(icon),
              label: Text('Like'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next')),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
                onPressed: () {
                  _firestoreService.sendToFirestore(pair.asLowerCase);
                },
                child: Text('Send to Firestore'))
          ],
        )
      ]),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      elevation: 20,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class FirestoreDataPage extends StatelessWidget {
  const FirestoreDataPage({Key? key}) : super(key: key);

  Stream<QuerySnapshot> fetchFirestoreData() {
    FirebaseFirestore _db = FirebaseFirestore.instance;
    return _db
        .collection('favorite_word2')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: fetchFirestoreData(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }
          return ListView(
            children:
                // Padding(
                //     padding: const EdgeInsets.all(20),
                //     child: Text(snapshot.data!.docs.first.data() == 'fetching'
                //         ? 'Currently fetching data... please wait.'
                //         : 'You have ${snapshot.data!.docs.length} new messages.')),
                snapshot.data!.docs
                    .map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return ListTile(
                          title: Text(data['text']),
                          trailing: Text(formatDate(
                              DateTime.fromMillisecondsSinceEpoch(
                                  data['timestamp'] * 1000),
                              [yyyy, '-', mm, '-', dd])));
                    })
                    .toList()
                    .cast(),

            // for(var document in snapshot.data!.docs)
            //   ListTile(
            //     leading: Icon(Icons.filter_drama),
            //     title: Text(document.data()!['message']),
            //     trailing: Text(document.data()!['timestamp'] != 999999
            //         ? formatDate(
            //             DateTime.fromMillisecondsSinceEpoch(
            //                 favorite.timestamp * 1000),
            //             [yyyy, '-', mm, '-', dd])
            //         : "0000-00-00"),
            //   )
          );
        });
  }
}
