import 'dart:convert';

List<Store> storeFromJson(String str) => List<Store>.from(json.decode(str).map((x) => Store.fromJson(x)));

String storeToJson(List<Store> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Store {
  Store({
    this.id,
    this.name,
    this.img,
    this.zoneId,
    this.countryId,
    this.lng,
    this.lat,
    this.distance=0.0
  });

  String? id;
  String? name;
  String? img;
  String? zoneId;
  String? countryId;
  double? lng;
  double? lat;
  double? distance;

  factory Store.fromJson(Map<String, dynamic> json) => Store(
    id: json["id"],
    name: json["name"],
    img: json["img"],
    zoneId: json["zone_id"],
    countryId: json["country_id"],
    lng: json["lng"].toDouble(),
    lat: json["lat"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "img": img,
    "zone_id": zoneId,
    "country_id": countryId,
    "lng": lng,
    "lat": lat,
  };
}
