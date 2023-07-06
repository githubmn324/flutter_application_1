import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stream_provider.dart';

class FavoriteWordPage extends StatelessWidget {
  final String id;
  final FirestoreService firestoreService = FirestoreService();
  final DeleteData deleteData = DeleteData();

  FavoriteWordPage({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: MultiProvider(providers: [
        FutureProvider<FavoriteDataDetailModel>(
            create: (context) => firestoreService.getIndivFirestoreData(id),
            initialData: firestoreService.initialData),
        // FutureProvider<DeleteProcessModel>(
        //   create: (_) => DeleteData(),
        //   initialData: DeleteProcessModel(
        //       isSucceed: false, message: 'processing'),
        // ),
      ], child: DetailContainer()),
    );
  }
}

class DetailContainer extends StatelessWidget {
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
                        onPressed: () => FutureProvider<DeleteProcessModel>(
                              create: (_) => firestoreService
                                  .deleteDocument(favoriteDataDetailModel.id),
                              initialData: DeleteProcessModel(
                                  isSucceed: false, message: 'processing'),
                            ),
                        icon: Icon(Icons.delete),
                        label: Text('Delete')),
                  ],
                ))));
  }
}
