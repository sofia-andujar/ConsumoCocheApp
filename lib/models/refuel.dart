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

  Refuel copyWith({
    int? id,
    DateTime? date,
    double? kilometers,
    double? liters,
    String? comment,
  }) {
    return Refuel(
      id: id ?? this.id,
      date: date ?? this.date,
      kilometers: kilometers ?? this.kilometers,
      liters: liters ?? this.liters,
      comment: comment ?? this.comment,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Refuel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          date == other.date &&
          kilometers == other.kilometers &&
          liters == other.liters &&
          comment == other.comment;

  @override
  int get hashCode => Object.hash(id, date, kilometers, liters, comment);

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
    final kmValue = map['kilometers'] ?? map['km'];
    if (kmValue == null) {
      throw StateError('Refuel map missing kilometers value: $map');
    }
    final litersValue = map['liters'];
    if (litersValue == null) {
      throw StateError('Refuel map missing liters value: $map');
    }
    return Refuel(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      kilometers: (kmValue as num).toDouble(),
      liters: (litersValue as num).toDouble(),
      comment: (map['comment'] ?? map['comments']) as String? ?? '',
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
