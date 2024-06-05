import 'dart:convert';
import 'package:unigo/models/user.dart';

List<ChallengeD> subjectFromJson(String str) =>
    List<ChallengeD>.from(json.decode(str).map((x) => ChallengeD.fromJson(x)));

String subjectToJson(List<ChallengeD> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChallengeD {
  ChallengeD({
    required this.id,
    required this.name,
    required this.descr,
    required this.exp,
    required this.users,
    required this.questions,
    this.lat = "0",
    this.long = "0",
  });

  final String id;
  final String name;
  final String descr;
  final int exp;
  final List<User> users;
  final String lat;
  final List<String> questions;
  final String long;

  factory ChallengeD.fromJson(Map<String, dynamic> json) => ChallengeD(
      id: json["_id"],
      name: json["name"],
      descr: json["descr"],
      exp: json["exp"],
      users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
      questions: List<String>.from(json["questions"].map((x) => x.toString())),
      lat: json["lat"],
      long: json["long"]);

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "descr": descr,
        "exp": exp,
        "users": List<dynamic>.from(users.map((x) => x.toJson())),
      };
}
