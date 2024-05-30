class Entity {
  Entity({
    required this.idEntity,
    required this.name,
    required this.description,
    this.imageURL,
    this.verified,
    required this.admin,
  });

  final String idEntity;
  final String name;
  final String description;
  final String? imageURL;
  final String? verified;
  final String admin;

  factory Entity.fromJson(Map<String, dynamic> json) => Entity(
        idEntity: json["_id"],
        name: json["name"],
        description: json["description"],
        imageURL: json["imageURL"],
        verified: json["verified"],
        admin: json["admin"],
      );

  factory Entity.fromJson2(Map<String, dynamic> json) => Entity(
        idEntity: json["_id"],
        name: json["name"],
        description: json["description"],
        imageURL: json["imageURL"],
        verified: json["verified"],
        admin: json["admin"],
      );

  get foto => null;

  Map<String, dynamic> toJson() => {
        "_id": idEntity,
        "name": name,
        "description": description,
        "imageURL": imageURL,
        "verified": verified,
        "admin": admin,
      };
}
