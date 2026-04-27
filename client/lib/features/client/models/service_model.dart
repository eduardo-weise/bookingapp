class ServiceModel {
  final String id;
  final String name;
  final Duration defaultDuration;
  final double price;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.defaultDuration,
    required this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      defaultDuration: _parseDuration(json['defaultDuration'] as String),
      price: (json['price'] as num).toDouble(),
    );
  }

  /// Parses a TimeSpan string like "00:45:00" into a Duration.
  static Duration _parseDuration(String raw) {
    final parts = raw.split(':');
    if (parts.length < 3) return Duration.zero;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final seconds = int.tryParse(parts[2].split('.').first) ?? 0;
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  /// Returns a human-friendly duration label, e.g. "45 min" or "1h 30min".
  String get durationLabel {
    final h = defaultDuration.inHours;
    final m = defaultDuration.inMinutes.remainder(60);
    if (h == 0) return '$m min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  String get priceLabel => 'R\$ ${price.toStringAsFixed(2)}';
}
