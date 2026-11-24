class NeighborhoodModel {
  const NeighborhoodModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.code,
  });

  final String id;
  final String name;
  final double lat;
  final double lng;
  final String? code;

  factory NeighborhoodModel.fromJson(Map<String, dynamic> json) {
    final rawId =
        json['id'] ?? json['Id'] ?? json['neighborhoodId'] ?? json['NeighborhoodId'];
    final rawName =
        json['nameAr'] ??
        json['NameAr'] ??
        json['name'] ??
        json['Name'] ??
        json['arabicName'] ??
        json['ArabicName'];
    final rawLat = json['Lat'] ?? json['lat'] ?? json['latitude'] ?? json['Latitude'];
    final rawLng = json['Lng'] ?? json['lng'] ?? json['longitude'] ?? json['Longitude'];

    return NeighborhoodModel(
      id: rawId?.toString() ?? '',
      name: rawName?.toString().trim().isNotEmpty == true
          ? rawName.toString().trim()
          : 'حي غير مسمى',
      lat: _parseDouble(rawLat) ?? 0.0,
      lng: _parseDouble(rawLng) ?? 0.0,
      code: (json['code'] ?? json['Code'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'Lat': lat,
    'Lng': lng,
    if (code != null) 'code': code,
  };

  static double? _parseDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
