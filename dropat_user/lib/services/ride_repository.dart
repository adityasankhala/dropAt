import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/ride_model.dart';
import '../models/ride_status.dart';

class RideRepository {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<String> createRide({
    required RideModel ride,
    required double fare,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final docRef = _firestore.collection('rides').doc();

    await docRef.set({
      'rideId': docRef.id,
      'userId': user.uid,
      'pickup': {'lat': ride.pickup.latitude, 'lng': ride.pickup.longitude},
      'drop': {'lat': ride.drop.latitude, 'lng': ride.drop.longitude},
      'distanceMeters': ride.distanceMeters,
      'durationSeconds': ride.durationSeconds,
      'fare': fare,
      'status': RideStatus.requested.value,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }
}
