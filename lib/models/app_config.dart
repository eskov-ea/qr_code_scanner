
class AppConfig {
  static const DEFAULT_FACTORY_NAME = "Гость";
  final String? factoryName;
  final String? authToken;

  const AppConfig({
    required this.factoryName,
    required this.authToken
  });

  static AppConfig fromJson(json) => AppConfig(
    factoryName: json["factory_name"],
    authToken: json["auth_token"]
  );

  static AppConfig get empty => const AppConfig(factoryName: null, authToken: null);

  @override
  String toString() => "Instance of AppConfig. authToken: $authToken";
}