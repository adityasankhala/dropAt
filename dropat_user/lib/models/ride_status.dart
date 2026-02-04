enum RideStatus { requested, accepted, arrived, started, completed, cancelled }

extension RideStatusX on RideStatus {
  String get value {
    return name.toUpperCase();
  }
}
