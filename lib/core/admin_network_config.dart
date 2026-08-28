import 'package:flutter/foundation.dart';

class AdminNetworkConfig {
  static const String _defaultUrl = kDebugMode
      ? 'http://localhost:3000/api/v1'
      : 'https://kanngrowbackend-production.up.railway.app/api/v1';

  static const String baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: _defaultUrl,
  );
}
