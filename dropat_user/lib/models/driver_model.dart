import 'package:cloud_firestore/cloud_firestore.dart';
import 'vehicle_type.dart';

class DriverModel {
  final String uid;
  final String name;
  final String phone;
  final String? photoUrl;
  final double rating;
  final String vehicleName;
  final String vehicleNumber;
  final VehicleType vehicleType;
  final bool isOnline;
  final double? lat;
  final double? lng;

  DriverModel({
    required this.uid,
    required this.name,
    required this.phone,
    this.photoUrl,
    this.rating = 5.0,
    required this.vehicleName,
    required this.vehicleNumber,
    required this.vehicleType,
    this.isOnline = false,
    this.lat,
    this.lng,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'rating': rating,
      'vehicleName': vehicleName,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType.value,
      'isOnline': isOnline,
      'currentLocation': lat != null && lng != null
          ? {'lat': lat, 'lng': lng}
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    final loc = map['currentLocation'] as Map<String, dynamic>?;
    return DriverModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],
      rating: (map['rating'] ?? 5.0).toDouble(),
      vehicleName: map['vehicleName'] ?? '',
      vehicleNumber: map['vehicleNumber'] ?? '',
      vehicleType: VehicleTypeX.fromString(map['vehicleType'] ?? 'MINI'),
      isOnline: map['isOnline'] ?? false,
      lat: loc?['lat']?.toDouble(),
      lng: loc?['lng']?.toDouble(),
    );
  }
}
