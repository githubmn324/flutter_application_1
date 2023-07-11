class FirestoreDataModel {
  final String id;
  final String email;
  final String message;
  final String name;
  final int timestamp;

  FirestoreDataModel(
      {required this.id,
      required this.email,
      required this.message,
      required this.name,
      required this.timestamp});

  // keyが文字列で値がdynamicなMapオブジェクトを FirestoreDataModel に変換
  FirestoreDataModel.fromJson(
      String documentId, Map<String, dynamic> parsedJson)
      : id = documentId,
        email = parsedJson['email'] ?? "",
        message = parsedJson['text'] ?? "",
        name = parsedJson['name'] ?? "",
        timestamp = parsedJson['timestamp'];
}
