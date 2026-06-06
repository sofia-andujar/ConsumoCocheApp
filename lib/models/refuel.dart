class Refuel {
  final int? id;
  final DateTime date;
  final double kilometers;
  final double liters;
  final String comment;

  Refuel({
    this.id,
    required this.date,
    required this.kilometers,
    required this.liters,
    this.comment = '',
  });


  Map<String, Object?> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'kilometers': kilometers,
      'liters': liters,
      'comment': comment,
    };
  }



  factory Refuel.fromMap(Map<String, Object?> map) {
    final kmValue = map['kilometers'] ?? map['kilometers'];
    if (kmValue == null) {
      throw StateError('Refuel map missing kilometers value: $map');
    }
    return Refuel(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      kilometers: (kmValue as num).toDouble(),
      liters: (map['liters'] as num).toDouble(),
      comment: map['comment'] as String? ?? '',
    );
  }

  double get consumptionLPer100Km {
    if (kilometers <= 0) {
      return 0.0;
    }
    return (liters / kilometers) * 100;
  }

  static double litersPer100Km({
    required double liters,
    required double distanceKm,
  }) {
    if (distanceKm <= 0) {
      return 0.0;
    }
    return (liters / distanceKm) * 100;
  }
}
