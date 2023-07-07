import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth.dart';
import 'root_page.dart';
import 'providers/stream_provider.dart';
import 'providers/app_state.dart';
import 'package:english_words/english_words.dart';
import 'models/favorite_word.dart';

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
          // StreamProvider<List<FavoriteDataModel>>(
          //     create: (BuildContext context) =>
          //         _firestoreService.fetchFirestoreData(),
          //     initialData: [],
          //     catchError: (context, error) =>
          //         [createErrorMessage(error.toString())]),
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
