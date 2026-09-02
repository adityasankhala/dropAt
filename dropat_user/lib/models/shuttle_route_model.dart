// ShuttleRouteModel — no SDK dependencies, pure Dart data class.

class ShuttleStop {
  final String name;
  final double lat;
  final double lng;
  final int order;

  ShuttleStop({
    required this.name,
    required this.lat,
    required this.lng,
    required this.order,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'lat': lat,
        'lng': lng,
        'order': order,
      };

  factory ShuttleStop.fromMap(Map<String, dynamic> map) => ShuttleStop(
        name: map['name'] ?? '',
        lat: (map['lat'] ?? 0).toDouble(),
        lng: (map['lng'] ?? 0).toDouble(),
        order: map['order'] ?? 0,
      );
}

class ShuttleSchedule {
  final String departureTime; // e.g., "08:00 AM"
  final List<String> daysOfWeek; // e.g., ["Mon", "Tue", ...]

  ShuttleSchedule({
    required this.departureTime,
    required this.daysOfWeek,
  });

  Map<String, dynamic> toMap() => {
        'departureTime': departureTime,
        'daysOfWeek': daysOfWeek,
      };

  factory ShuttleSchedule.fromMap(Map<String, dynamic> map) => ShuttleSchedule(
        departureTime: map['departureTime'] ?? '',
        daysOfWeek: List<String>.from(map['daysOfWeek'] ?? []),
      );
}

class ShuttleRouteModel {
  final String routeId;
  final String name;
  final List<ShuttleStop> stops;
  final List<ShuttleSchedule> schedule;
  final double price;
  final int totalSeats;
  final int? availableSeats;

  ShuttleRouteModel({
    required this.routeId,
    required this.name,
    required this.stops,
    required this.schedule,
    required this.price,
    required this.totalSeats,
    this.availableSeats,
  });

  String get routeSummary {
    if (stops.isEmpty) return name;
    return '${stops.first.name} → ${stops.last.name}';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'stops': stops.map((s) => s.toMap()).toList(),
      'schedule': schedule.map((s) => s.toMap()).toList(),
      'price': price,
      'totalSeats': totalSeats,
    };
  }

  factory ShuttleRouteModel.fromMap(String id, Map<String, dynamic> map) {
    return ShuttleRouteModel(
      routeId: id,
      name: map['name'] ?? '',
      stops: (map['stops'] as List<dynamic>?)
              ?.map((s) => ShuttleStop.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      schedule: (map['schedule'] as List<dynamic>?)
              ?.map((s) => ShuttleSchedule.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      price: (map['price'] ?? 0).toDouble(),
      totalSeats: map['totalSeats'] ?? 20,
      availableSeats: map['availableSeats'],
    );
  }
}
