import 'package:flutter_application_1/models/firestore_data_model.dart';

class FirestoreDataViewModel {
  final FirestoreDataModel firestoreDataModel;
  FirestoreDataViewModel({required this.firestoreDataModel});

  String get id {
    return firestoreDataModel.id;
  }

  String get email {
    return firestoreDataModel.email;
  }

  String get message {
    return firestoreDataModel.message;
  }

  String get name {
    return firestoreDataModel.name;
  }

  int get timestamp {
    return firestoreDataModel.timestamp;
  }
}
