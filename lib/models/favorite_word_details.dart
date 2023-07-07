class FavoriteDataDetailModel {
  final String id;
  final String message;
  final String name;
  final int timestamp;
  final String email;
  final bool isPrivate;
  final bool isFavorite;

  FavoriteDataDetailModel(
      {required this.id,
      required this.message,
      required this.name,
      required this.timestamp,
      required this.email,
      required this.isPrivate,
      required this.isFavorite});

  // keyが文字列で値がdynamicなMapオブジェクトを FavoriteDataModel に変換
  FavoriteDataDetailModel.fromJson(
      String documentId, bool favorite, Map<String, dynamic> parsedJson)
      : id = documentId,
        email = parsedJson['email'] ?? "",
        message = parsedJson['text'] ?? "",
        name = parsedJson['name'] ?? "",
        timestamp = parsedJson['timestamp'],
        isPrivate = parsedJson['isPrivate'],
        isFavorite = favorite;
}
