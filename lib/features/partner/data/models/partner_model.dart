class PartnerModel {
  final String id;
  final String name;
  final bool isOnline;
  final int todayPickups;
  final double todayEarnings;
  final double rating;
  final String
  verificationStatus; // 'unsubmitted', 'pending', 'verified', 'rejected'
  final String? aadharFrontUrl;
  final String? aadharBackUrl;
  final String? panFrontUrl;
  final String? panBackUrl;
  final String? selfieUrl;

  PartnerModel({
    required this.id,
    required this.name,
    required this.isOnline,
    required this.todayPickups,
    required this.todayEarnings,
    required this.rating,
    this.verificationStatus = 'unsubmitted',
    this.aadharFrontUrl,
    this.aadharBackUrl,
    this.panFrontUrl,
    this.panBackUrl,
    this.selfieUrl,
  });

  factory PartnerModel.fromMap(Map<String, dynamic> map, String id) {
    return PartnerModel(
      id: id,
      name: map['name'] ?? '',
      isOnline: map['isOnline'] ?? false,
      todayPickups: map['todayPickups']?.toInt() ?? 0,
      todayEarnings: map['todayEarnings']?.toDouble() ?? 0.0,
      rating: map['rating']?.toDouble() ?? 0.0,
      verificationStatus: map['verificationStatus'] ?? 'unsubmitted',
      aadharFrontUrl: map['aadharFrontUrl'],
      aadharBackUrl: map['aadharBackUrl'],
      panFrontUrl: map['panFrontUrl'],
      panBackUrl: map['panBackUrl'],
      selfieUrl: map['selfieUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isOnline': isOnline,
      'todayPickups': todayPickups,
      'todayEarnings': todayEarnings,
      'rating': rating,
      'verificationStatus': verificationStatus,
      'aadharFrontUrl': aadharFrontUrl,
      'aadharBackUrl': aadharBackUrl,
      'panFrontUrl': panFrontUrl,
      'panBackUrl': panBackUrl,
      'selfieUrl': selfieUrl,
    };
  }

  PartnerModel copyWith({
    String? id,
    String? name,
    bool? isOnline,
    int? todayPickups,
    double? todayEarnings,
    double? rating,
    String? verificationStatus,
    String? aadharFrontUrl,
    String? aadharBackUrl,
    String? panFrontUrl,
    String? panBackUrl,
    String? selfieUrl,
  }) {
    return PartnerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isOnline: isOnline ?? this.isOnline,
      todayPickups: todayPickups ?? this.todayPickups,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      rating: rating ?? this.rating,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      aadharFrontUrl: aadharFrontUrl ?? this.aadharFrontUrl,
      aadharBackUrl: aadharBackUrl ?? this.aadharBackUrl,
      panFrontUrl: panFrontUrl ?? this.panFrontUrl,
      panBackUrl: panBackUrl ?? this.panBackUrl,
      selfieUrl: selfieUrl ?? this.selfieUrl,
    );
  }
}
