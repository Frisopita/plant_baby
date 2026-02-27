import 'dart:convert';

class Plant {
  Plant({
    required this.id,
    required this.nickname,
    required this.scientificName,
    this.imageUrl,
    DateTime? lastWatered,
    required this.waterFrequencyDays,
  }) : lastWatered = lastWatered ?? DateTime.now();

  final String id;
  final String nickname;
  final String scientificName;
  final String? imageUrl;
  final DateTime lastWatered;
  final int waterFrequencyDays;

  bool get needsWater => daysUntilNextWater <= 0;

  int get daysSinceLastWatered {
    final now = DateTime.now();
    return now.difference(
      DateTime(lastWatered.year, lastWatered.month, lastWatered.day),
    ).inDays;
  }

  int get daysUntilNextWater => waterFrequencyDays - daysSinceLastWatered;

  Plant copyWith({
    String? id,
    String? nickname,
    String? scientificName,
    String? imageUrl,
    DateTime? lastWatered,
    int? waterFrequencyDays,
  }) {
    return Plant(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      scientificName: scientificName ?? this.scientificName,
      imageUrl: imageUrl ?? this.imageUrl,
      lastWatered: lastWatered ?? this.lastWatered,
      waterFrequencyDays: waterFrequencyDays ?? this.waterFrequencyDays,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nickname': nickname,
      'scientificName': scientificName,
      'imageUrl': imageUrl,
      'lastWatered': lastWatered.toIso8601String(),
      'waterFrequencyDays': waterFrequencyDays,
    };
  }

  factory Plant.fromJson(Map<String, dynamic> map) {
    return Plant(
      id: map['id'] as String,
      nickname: map['nickname'] as String,
      scientificName: map['scientificName'] as String,
      imageUrl: map['imageUrl'] as String?,
      lastWatered: DateTime.parse(map['lastWatered'] as String),
      waterFrequencyDays: map['waterFrequencyDays'] as int,
    );
  }

  static String encodeList(List<Plant> plants) {
    final list = plants.map((p) => p.toJson()).toList();
    return jsonEncode(list);
  }

  static List<Plant> decodeList(String data) {
    final list = jsonDecode(data) as List<dynamic>;
    return list
        .map((item) => Plant.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

