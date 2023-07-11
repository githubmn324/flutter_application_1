import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/firestore_services.dart';
import 'package:flutter_application_1/models/firestore_favorite_model.dart';
import 'package:flutter_application_1/views/firestore_stream_delete_page.dart';

class FirestoreStreamDetailsPage extends StatelessWidget {
  final String id;
  final FirestoreService firestoreService = FirestoreService();

  FirestoreStreamDetailsPage({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: MultiProvider(providers: [
        FutureProvider<FirestoreFavoriteDataModel>(
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
    FirestoreFavoriteDataModel firestoreFavoriteDataModel =
        Provider.of<FirestoreFavoriteDataModel>(context);
    return Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Center(
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(
                  children: [
                    Text('id: ${firestoreFavoriteDataModel.id}',
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryColor)),
                    Text('email: ${firestoreFavoriteDataModel.email}'),
                    Text('timestamp: ${firestoreFavoriteDataModel.timestamp}'),
                    SizedBox(height: 30),
                    ElevatedButton.icon(
                        // Using FutureProvider
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => WordDeletePage(
                                id: firestoreFavoriteDataModel.id),
                          ));
                        },
                        icon: Icon(Icons.delete),
                        label: Text('Delete')),
                  ],
                ))));
  }
}
