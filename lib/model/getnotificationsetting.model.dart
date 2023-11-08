class GetNotificationSettingModel {
  GetNotificationSettingModel({
    required this.status,
    required this.message,
  });
  late final bool status;
  late final MessageNotifSetting message;

  GetNotificationSettingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = MessageNotifSetting.fromJson(json['message']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message.toJson();
    return data;
  }
}

class MessageNotifSetting {
  MessageNotifSetting({
    required this.total,
    required this.dataNotificationSetting,
  });
  late final int total;
  late final List<DataNotificartionSetting> dataNotificationSetting;

  MessageNotifSetting.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    dataNotificationSetting = List.from(json['data'])
        .map((e) => DataNotificartionSetting.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['total'] = total;
    data['data'] = dataNotificationSetting.map((e) => e.toJson()).toList();
    return data;
  }
}

class DataNotificartionSetting {
  DataNotificartionSetting({
    required this.code,
    required this.alertNo,
    required this.isActive,
  });
  late String code;
  late final int alertNo;
  late bool isActive;

  DataNotificartionSetting.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    alertNo = json['alert_no'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    data['alert_no'] = alertNo;
    data['is_active'] = isActive;
    return data;
  }
}
