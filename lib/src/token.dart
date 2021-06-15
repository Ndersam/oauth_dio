import 'dart:convert';

class OAuthToken {
  final String accessToken;
  final String refreshToken;
  final DateTime expiration;

  bool get canRefresh => refreshToken != null;

  bool get isExpired {
    var expiration = this.expiration;
    return expiration != null && DateTime.now().isAfter(expiration);
  }

  const OAuthToken({
    this.accessToken,
    this.refreshToken,
    this.expiration,
  }) : assert(accessToken != null);

  factory OAuthToken.fromToken(String json) {
    final map = jsonDecode(json);
    final accessToken = map[_accessTokenKey];
    final refreshToken = map[_refreshTokenKey];
    final expiration = map[_expirationKey];
    return OAuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiration: expiration == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(expiration),
    );
  }

  String toJson() => jsonEncode({
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiration': expiration?.millisecondsSinceEpoch
      });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuthToken &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          expiration == other.expiration;

  @override
  int get hashCode =>
      accessToken.hashCode ^ refreshToken.hashCode ^ expiration.hashCode;

  static final _accessTokenKey = 'accessToken';
  static final _refreshTokenKey = 'refreshToken';
  static final _expirationKey = 'expiration';
}
