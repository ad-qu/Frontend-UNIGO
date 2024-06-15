class Challenge {
  Challenge({
    required this.idChallenge,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.question,
    required this.experience,
    required this.itinerary,
    this.imageURL,
  });

  final String idChallenge;
  final String name;
  final String description;
  final String latitude;
  final String longitude;
  final List<String>? question;
  final int experience;
  final String itinerary;
  final String? imageURL;

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        idChallenge: json["_id"],
        name: json["name"],
        description: json["description"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        question: List<String>.from(
          json["question"].map(
            (x) => x.toString(),
          ),
        ),
        experience: json["experience"],
        itinerary: json["itinerary"],
        imageURL: json["imageURL"],
      );

  factory Challenge.fromJson2(Map<String, dynamic> json) => Challenge(
        idChallenge: json["_id"],
        name: json["name"],
        description: json["description"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        question: List<String>.from(
          json["question"].map(
            (x) => x.toString(),
          ),
        ),
        experience: json["experience"],
        itinerary: json["itinerary"],
        imageURL: json["imageURL"],
      );

  get foto => null;

  Map<String, dynamic> toJson() => {
        "_id": idChallenge,
        "name": name,
        "description": description,
        "latitude": latitude,
        "longitude": longitude,
        "question": question,
        "experience": experience,
        "itinerary": itinerary,
        "imageURL": imageURL,
      };
}
