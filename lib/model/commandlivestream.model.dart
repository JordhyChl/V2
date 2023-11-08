// ignore_for_file: no_leading_underscores_for_local_identifiers

class CommandDashcam {
  CommandDashcam({
    required this.code,
    required this.msg,
    required this.data,
  });
  late final int code;
  late final String msg;
  late final DataCommandLiveStream data;

  CommandDashcam.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['data']['_content'];
    data = DataCommandLiveStream.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['code'] = code;
    _data['msg'] = msg;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataCommandLiveStream {
  DataCommandLiveStream({
    required this.code,
    required this.imei,
    required this.content,
    required this.msg,
    required this.serverFlagId,
  });
  late final String code;
  late final String imei;
  late final String content;
  late final String msg;
  late final String serverFlagId;

  DataCommandLiveStream.fromJson(Map<String, dynamic> json) {
    code = json['_code'];
    imei = json['_imei'];
    content = json['_content'];
    msg = json['_msg'] ?? '';
    serverFlagId = json['_serverFlagId'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['_code'] = code;
    _data['_imei'] = imei;
    _data['_content'] = content;
    _data['_msg'] = msg;
    _data['_serverFlagId'] = serverFlagId;
    return _data;
  }
}
