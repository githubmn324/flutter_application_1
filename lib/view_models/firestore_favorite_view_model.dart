import 'package:flutter_application_1/models/firestore_favorite_model.dart';

class FirestoreFavoriteViewModel {
  final FirestoreFavoriteDataModel firestoreFavoriteDataModel;
  FirestoreFavoriteViewModel({required this.firestoreFavoriteDataModel});

  String get id {
    return firestoreFavoriteDataModel.id;
  }

  String get email {
    return firestoreFavoriteDataModel.email;
  }

  String get message {
    return firestoreFavoriteDataModel.message;
  }

  int get timestamp {
    return firestoreFavoriteDataModel.timestamp;
  }

  bool get isFavorite {
    return firestoreFavoriteDataModel.isFavorite;
  }
}
