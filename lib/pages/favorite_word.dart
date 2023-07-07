import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stream_provider.dart';
import 'package:flutter_application_1/models/favorite_word.dart';
import 'package:flutter_application_1/models/favorite_word_details.dart';
import 'package:flutter_application_1/models/delete_result.dart';
import 'package:date_format/date_format.dart';

class StreamFirestoreDataPage extends StatelessWidget {
  const StreamFirestoreDataPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Using Provider.of to read stream data
    var favorites = Provider.of<List<FavoriteDataModel>>(context, listen: true);
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
                  builder: (context) =>
                      FavoriteWordDetailsPage(id: favorite.id),
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

class FavoriteWordDetailsPage extends StatelessWidget {
  final String id;
  final FirestoreService firestoreService = FirestoreService();

  FavoriteWordDetailsPage({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: MultiProvider(providers: [
        FutureProvider<FavoriteDataDetailModel>(
            create: (context) => firestoreService.getIndivFirestoreData(id),
            initialData: firestoreService.initialData),
      ], child: FavWordDetailsContent()),
    );
  }
}

class FavWordDetailsContent extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    FavoriteDataDetailModel favoriteDataDetailModel =
        Provider.of<FavoriteDataDetailModel>(context);
    return Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Center(
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(
                  children: [
                    Text('id: ${favoriteDataDetailModel.id}',
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryColor)),
                    Text('name: ${favoriteDataDetailModel.name}'),
                    Text('email: ${favoriteDataDetailModel.email}'),
                    Text('timestamp: ${favoriteDataDetailModel.timestamp}'),
                    Text(
                        'isPrivate: ${favoriteDataDetailModel.isPrivate.toString()}'),
                    SizedBox(height: 30),
                    ElevatedButton.icon(
                        // pattern(4) Using FutureProvider: onPressトリガーに画面遷移させる
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                WordDeletePage(id: favoriteDataDetailModel.id),
                          ));
                        },
                        icon: Icon(Icons.delete),
                        label: Text('Delete')),
                  ],
                ))));
  }
}

// pattern(4) Using FutureProvider: 画面遷移させる
class WordDeletePage extends StatelessWidget {
  final String id;

  WordDeletePage({required this.id});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        appBar: AppBar(title: Text('Details')),
        body: FutureProvider<DeleteResultModel>(
            create: (_) async {
              print('ID: $idを消します');
              return firestoreService.deleteDocument(id);
            },
            initialData:
                DeleteResultModel(isSucceed: false, message: 'deleting...'),
            child: Consumer<DeleteResultModel>(
                builder: (context, deleteProcessModel, child) {
              return Column(
                children: <Widget>[
                  Text("isSucceed: ${deleteProcessModel.isSucceed}"),
                  Text("message: ${deleteProcessModel.message}"),
                ],
              );
            })));
  }
}
