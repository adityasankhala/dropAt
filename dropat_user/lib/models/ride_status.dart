enum RideStatus {
  requested,
  searching,
  accepted,
  driverEnRoute,
  arrived,
  started,
  completed,
  cancelled,
}

extension RideStatusX on RideStatus {
  String get value => name.toUpperCase();

  String get displayLabel {
    switch (this) {
      case RideStatus.requested:
        return 'Requesting...';
      case RideStatus.searching:
        return 'Finding driver...';
      case RideStatus.accepted:
        return 'Driver assigned';
      case RideStatus.driverEnRoute:
        return 'Driver is on the way';
      case RideStatus.arrived:
        return 'Driver has arrived';
      case RideStatus.started:
        return 'Ride in progress';
      case RideStatus.completed:
        return 'Ride completed';
      case RideStatus.cancelled:
        return 'Ride cancelled';
    }
  }

  bool get isActive =>
      this == RideStatus.accepted ||
      this == RideStatus.driverEnRoute ||
      this == RideStatus.arrived ||
      this == RideStatus.started;

  static RideStatus fromString(String value) {
    return RideStatus.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => RideStatus.requested,
    );
  }
}
