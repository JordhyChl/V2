// ignore_for_file: no_leading_underscores_for_local_identifiers

class LocalNotifAlarmModel {
  LocalNotifAlarmModel({
    required this.isNotif,
  });
  late final bool isNotif;

  LocalNotifAlarmModel.fromJson(Map<String, dynamic> json) {
    isNotif = json['isNotif'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['isNotif'] = isNotif;
    return _data;
  }
}
