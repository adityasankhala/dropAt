import 'package:cloud_firestore/cloud_firestore.dart';

class SavedPlace {
  final String name;
  final String address;
  final double lat;
  final double lng;

  SavedPlace({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'lat': lat,
        'lng': lng,
      };

  factory SavedPlace.fromMap(Map<String, dynamic> map) => SavedPlace(
        name: map['name'] ?? '',
        address: map['address'] ?? '',
        lat: (map['lat'] ?? 0).toDouble(),
        lng: (map['lng'] ?? 0).toDouble(),
      );
}

class UserProfileModel {
  final String uid;
  final String name;
  final String phone;
  final String? email;
  final String? photoUrl;
  final double rating;
  final double walletBalance;
  final List<SavedPlace> savedPlaces;
  final DateTime? createdAt;

  UserProfileModel({
    required this.uid,
    required this.name,
    required this.phone,
    this.email,
    this.photoUrl,
    this.rating = 5.0,
    this.walletBalance = 0,
    this.savedPlaces = const [],
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'rating': rating,
      'walletBalance': walletBalance,
      'savedPlaces': savedPlaces.map((p) => p.toMap()).toList(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      photoUrl: map['photoUrl'],
      rating: (map['rating'] ?? 5.0).toDouble(),
      walletBalance: (map['walletBalance'] ?? 0).toDouble(),
      savedPlaces: (map['savedPlaces'] as List<dynamic>?)
              ?.map((p) => SavedPlace.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  UserProfileModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    double? rating,
    double? walletBalance,
    List<SavedPlace>? savedPlaces,
  }) {
    return UserProfileModel(
      uid: uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
      walletBalance: walletBalance ?? this.walletBalance,
      savedPlaces: savedPlaces ?? this.savedPlaces,
      createdAt: createdAt,
    );
  }
}
