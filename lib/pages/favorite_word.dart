import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stream_provider.dart';
import 'package:flutter_application_1/models/favorite_word_details.dart';
import 'package:flutter_application_1/models/delete_result.dart';

class FavoriteWordDetailsPage extends StatelessWidget {
  final String id;
  final FirestoreService firestoreService = FirestoreService();

  // // pattern(3) Using ChangeNotifierProvider
  // final DeleteData deleteData = DeleteData();

  FavoriteWordDetailsPage({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: MultiProvider(providers: [
        FutureProvider<FavoriteDataDetailModel>(
            create: (context) => firestoreService.getIndivFirestoreData(id),
            initialData: firestoreService.initialData),
        // // pattern(1) Declare FutureProvider Here　⇒　× レンダリング時に削除処理が実行されてしまう
        // FutureProvider<DeleteProcessModel>(
        //     create: (context) => firestoreService.deleteDocument(id),
        //     initialData:
        //         DeleteProcessModel(isSucceed: true, message: 'processing')),
        // pattern(3) Using ChangeNotifierProvider
        // ChangeNotifierProvider<DeleteData>(
        //   create: (_) => DeleteData(),
        // ),
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
    // // pattern(1) Using Future Provider
    // DeleteProcessModel deleteProcessModel =
    //     Provider.of<DeleteProcessModel>(context, listen:true);
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
                    // // pattern(2) Using FutureProvider ⇒上位でprovider宣言できないので消す
                    // Consumer<DeleteProcessModel>(
                    //     builder: (context, deleteData, child) {
                    //   return Text(
                    //       '${deleteProcessModel.isSucceed}: ${deleteProcessModel.message}');
                    // }),
                    // // pattern(3) Using ChangeNotifierProvider
                    // Consumer<DeleteData>(builder: (context, deleteData, child) {
                    //   return Text(
                    //       '${deleteData.deleteProcessModel.isSucceed}: ${deleteData.deleteProcessModel.message}');
                    // }),
                    ElevatedButton.icon(
                        // // pattern(1) read future provider here　⇒　×
                        // onPressed: () {
                        //   print('clicked');
                        //   // Text(deleteProcessModel.message);

                        // pattern(2) Using Future Provier Here
                        // onPressed: () {
                        //   FutureProvider<void>(
                        //       create: (_) async {
                        //         print('ID: ${favoriteDataDetailModel.id}を消します');
                        //         firestoreService
                        //             .deleteDocument(favoriteDataDetailModel.id);
                        //       },
                        //       initialData: null,
                        //       // DeleteProcessModel(
                        //       //     isSucceed: false, message: 'processing'),
                        //     );}

                        // // pattern(3) Using ChangeNotifier Provider
                        // onPressed: () {
                        //   context
                        //       .read<DeleteData>()
                        //       .deleteDocument(favoriteDataDetailModel.id);
                        // },

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
    final DeleteData deleteData = DeleteData();
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        appBar: AppBar(title: Text('Details')),
        body: FutureProvider<DeleteResultModel>(
            create: (_) async {
              print('ID: $idを消します');
              return deleteData.deleteDocument(id);
            },
            initialData:
                DeleteResultModel(isSucceed: false, message: 'processing'),
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
