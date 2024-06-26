class Itinerary {
  Itinerary({
    required this.idItinerary,
    required this.name,
    this.imageURL,
    required this.number,
  });

  final String idItinerary;
  final String name;
  final String? imageURL;
  final int number;

  factory Itinerary.fromJson(Map<String, dynamic> json) => Itinerary(
        idItinerary: json["_id"],
        name: json["name"],
        imageURL: json["imageURL"],
        number: json["number"] ?? 0, // Asignar 0 si number es null
      );

  factory Itinerary.fromJson2(Map<String, dynamic> json) => Itinerary(
        idItinerary: json["_id"],
        name: json["name"],
        imageURL: json["imageURL"],
        number: json["number"] ?? 0,
      );

  get foto => null;

  Map<String, dynamic> toJson() => {
        "_id": idItinerary,
        "name": name,
        "imageURL": imageURL,
        "number": number,
      };
}
