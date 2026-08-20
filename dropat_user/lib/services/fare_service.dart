import '../models/vehicle_type.dart';

class FareBreakdown {
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double surgeFactor;
  final double subtotal;
  final double discount;
  final double total;

  FareBreakdown({
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.surgeFactor,
    required this.subtotal,
    this.discount = 0,
    required this.total,
  });
}

class FareService {
  /// Calculate fare with a realistic tiered pricing model based on vehicle type
  static FareBreakdown calculateFare({
    required double distanceKm,
    required int durationMin,
    required VehicleType vehicleType,
    double surgeFactor = 1.0,
    double discount = 0,
  }) {
    double baseFare = 0;
    double perKmRate = 0;
    double perMinRate = 1.5; // Average waiting/time charge

    switch (vehicleType) {
      case VehicleType.bike:
        baseFare = 15;
        perKmRate = 7;
        perMinRate = 1.0;
        break;
      case VehicleType.auto:
        baseFare = 25;
        perKmRate = 10;
        perMinRate = 1.2;
        break;
      case VehicleType.mini:
        baseFare = 40;
        perKmRate = 14;
        perMinRate = 2.0;
        break;
      case VehicleType.sedan:
        baseFare = 50;
        perKmRate = 16;
        perMinRate = 2.5;
        break;
      case VehicleType.suv:
        baseFare = 70;
        perKmRate = 20;
        perMinRate = 3.0;
        break;
      case VehicleType.shuttle:
        baseFare = 20;
        perKmRate = 5;
        perMinRate = 0.5;
        break;
    }

    final distanceFare = distanceKm * perKmRate;
    final timeFare = durationMin * perMinRate;

    final subtotal = (baseFare + distanceFare + timeFare) * surgeFactor;
    final total = (subtotal - discount).clamp(0, double.infinity);

    return FareBreakdown(
      baseFare: baseFare.roundToDouble(),
      distanceFare: distanceFare.roundToDouble(),
      timeFare: timeFare.roundToDouble(),
      surgeFactor: surgeFactor,
      subtotal: subtotal.roundToDouble(),
      discount: discount,
      total: total.roundToDouble(),
    );
  }

  /// Quick fare estimate for a vehicle type (used in vehicle cards)
  static String estimateFare({
    required double distanceKm,
    required int durationMin,
    required VehicleType vehicleType,
  }) {
    final breakdown = calculateFare(
      distanceKm: distanceKm,
      durationMin: durationMin,
      vehicleType: vehicleType,
    );

    // Show range (±10%)
    final low = (breakdown.total * 0.9).round();
    final high = (breakdown.total * 1.1).round();

    if (vehicleType == VehicleType.auto || vehicleType == VehicleType.bike) {
      return '₹$low–₹$high';
    }
    return '₹${breakdown.total.toInt()}';
  }
}
