import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/models/firestore_data_model.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_application_1/views/firestore_stream_details_page.dart';

class FirestoreStreamPage extends StatelessWidget {
  const FirestoreStreamPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Using Provider.of to read stream data
    var favorites =
        Provider.of<List<FirestoreDataModel>>(context, listen: true);
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
                      FirestoreStreamDetailsPage(id: favorite.id),
                ));
              }),
      ],
    );
    // Using Consumer to read stream data
    // return Consumer<List<FirestoreDataModel>>(
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
