class Campus {
  Campus({
    required this.idCampus,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String idCampus;
  final String name;
  final String latitude;
  final String longitude;

  factory Campus.fromJson(Map<String, dynamic> json) => Campus(
        idCampus: json["idCampus"],
        name: json["name"],
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  factory Campus.fromJson2(Map<String, dynamic> json) => Campus(
        idCampus: json["_id"],
        name: json["name"],
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  get foto => null;

  Map<String, dynamic> toJson() => {
        "_id": idCampus,
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
      };
}
