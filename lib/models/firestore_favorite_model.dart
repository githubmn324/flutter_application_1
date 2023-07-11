class FirestoreFavoriteDataModel {
  /* members */
  final String id;
  final String email;
  final String message;
  final int timestamp;
  final bool isFavorite;

  /* constructors */
  FirestoreFavoriteDataModel(
      {required this.id,
      required this.email,
      required this.message,
      required this.timestamp,
      required this.isFavorite});

  // keyが文字列で値がdynamicなMapオブジェクトを FirestoreDataModel に変換
  FirestoreFavoriteDataModel.fromJson(
      String documentId, bool favorite, Map<String, dynamic> parsedJson)
      : id = documentId,
        email = parsedJson['email'] ?? "",
        message = parsedJson['text'] ?? "",
        timestamp = parsedJson['timestamp'],
        isFavorite = favorite;
}
