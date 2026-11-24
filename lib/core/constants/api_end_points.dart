abstract final class ApiEndPoints {
  /// Base server URL — override at run/build time via:
  /// `flutter run -d chrome --dart-define=API_BASE_URL=https://your-api.example.com/`
  static const String _rawServerUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://qatra-api.runasp.net/',
  );

  static String get serverUrl =>
      _rawServerUrl.endsWith('/') ? _rawServerUrl : '$_rawServerUrl/';

  static String get baseUrl => '${serverUrl}api/';

  static const String neighborhoods = 'Neighborhoods';
  static const String incidents = 'incidents';

  static String incidentDetails(String incidentId) => 'incidents/$incidentId';

  static String incidentStatus(String incidentId) =>
      'incidents/$incidentId/status';

  static String neighborhoodPrediction(String neighborhoodId) =>
      'predictions/$neighborhoodId';
}
