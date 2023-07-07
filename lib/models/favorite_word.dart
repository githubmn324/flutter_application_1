class FavoriteDataModel {
  final String id;
  final String message;
  final String name;
  final int timestamp;

  FavoriteDataModel(
      {required this.id,
      required this.message,
      required this.name,
      required this.timestamp});

  // keyが文字列で値がdynamicなMapオブジェクトを FavoriteDataModel に変換
  FavoriteDataModel.fromJson(String documentId, Map<String, dynamic> parsedJson)
      : id = documentId,
        // : message = parsedJson['message'], // catchErrorの動作確認
        message = parsedJson['text'] ?? "",
        name = parsedJson['name'] ?? "",
        timestamp = parsedJson['timestamp'];
}