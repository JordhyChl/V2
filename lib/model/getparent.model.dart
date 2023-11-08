// ignore_for_file: no_leading_underscores_for_local_identifiers

class GetParentModel {
  GetParentModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final ParentData data;

  GetParentModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = ParentData.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class ParentData {
  ParentData({
    required this.iD,
    required this.username,
    required this.parent,
  });
  late final int iD;
  late final String username;
  late final List<ParentResult> parent;

  ParentData.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    username = json['Username'];
    parent = List.from(json['Parent'] ?? [])
        .map((e) => ParentResult.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['ID'] = iD;
    _data['Username'] = username;
    _data['Parent'] = parent.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ParentResult {
  ParentResult({
    required this.iD,
    required this.username,
  });
  late final int iD;
  late final String username;

  ParentResult.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    username = json['Username'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['ID'] = iD;
    _data['Username'] = username;
    return _data;
  }
}
