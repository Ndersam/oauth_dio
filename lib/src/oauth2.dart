library oauth_dio;

import 'dart:convert';

import 'package:dio/dio.dart';

import 'grant_types.dart';
import 'storage.dart';
import 'token.dart';

typedef OAuthToken OAuthTokenExtractor(DateTime startTime, Response response);
typedef Future<bool> OAuthTokenValidator(OAuthToken token);

/// The amount of time to add as a "grace period" for credential expiration.
///
/// This allows credential expiration checks to remain valid for a reasonable
/// amount of time.
const _expirationGrace = Duration(seconds: 10);

OAuthToken _defaultExtractor(DateTime startTime, Response res) {
  var data = res.data;
  var expiresIn = data['expires_in'];
  var expiration = expiresIn == null
      ? null
      : startTime.add(Duration(seconds: expiresIn) - _expirationGrace);

  return OAuthToken(
    accessToken: data['access_token'],
    refreshToken: data['refresh_token'],
    expiration: expiration,
  );
}

Future<bool> _defaultValidator(OAuthToken token) {
  if (token.canRefresh && token.isExpired) {
    return Future.value(false);
  }
  return Future.value(true);
}

/// Encode String To Base64
Codec<String, String> stringToBase64 = utf8.fuse(base64);

/// OAuth Client
class OAuth {
  final Dio _dio;
  final String _tokenUrl;
  final String _clientId;
  final String _clientSecret;
  final OAuthStorage _storage;
  final OAuthTokenExtractor _extractor;
  final OAuthTokenValidator _validator;

  OAuth({
    String tokenUrl,
    String clientId,
    String clientSecret,
    OAuthTokenExtractor extractor,
    Dio dio,
    OAuthStorage storage,
    OAuthTokenValidator validator,
  })  : assert(tokenUrl != null),
        assert(clientSecret != null),
        assert(clientId != null),
        _tokenUrl = tokenUrl,
        _clientId = clientId,
        _clientSecret = clientSecret,
        _dio = dio ?? Dio(),
        _storage = storage ?? OAuthMemoryStorage(),
        _extractor = extractor ?? _defaultExtractor,
        _validator = validator ?? _defaultValidator;

  Future<OAuthToken> requestTokenAndSave(OAuthGrantType grantType) async {
    return requestToken(grantType).then((token) => _storage.save(token));
  }

  /// Request a new Access Token using a strategy
  Future<OAuthToken> requestToken(OAuthGrantType grantType) {
    final startTime = DateTime.now();
    final request = grantType.handle(RequestOptions(
        method: 'POST',
        contentType: 'application/x-www-form-urlencoded',
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization":
              "Basic ${stringToBase64.encode('$_clientId:$_clientSecret')}"
        }));

    return _dio
        .request(_tokenUrl, data: request.data, options: request)
        .then((res) => _extractor(startTime, res));
  }

  /// return current access token or refresh
  Future<OAuthToken> fetchOrRefreshAccessToken() async {
    OAuthToken token = await _storage.fetch();

    if (token == null) {
      return null;
    }

    if (await this._validator(token)) return token;

    return this.refreshAccessToken();
  }

  /// Refresh Access Token
  Future<OAuthToken> refreshAccessToken() async {
    OAuthToken token = await _storage.fetch();

    return this.requestTokenAndSave(
        RefreshTokenGrant(refreshToken: token.refreshToken));
  }
}
