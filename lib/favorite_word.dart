import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stream_provider.dart';

class FavoriteWordPage extends StatelessWidget {
  final String id;
  final FirestoreService firestoreService = FirestoreService();

  FavoriteWordPage({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: FutureProvider<FavoriteDataDetailModel>(
        create: (context) => firestoreService.getIndivFirestoreData(id),
        initialData: firestoreService.initialData,
        child: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Center(child: Consumer<FavoriteDataDetailModel>(
            builder: (context, favorite, child) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  Text(
                    'id: ${favorite.id}',
                    style: TextStyle(
                        fontSize: 20, color: Theme.of(context).primaryColor),
                  ),
                  Text('name: ${favorite.name}'),
                  Text('email: ${favorite.email}'),
                  Text('message: ${favorite.message}'),
                  Text('timestamp: ${favorite.timestamp}'),
                ]),
              );
            },
          )),
        ),
      ),
    );
  }
}
