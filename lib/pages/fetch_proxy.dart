import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/stream_provider.dart';

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
