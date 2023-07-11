import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/delete_result.dart';
import '../repositories/firestore_services.dart';
import 'package:provider/provider.dart';

class WordDeletePage extends StatelessWidget {
  final String id;

  final FirestoreService firestoreService = FirestoreService();
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
