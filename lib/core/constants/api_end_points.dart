import 'package:flutter/foundation.dart';

abstract final class ApiEndPoints {
  /// Base server URL — override at run/build time via:
  /// `flutter run -d chrome --dart-define=API_BASE_URL=https://your-api.example.com/`
  static const String _definedServerUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static const String _defaultRemoteServerUrl =
      'https://qatra-api.runasp.net/';

  static String get serverUrl {
    if (_definedServerUrl.isNotEmpty) {
      return _definedServerUrl.endsWith('/')
          ? _definedServerUrl
          : '$_definedServerUrl/';
    }

    if (kIsWeb) {
      final host = Uri.base.host;
      final isLocalhost =
          host == 'localhost' || host == '127.0.0.1' || host.isEmpty;
      if (!isLocalhost) {
        return '${Uri.base.origin}/';
      }
    }

    return _defaultRemoteServerUrl;
  }

  static String get baseUrl => '${serverUrl}api/';

  static const String neighborhoods = 'Neighborhoods';
  static const String incidents = 'incidents';

  static String incidentDetails(String incidentId) => 'incidents/$incidentId';

  static String incidentStatus(String incidentId) =>
      'incidents/$incidentId/status';

  static String neighborhoodPrediction(String neighborhoodId) =>
      'predictions/$neighborhoodId';
}
