import 'package:dio/dio.dart';

import 'oauth2.dart';

/// Interceptor to send the bearer access token and update the access token when needed
class BearerInterceptor extends Interceptor {
  final OAuth oauth;

  BearerInterceptor(this.oauth);

  /// Add Bearer token to Authorization Header
  @override
  Future onRequest(RequestOptions options) async {
    final token = await oauth.fetchOrRefreshAccessToken();
    if (token != null) {
      options.headers.addAll({"Authorization": "Bearer ${token.accessToken}"});
    }
    return options;
  }
}
