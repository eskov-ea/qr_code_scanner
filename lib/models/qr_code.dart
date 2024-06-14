class QRCode {
  final String value;
  final int status;
  final DateTime createdAt;
  final DateTime? deletedAt;

  const QRCode({
    required this.value,
    required this.status,
    required this.createdAt,
    required this.deletedAt
  });

  static QRCode fromJson(json) {
    return QRCode(
        value: json["value"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        deletedAt: json["deleted_at"]
    );
  }


  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QRCode &&
            runtimeType == other.runtimeType &&
            value == other.value;
  }
  @override
  int get hashCode => runtimeType.hashCode ^ value.hashCode;

  @override
  String toString() => "QRCode: $value";

}