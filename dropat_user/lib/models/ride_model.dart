import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'ride_status.dart';
import 'vehicle_type.dart';

class RideModel {
  final String? rideId;
  final String? userId;
  final String? driverId;
  final LatLng pickup;
  final LatLng drop;
  final String pickupAddress;
  final String dropAddress;
  final double distanceMeters;
  final int durationSeconds;
  final VehicleType vehicleType;
  final double fare;
  final double discountAmount;
  final double totalPaid;
  final String paymentMethod;
  final RideStatus status;
  final String? cancellationReason;
  final double? rating;
  final String? feedback;
  final double? tipAmount;
  final String? encodedPolyline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RideModel({
    this.rideId,
    this.userId,
    this.driverId,
    required this.pickup,
    required this.drop,
    this.pickupAddress = '',
    this.dropAddress = '',
    required this.distanceMeters,
    required this.durationSeconds,
    this.vehicleType = VehicleType.mini,
    this.fare = 0,
    this.discountAmount = 0,
    this.totalPaid = 0,
    this.paymentMethod = 'CASH',
    this.status = RideStatus.requested,
    this.cancellationReason,
    this.rating,
    this.feedback,
    this.tipAmount,
    this.encodedPolyline,
    this.createdAt,
    this.updatedAt,
  });

  double get distanceKm => distanceMeters / 1000;
  int get durationMin => (durationSeconds / 60).round();

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'userId': userId,
      'driverId': driverId,
      'pickup': {'lat': pickup.latitude, 'lng': pickup.longitude},
      'drop': {'lat': drop.latitude, 'lng': drop.longitude},
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'distanceMeters': distanceMeters,
      'durationSeconds': durationSeconds,
      'vehicleType': vehicleType.value,
      'fare': fare,
      'discountAmount': discountAmount,
      'totalPaid': totalPaid,
      'paymentMethod': paymentMethod,
      'status': status.value,
      'cancellationReason': cancellationReason,
      'rating': rating,
      'feedback': feedback,
      'tipAmount': tipAmount,
      'encodedPolyline': encodedPolyline,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory RideModel.fromMap(Map<String, dynamic> map) {
    final pickupMap = map['pickup'] as Map<String, dynamic>? ?? {};
    final dropMap = map['drop'] as Map<String, dynamic>? ?? {};

    return RideModel(
      rideId: map['rideId'],
      userId: map['userId'],
      driverId: map['driverId'],
      pickup: LatLng(
        (pickupMap['lat'] ?? 0).toDouble(),
        (pickupMap['lng'] ?? 0).toDouble(),
      ),
      drop: LatLng(
        (dropMap['lat'] ?? 0).toDouble(),
        (dropMap['lng'] ?? 0).toDouble(),
      ),
      pickupAddress: map['pickupAddress'] ?? '',
      dropAddress: map['dropAddress'] ?? '',
      distanceMeters: (map['distanceMeters'] ?? 0).toDouble(),
      durationSeconds: (map['durationSeconds'] ?? 0).toInt(),
      vehicleType: VehicleTypeX.fromString(map['vehicleType'] ?? 'MINI'),
      fare: (map['fare'] ?? 0).toDouble(),
      discountAmount: (map['discountAmount'] ?? 0).toDouble(),
      totalPaid: (map['totalPaid'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'CASH',
      status: RideStatusX.fromString(map['status'] ?? 'REQUESTED'),
      cancellationReason: map['cancellationReason'],
      rating: map['rating']?.toDouble(),
      feedback: map['feedback'],
      tipAmount: map['tipAmount']?.toDouble(),
      encodedPolyline: map['encodedPolyline'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  RideModel copyWith({
    String? rideId,
    String? driverId,
    double? fare,
    double? discountAmount,
    double? totalPaid,
    String? paymentMethod,
    RideStatus? status,
    String? cancellationReason,
    double? rating,
    String? feedback,
    double? tipAmount,
    String? encodedPolyline,
  }) {
    return RideModel(
      rideId: rideId ?? this.rideId,
      userId: userId,
      driverId: driverId ?? this.driverId,
      pickup: pickup,
      drop: drop,
      pickupAddress: pickupAddress,
      dropAddress: dropAddress,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      vehicleType: vehicleType,
      fare: fare ?? this.fare,
      discountAmount: discountAmount ?? this.discountAmount,
      totalPaid: totalPaid ?? this.totalPaid,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      tipAmount: tipAmount ?? this.tipAmount,
      encodedPolyline: encodedPolyline ?? this.encodedPolyline,
      createdAt: createdAt,
    );
  }
}
