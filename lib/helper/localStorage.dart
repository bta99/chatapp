import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._();
  static final LocalStorage _instance = LocalStorage._();
  SharedPreferences? _pref;
  static LocalStorage get instance => _instance;

  static Future<void> init() async {
    instance._pref ??= await SharedPreferences.getInstance();
    return Future.value();
  }

  SharedPreferences get store => _pref!;

  setToken(String key, String token) {
    return store.setString(key, token);
  }

  String? getString(String key) {
    return store.getString(key);
  }
}
