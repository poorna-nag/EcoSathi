class PartnerModel {
  final String id;
  final String name;
  final bool isOnline;
  final int todayPickups;
  final double todayEarnings;
  final double rating;

  PartnerModel({
    required this.id,
    required this.name,
    required this.isOnline,
    required this.todayPickups,
    required this.todayEarnings,
    required this.rating,
  });

  factory PartnerModel.fromMap(Map<String, dynamic> map, String id) {
    return PartnerModel(
      id: id,
      name: map['name'] ?? '',
      isOnline: map['isOnline'] ?? false,
      todayPickups: map['todayPickups']?.toInt() ?? 0,
      todayEarnings: map['todayEarnings']?.toDouble() ?? 0.0,
      rating: map['rating']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isOnline': isOnline,
      'todayPickups': todayPickups,
      'todayEarnings': todayEarnings,
      'rating': rating,
    };
  }

  PartnerModel copyWith({
    String? id,
    String? name,
    bool? isOnline,
    int? todayPickups,
    double? todayEarnings,
    double? rating,
  }) {
    return PartnerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isOnline: isOnline ?? this.isOnline,
      todayPickups: todayPickups ?? this.todayPickups,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      rating: rating ?? this.rating,
    );
  }
}
