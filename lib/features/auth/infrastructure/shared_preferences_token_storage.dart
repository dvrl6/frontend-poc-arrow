import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../application/token_storage.dart';
import '../domain/auth_session.dart';

class SharedPreferencesTokenStorage implements TokenStorage {
  const SharedPreferencesTokenStorage(this._preferences);

  static const _authSessionKey = 'auth.session';

  final SharedPreferences _preferences;

  @override
  Future<void> clearSession() async {
    await _preferences.remove(_authSessionKey);
  }

  @override
  Future<String?> getAccessToken() async {
    final session = await getSession();
    return session?.accessToken;
  }

  @override
  Future<AuthSession?> getSession() async {
    final encoded = _preferences.getString(_authSessionKey);
    if (encoded == null || encoded.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, Object?>) {
        return null;
      }
      final session = AuthSession.fromJson(decoded);
      return session.accessToken.isEmpty ? null : session;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    await _preferences.setString(_authSessionKey, jsonEncode(session.toJson()));
  }
}
