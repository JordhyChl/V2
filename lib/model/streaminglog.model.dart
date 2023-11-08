// ignore_for_file: no_leading_underscores_for_local_identifiers

class StreamingLogModel {
  StreamingLogModel({
    required this.status,
    required this.message,
  });
  late final bool status;
  late final Message message;

  StreamingLogModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = Message.fromJson(json['message']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message.toJson();
    return _data;
  }
}

class Message {
  Message({
    required this.total,
    required this.dataStreamingLog,
  });
  late final int total;
  late final List<DataStreamingLog> dataStreamingLog;

  Message.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    dataStreamingLog = List.from(json['data'])
        .map((e) => DataStreamingLog.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['total'] = total;
    _data['data'] = dataStreamingLog.map((e) => e.toJson()).toList();
    return _data;
  }
}

class DataStreamingLog {
  DataStreamingLog({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalSecond,
    required this.imei,
    required this.cmdContent,
    required this.liveFrom,
    required this.action,
    required this.camera,
    required this.totalTime,
    required this.userAccess,
    required this.gps,
  });
  late final int id;
  late final int userId;
  late final String startDate;
  late final String endDate;
  late final int totalSecond;
  late final String imei;
  late final String cmdContent;
  late final String liveFrom;
  late final String action;
  late final String camera;
  late final String totalTime;
  late final UserAccess userAccess;
  late final Gps gps;

  DataStreamingLog.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    totalSecond = json['total_second'];
    imei = json['imei'];
    cmdContent = json['cmd_content'];
    liveFrom = json['live_from'];
    action = json['action'];
    camera = json['camera'];
    totalTime = json['total_time'];
    userAccess = UserAccess.fromJson(json['_user_access']);
    gps = Gps.fromJson(json['_gps']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['user_id'] = userId;
    _data['start_date'] = startDate;
    _data['end_date'] = endDate;
    _data['total_second'] = totalSecond;
    _data['imei'] = imei;
    _data['cmd_content'] = cmdContent;
    _data['live_from'] = liveFrom;
    _data['action'] = action;
    _data['camera'] = camera;
    _data['total_time'] = totalTime;
    _data['_user_access'] = userAccess.toJson();
    _data['_gps'] = gps.toJson();
    return _data;
  }
}

class UserAccess {
  UserAccess({
    required this.id,
    required this.branch,
    required this.username,
  });
  late final int id;
  late final int branch;
  late final String username;

  UserAccess.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    branch = json['branch'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['branch'] = branch;
    _data['username'] = username;
    return _data;
  }
}

class Gps {
  Gps({
    required this.imei,
    required this.plate,
    required this.deviceName,
  });
  late final String imei;
  late final String plate;
  late final String deviceName;

  Gps.fromJson(Map<String, dynamic> json) {
    imei = json['imei'];
    plate = json['plate'];
    deviceName = json['device_name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['imei'] = imei;
    _data['plate'] = plate;
    _data['device_name'] = deviceName;
    return _data;
  }
}
