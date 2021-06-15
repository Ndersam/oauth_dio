import 'token.dart';

/// Use to implement custom token storage
abstract class OAuthStorage {
  /// Read token
  Future<OAuthToken> fetch();

  /// Save Token
  Future<OAuthToken> save(OAuthToken token);

  /// Clear token
  Future<void> clear();
}

/// Save Token in Memory
class OAuthMemoryStorage extends OAuthStorage {
  OAuthToken _token;

  /// Read
  @override
  Future<OAuthToken> fetch() async {
    return _token;
  }

  /// Save
  @override
  Future<OAuthToken> save(OAuthToken token) async {
    return _token = token;
  }

  /// Clear
  Future<void> clear() async {
    _token = null;
  }
}
