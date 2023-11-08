// ignore_for_file: no_leading_underscores_for_local_identifiers

class AlarmTypeModel {
  AlarmTypeModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataAlarmType data;

  AlarmTypeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataAlarmType.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataAlarmType {
  DataAlarmType({
    required this.result,
  });
  late final List<ResultAlarmType> result;

  DataAlarmType.fromJson(Map<String, dynamic> json) {
    result = List.from(json['result'])
        .map((e) => ResultAlarmType.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['result'] = result.map((e) => e.toJson()).toList();
    return _data;
  }
}

class ResultAlarmType {
  ResultAlarmType({
    required this.code,
    required this.alertNo,
    required this.checked,
  });
  late final String code;
  late final int alertNo;
  late bool checked;

  ResultAlarmType.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    alertNo = json['Alert_no'];
    checked = json['Checked'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Code'] = code;
    _data['Alert_no'] = alertNo;
    _data['Checked'] = checked;
    return _data;
  }
}
