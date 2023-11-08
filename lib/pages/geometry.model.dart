class GeometryModel {
  GeometryModel({
    required this.polygon,
  });
  late final List<PolygonData> polygon;

  GeometryModel.fromJson(Map<String, dynamic> json) {
    polygon =
        List.from(json['polygon']).map((e) => PolygonData.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['polygon'] = polygon.map((e) => e.toJson()).toList();
    return _data;
  }
}

class PolygonData {
  PolygonData({
    required this.polygonID,
    required this.polygonLatLng,
  });
  late final String polygonID;
  late final List<PolygonLatLng> polygonLatLng;

  PolygonData.fromJson(Map<String, dynamic> json) {
    polygonID = json['polygonID'];
    polygonLatLng = List.from(json['polygonLatLng'])
        .map((e) => PolygonLatLng.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['polygonID'] = polygonID;
    _data['polygonLatLng'] = polygonLatLng.map((e) => e.toJson()).toList();
    return _data;
  }
}

class PolygonLatLng {
  PolygonLatLng({
    required this.lat,
    required this.lon,
  });
  late final String lat;
  late final String lon;

  PolygonLatLng.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lon = json['lon'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['lat'] = lat;
    _data['lon'] = lon;
    return _data;
  }
}
