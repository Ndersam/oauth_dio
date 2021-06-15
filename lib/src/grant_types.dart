import 'package:dio/dio.dart';

/// Use to implement a custom grantType
abstract class OAuthGrantType {
  RequestOptions handle(RequestOptions request);
}

/// Obtain an access token using a username and password
class PasswordGrant extends OAuthGrantType {
  String username;
  String password;
  List<String> scope = [];

  PasswordGrant({this.username, this.password, this.scope});

  /// Prepare Request
  @override
  RequestOptions handle(RequestOptions request) {
    request.data =
        "grant_type=password&username=${Uri.encodeComponent(username)}&password=${Uri.encodeComponent(password)}&scope=${this.scope.join(' ')}";
    return request;
  }
}

/// Obtain an access token using an refresh token
class RefreshTokenGrant extends OAuthGrantType {
  String refreshToken;

  RefreshTokenGrant({this.refreshToken});

  /// Prepare Request
  @override
  RequestOptions handle(RequestOptions request) {
    request.data = "grant_type=refresh_token&refresh_token=$refreshToken";
    return request;
  }
}
