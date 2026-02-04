class FareService {
  // Base pricing (example – adjustable later)
  static const double baseFare = 40; // ₹
  static const double perKmRate = 12; // ₹ per km
  static const double perMinRate = 2; // ₹ per min

  static double calculateFare({
    required double distanceKm,
    required int durationMin,
  }) {
    final distanceFare = distanceKm * perKmRate;
    final timeFare = durationMin * perMinRate;

    final total = baseFare + distanceFare + timeFare;

    return total.roundToDouble();
  }
}
