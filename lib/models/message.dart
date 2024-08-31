class Messages {
  Messages({
    required this.idUser,
    required this.senderName,
    required this.message,
  });

  final String idUser;
  final String senderName;
  final String message;

  factory Messages.fromJson(Map<String, dynamic> json) => Messages(
        idUser: json["idUser"],
        senderName: json["senderName"],
        message: json["message"],
      );

  factory Messages.fromJson2(Map<String, dynamic> json) => Messages(
        idUser: json["idUser"],
        senderName: json["senderName"],
        message: json["message"],
      );

  get foto => null;

  Map<String, dynamic> toJson() => {
        "_id": idUser,
        "senderName": senderName,
        "message": message,
      };
}
