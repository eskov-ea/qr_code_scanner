class Log {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;

  Log({required this.id, required this.name, required this.description, required this.createdAt});

  static Log fromJson(json) => Log(id: json["id"], name: json["name"], description: json["description"], createdAt: DateTime.parse(json["created_at"]));
  static Log fromEvent(String name, {String? description}) => Log(id: 0, name: name, description: description, createdAt: DateTime.now().toUtc());

  @override
  String toString() => "Log Instance( $createdAt: message: $name, description: $description).";

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Log &&
            runtimeType == other.runtimeType &&
            id == other.id;
  }
  @override
  int get hashCode => runtimeType.hashCode ^ id.hashCode;
}