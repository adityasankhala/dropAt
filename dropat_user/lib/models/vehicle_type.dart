import 'package:flutter/material.dart';

enum VehicleType { bike, auto, mini, sedan, suv, shuttle }

extension VehicleTypeX on VehicleType {
  String get displayName {
    switch (this) {
      case VehicleType.bike:
        return 'Bike';
      case VehicleType.auto:
        return 'Auto';
      case VehicleType.mini:
        return 'DropAt Mini';
      case VehicleType.sedan:
        return 'DropAt Sedan';
      case VehicleType.suv:
        return 'DropAt SUV';
      case VehicleType.shuttle:
        return 'Shuttle';
    }
  }

  String get shortName {
    switch (this) {
      case VehicleType.bike:
        return 'Bike';
      case VehicleType.auto:
        return 'Auto';
      case VehicleType.mini:
        return 'Mini';
      case VehicleType.sedan:
        return 'Prime Sedan';
      case VehicleType.suv:
        return 'SUV';
      case VehicleType.shuttle:
        return 'Shuttle';
    }
  }

  String get description {
    switch (this) {
      case VehicleType.bike:
        return 'Quick & affordable';
      case VehicleType.auto:
        return 'Affordable rides';
      case VehicleType.mini:
        return 'Compact & comfortable';
      case VehicleType.sedan:
        return 'Premium comfort';
      case VehicleType.suv:
        return 'Extra space & luxury';
      case VehicleType.shuttle:
        return 'Share & save';
    }
  }

  String get emoji {
    switch (this) {
      case VehicleType.bike:
        return '🏍️';
      case VehicleType.auto:
        return '🛺';
      case VehicleType.mini:
        return '🚗';
      case VehicleType.sedan:
        return '🚕';
      case VehicleType.suv:
        return '🚙';
      case VehicleType.shuttle:
        return '🚐';
    }
  }

  IconData get icon {
    switch (this) {
      case VehicleType.bike:
        return Icons.motorcycle_rounded;
      case VehicleType.auto:
        return Icons.electric_rickshaw;
      case VehicleType.mini:
        return Icons.directions_car;
      case VehicleType.sedan:
        return Icons.local_taxi;
      case VehicleType.suv:
        return Icons.airport_shuttle;
      case VehicleType.shuttle:
        return Icons.directions_bus;
    }
  }

  String get seats {
    switch (this) {
      case VehicleType.bike:
        return '1 person';
      case VehicleType.auto:
        return '2-3 person';
      case VehicleType.mini:
        return '3-4 person';
      case VehicleType.sedan:
        return '4 person';
      case VehicleType.suv:
        return '6 person';
      case VehicleType.shuttle:
        return '10+ person';
    }
  }

  double get baseFareMultiplier {
    switch (this) {
      case VehicleType.bike:
        return 0.6;
      case VehicleType.auto:
        return 1.0;
      case VehicleType.mini:
        return 1.3;
      case VehicleType.sedan:
        return 1.7;
      case VehicleType.suv:
        return 2.2;
      case VehicleType.shuttle:
        return 0.4;
    }
  }

  String get value => name.toUpperCase();

  static VehicleType fromString(String value) {
    return VehicleType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => VehicleType.mini,
    );
  }
}
