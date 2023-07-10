import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stream_provider.dart';

class FavoriteWordDetailsPage extends StatelessWidget {
  final String id;
  final FirestoreService firestoreService = FirestoreService();
  final DeleteData deleteData = DeleteData();

  FavoriteWordDetailsPage({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: MultiProvider(providers: [
        FutureProvider<FavoriteDataDetailModel>(
            create: (context) => firestoreService.getIndivFirestoreData(id),
            initialData: firestoreService.initialData),
        // pattern(1) Declare FutureProvider Here　⇒　× レンダリング時に削除処理が実行されてしまう
        FutureProvider<DeleteProcessModel>(
            lazy: true,
            create: (context) => firestoreService.deleteDocument(id),
            initialData:
                DeleteProcessModel(isSucceed: true, message: 'processing')),
        // // pattern(3) Using ChangeNotifierProvider
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
    //     Provider.of<DeleteProcessModel>(context);
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
                    // pattern(3) Using ChangeNotifierProvider
                    // Consumer<DeleteData>(builder: (context, deleteData, child) {
                    //   return Text(
                    //       '${deleteData.deleteProcessModel.isSucceed}: ${deleteData.deleteProcessModel.message}');
                    // }),
                    ElevatedButton.icon(
                        onPressed: () {
                          print('clicked');
                          // // pattern(1) read future provider here　⇒　×
                          // DeleteProcessModel deleteProcessModel =
                          //     Provider.of<DeleteProcessModel>(context,
                          //         listen: false);
                          // // pattern(1-2)
                          context.read<DeleteProcessModel>();
                          // // pattern(2) Using Future Provier Here
                          // FutureProvider<DeleteProcessModel>(
                          //   create: (_) async {
                          //     print('ID: ${favoriteDataDetailModel.id}を消します');
                          //     return firestoreService
                          //         .deleteDocument(favoriteDataDetailModel.id);
                          //   },
                          //   initialData: DeleteProcessModel(
                          //       isSucceed: false, message: 'processing'),
                          // );
                          // // pattern(3) Using ChangeNotifier Provider
                          // context
                          //     .read<DeleteData>()
                          //     .deleteDocument(favoriteDataDetailModel.id);
                        },
                        icon: Icon(Icons.delete),
                        label: Text('Delete')),
                  ],
                ))));
  }
}
