class NotificationEvent {
  final String type;
  final String title;
  final String message;
  final String? appointmentId;
  final String? clientId;
  final bool feeApplied;
  final double? feeAmount;
  final double? totalAmount;
  final DateTime occurredOn;

  NotificationEvent({
    required this.type,
    required this.title,
    required this.message,
    this.appointmentId,
    this.clientId,
    required this.feeApplied,
    this.feeAmount,
    this.totalAmount,
    required this.occurredOn,
  });

  factory NotificationEvent.fromJson(Map<String, dynamic> json) {
    return NotificationEvent(
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      appointmentId: json['appointmentId'] as String?,
      clientId: json['clientId'] as String?,
      feeApplied: json['feeApplied'] as bool? ?? false,
      feeAmount: (json['feeAmount'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      occurredOn: DateTime.parse(json['occurredOn'] as String),
    );
  }
}
