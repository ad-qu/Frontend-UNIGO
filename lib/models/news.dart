class New {
  New({
    required this.idNew,
    required this.title,
    required this.description,
    this.imageURL,
    required this.date,
  });

  final String idNew;
  final String title;
  final String description;
  final String? imageURL;
  final String date;

  factory New.fromJson(Map<String, dynamic> json) => New(
        idNew: json["idNew"],
        title: json["title"],
        description: json["description"],
        imageURL: json["imageURL"],
        date: json["date"],
      );

  factory New.fromJson2(Map<String, dynamic> json) => New(
        idNew: json["_id"],
        title: json["title"],
        description: json["description"],
        imageURL: json["imageURL"],
        date: json["date"],
      );

  get foto => null;

  Map<String, dynamic> toJson() => {
        "_id": idNew,
        "title": title,
        "description": description,
        "imageURL": imageURL,
        "date": date,
      };
}
