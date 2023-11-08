// ignore_for_file: no_leading_underscores_for_local_identifiers

class AssetModel {
  AssetModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataAsset data;

  AssetModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataAsset.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataAsset {
  DataAsset({
    required this.totalAllData,
    required this.results,
  });
  late final int totalAllData;
  late final Results results;

  DataAsset.fromJson(Map<String, dynamic> json) {
    totalAllData = json['total_all_data'];
    results = Results.fromJson(json['results']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['total_all_data'] = totalAllData;
    _data['results'] = results.toJson();
    return _data;
  }
}

class Results {
  Results({
    required this.marker,
    required this.poi,
  });
  late final Marker marker;
  late final Poi poi;

  Results.fromJson(Map<String, dynamic> json) {
    marker = Marker.fromJson(json['marker']);
    poi = Poi.fromJson(json['poi']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['marker'] = marker.toJson();
    _data['poi'] = poi.toJson();
    return _data;
  }
}

class Marker {
  Marker({
    required this.totalAllData,
    required this.results,
  });
  late final int totalAllData;
  late final List<Results> results;

  Marker.fromJson(Map<String, dynamic> json) {
    totalAllData = json['total_all_data'];
    results =
        List.from(json['results']).map((e) => Results.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['total_all_data'] = totalAllData;
    _data['results'] = results.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Poi {
  Poi({
    required this.totalAllData,
    required this.results,
  });
  late final int totalAllData;
  late final List<Results> results;

  Poi.fromJson(Map<String, dynamic> json) {
    totalAllData = json['total_all_data'];
    results =
        List.from(json['results']).map((e) => Results.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['total_all_data'] = totalAllData;
    _data['results'] = results.map((e) => e.toJson()).toList();
    return _data;
  }
}
