// ignore_for_file: no_leading_underscores_for_local_identifiers

class AssetMarkerModel {
  AssetMarkerModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final Data data;

  AssetMarkerModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = Data.fromJson(json['data'] ?? []);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class Data {
  Data({
    required this.totalAllData,
    required this.results,
  });
  late final int totalAllData;
  late final List<Results> results;

  Data.fromJson(Map<String, dynamic> json) {
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

class Results {
  Results({
    required this.marker,
    required this.poi,
    required this.type,
    required this.clara,
  });
  late final Marker marker;
  late final Poi poi;
  late final Type type;
  late final Clara clara;

  Results.fromJson(Map<String, dynamic> json) {
    marker = Marker.fromJson(json['marker']);
    poi = Poi.fromJson(json['poi']);
    type = Type.fromJson(json['type']);
    clara = Clara.fromJson(json['clara']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['marker'] = marker.toJson();
    _data['poi'] = poi.toJson();
    _data['type'] = type.toJson();
    _data['clara'] = clara.toJson();
    return _data;
  }
}

class Marker {
  Marker({
    required this.totalAllData,
    required this.resultsMarker,
  });
  late final int totalAllData;
  late final List<ResultsMarker> resultsMarker;

  Marker.fromJson(Map<String, dynamic> json) {
    totalAllData = json['total_all_data'];
    resultsMarker = List.from(json['results_marker'])
        .map((e) => ResultsMarker.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['total_all_data'] = totalAllData;
    _data['results_marker'] = resultsMarker.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultsMarker {
  ResultsMarker({
    required this.iconMarkerId,
    required this.iconMarkerName,
    required this.iconMarkerUrl,
  });
  late final int iconMarkerId;
  late final String iconMarkerName;
  late final List<IconMarkerUrl> iconMarkerUrl;

  ResultsMarker.fromJson(Map<String, dynamic> json) {
    iconMarkerId = json['icon_marker_id'];
    iconMarkerName = json['icon_marker_name'];
    iconMarkerUrl = List.from(json['icon_marker_url'])
        .map((e) => IconMarkerUrl.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['icon_marker_id'] = iconMarkerId;
    _data['icon_marker_name'] = iconMarkerName;
    _data['icon_marker_url'] = iconMarkerUrl.map((e) => e.toJson()).toList();
    return _data;
  }
}

class IconMarkerUrl {
  IconMarkerUrl({
    required this.parking,
    required this.accOn,
    required this.lost,
    required this.alarm,
  });
  late final String parking;
  late final String accOn;
  late final String lost;
  late final String alarm;

  IconMarkerUrl.fromJson(Map<String, dynamic> json) {
    parking = json['parking'];
    accOn = json['acc_on'];
    lost = json['lost'];
    alarm = json['alarm'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['parking'] = parking;
    _data['acc_on'] = accOn;
    _data['lost'] = lost;
    _data['alarm'] = alarm;
    return _data;
  }
}

class Clara {
  Clara({
    required this.totalAllData,
    required this.resultClara,
  });
  late final int totalAllData;
  late final List<ResultClara> resultClara;

  Clara.fromJson(Map<String, dynamic> json) {
    totalAllData = json['total_all_data'];
    resultClara = List.from(json['results_clara'] ?? [])
        .map((e) => ResultClara.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['total_all_data'] = totalAllData;
    _data['results_clara'] = resultClara.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultClara {
  ResultClara({
    required this.iconClaraId,
    required this.iconClaraName,
    required this.iconClaraUrl,
  });
  late final int iconClaraId;
  late final String iconClaraName;
  late final String iconClaraUrl;

  ResultClara.fromJson(Map<String, dynamic> json) {
    iconClaraId = json['icon_clara_id'];
    iconClaraName = json['icon_clara_name'];
    iconClaraUrl = json['icon_clara_url'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['icon_clara_id'] = iconClaraId;
    _data['icon_clara_name'] = iconClaraName;
    _data['icon_clara_url'] = iconClaraUrl;
    return _data;
  }
}

class Poi {
  Poi({
    required this.totalAllData,
    required this.resultsPoi,
  });
  late final int totalAllData;
  late final List<ResultsPoi> resultsPoi;

  Poi.fromJson(Map<String, dynamic> json) {
    totalAllData = json['total_all_data'];
    resultsPoi = List.from(json['results_poi'] ?? [])
        .map((e) => ResultsPoi.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['total_all_data'] = totalAllData;
    _data['results_poi'] = resultsPoi.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultsPoi {
  ResultsPoi({
    required this.iconPoiId,
    required this.iconPoiName,
    required this.iconPoiUrl,
  });
  late final int iconPoiId;
  late final String iconPoiName;
  late final String iconPoiUrl;

  ResultsPoi.fromJson(Map<String, dynamic> json) {
    iconPoiId = json['icon_poi_id'];
    iconPoiName = json['icon_poi_name'];
    iconPoiUrl = json['icon_poi_url'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['icon_poi_id'] = iconPoiId;
    _data['icon_poi_name'] = iconPoiName;
    _data['icon_poi_url'] = iconPoiUrl;
    return _data;
  }
}

class Type {
  Type({
    required this.totalAllData,
    required this.resultsType,
  });
  late final int totalAllData;
  late final List<ResultsType> resultsType;

  Type.fromJson(Map<String, dynamic> json) {
    totalAllData = json['total_all_data'];
    resultsType = List.from(json['results_type'])
        .map((e) => ResultsType.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['total_all_data'] = totalAllData;
    _data['results_type'] = resultsType.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultsType {
  ResultsType({
    required this.iconTypeId,
    required this.iconTypeName,
    required this.iconTypeUrl,
  });
  late final int iconTypeId;
  late final String iconTypeName;
  late final List<IconTypeUrl> iconTypeUrl;

  ResultsType.fromJson(Map<String, dynamic> json) {
    iconTypeId = json['icon_type_id'];
    iconTypeName = json['icon_type_name'];
    iconTypeUrl = List.from(json['icon_type_url'])
        .map((e) => IconTypeUrl.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['icon_type_id'] = iconTypeId;
    _data['icon_type_name'] = iconTypeName;
    _data['icon_type_url'] = iconTypeUrl.map((e) => e.toJson()).toList();
    return _data;
  }
}

class IconTypeUrl {
  IconTypeUrl({
    required this.parking,
    required this.accOn,
    required this.lost,
    required this.alarm,
  });
  late final String parking;
  late final String accOn;
  late final String lost;
  late final String alarm;

  IconTypeUrl.fromJson(Map<String, dynamic> json) {
    parking = json['parking'];
    accOn = json['acc_on'];
    lost = json['lost'];
    alarm = json['alarm'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['parking'] = parking;
    _data['acc_on'] = accOn;
    _data['lost'] = lost;
    _data['alarm'] = alarm;
    return _data;
  }
}
