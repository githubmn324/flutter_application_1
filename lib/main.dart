import 'package:date_format/date_format.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/favorite_word.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth.dart';
import 'root_page.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'stream_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  FavoriteDataModel createErrorMessage(error) {
    return FavoriteDataModel(
        id: "", message: error, name: "error", timestamp: 999999);
  }

  @override
  Widget build(BuildContext context) {
    final _firestoreService = FirestoreService();

    final darkTheme = ThemeData.from(
      colorScheme: ColorScheme.dark(primary: Colors.blueGrey),
    );

    return MultiProvider(
        providers: [
          // アプリ起動中にユーザがお気に入りしたお気に入り一覧を管理
          ChangeNotifierProvider(
            create: ((context) => MyAppState()),
          ),
          // Firestoreのストリームデータを管理
          StreamProvider<List<FavoriteDataModel>>(
              create: (BuildContext context) =>
                  _firestoreService.fetchFirestoreData(),
              initialData: [],
              catchError: (context, error) =>
                  [createErrorMessage(error.toString())]),
          // ProxyProvider<MyAppState, <List<FavoriteDataDetailModel>>>(
          //     create: (_) => _firestoreService.getFirestoreData(),
          //     update: (_, myAppState, dataListModel) {
          //       dataListModel!.updateList(myAppState.favorites);
          //       return dataListModel;
          //     })
          // FutureProvider<List<FavoriteDataModel>>(
          //   create: (context) => _firestoreService.getFirestoreData(),
          //   initialData: [initialData],
          //   catchError: (context, error) =>init()
          //       [createErrorMessage(error.toString())],
          // )
        ],
        child: MaterialApp(
          title: 'flutter_application_1',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          ),
          darkTheme: darkTheme,
          home: RootPage(auth: Auth()),
        ));
  }
}

class MyAppState extends ChangeNotifier {
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

class ProxyTest extends StatelessWidget {
  const ProxyTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<MyAppState, FirestoreFavoriteList>(
        create: (context) => FirestoreFavoriteList(),
        update: (context, myAppState, firestoreFavoriteList) {
          firestoreFavoriteList!.getFirestoreData(myAppState.favorites);
          return firestoreFavoriteList;
        },
        child: FfList());
  }
}

class FfList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FirestoreFavoriteList>(
      builder: (context, model, _) {
        return ListView.builder(
          itemCount: model.firestoreDataList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(model.firestoreDataList[index].message),
                  ),
                  Offstage(
                    offstage: !model.firestoreDataList[index].isFavorite,
                    child: Text(
                      'お気に入り',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class StreamFirestoreDataPage extends StatelessWidget {
  const StreamFirestoreDataPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Using Provider.of to read stream data
    var favorites = Provider.of<List<FavoriteDataModel>>(context);
    return ListView(
      children: [
        Padding(
            padding: const EdgeInsets.all(20),
            child: (favorites.isEmpty)
                ? Text('You have no message.')
                : ((favorites.first.message == 'fetching')
                    ? Center(child: CircularProgressIndicator())
                    : Text('You have ${favorites.length} messages.'))),
        for (var favorite in favorites)
          ListTile(
              leading: Icon(Icons.filter_drama),
              title: Text(favorite.message),
              subtitle: Text('(ID: ${favorite.id})'),
              trailing: Text(favorite.timestamp != 999999
                  ? formatDate(
                      DateTime.fromMillisecondsSinceEpoch(
                          favorite.timestamp * 1000),
                      [yyyy, '-', mm, '-', dd])
                  : "0000-00-00"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => FavoriteWordPage(id: favorite.id),
                ));
              }),
      ],
    );
    // Using Consumer to read stream data
    // return Consumer<List<FavoriteDataModel>>(
    //     builder: (context, favorites, child) {
    //   return ListView(
    //     children: [
    //       Padding(
    //           padding: const EdgeInsets.all(20),
    //           child: Text(favorites.first.message == 'fetching'
    //               ? 'Currently fetching data... please wait.'
    //               : 'You have ${favorites.length} new messages.')),
    //       for (var favorite in favorites)
    //         ListTile(
    //           leading: Icon(Icons.filter_drama),
    //           title: Text(favorite.message),
    //           trailing: Text(favorite.timestamp != 999999
    //               ? formatDate(
    //                   DateTime.fromMillisecondsSinceEpoch(
    //                       favorite.timestamp * 1000),
    //                   [yyyy, '-', mm, '-', dd])
    //               : "0000-00-00"),
    //         ),
    //     ],
    //   );
    // });
  }
}
