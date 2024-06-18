import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';

abstract class _Keys {
  static const token = 'token';
  static const factoryName = 'factory_name';
}

class CacheManager {

  final _db = GetIt.instance.get<DBProvider>();
  final _cache = <String, String?>{};

  Future<void> initialize() async {
    await getToken();
    await getFactoryName();
  }

  Future<String?> getToken() async {
    if (_cache.containsKey(_Keys.token)) {
      return _cache[_Keys.token];
    } else {
      final config = await _db.getConfig();
      _cache[_Keys.token] = config.authToken;
      return config.authToken;
    }
  }

  Future<void> setToken(String value) async {
    _cache[_Keys.token] = value;
    await _db.setAuthToken(value);
  }

  Future<String?> getFactoryName() async {
    if (_cache.containsKey(_Keys.factoryName)) {
      return _cache[_Keys.factoryName];
    } else {
      final config = await _db.getConfig();
      _cache[_Keys.factoryName] = config.factoryName;
      return config.factoryName;
    }
  }

  Future<void> setFactoryName(String value) async {
    _cache[_Keys.factoryName] = value;
    await _db.setFactoryName(value);
  }

}