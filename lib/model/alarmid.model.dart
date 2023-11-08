class AlarmIDModel {
  AlarmIDModel({
    required this.alarmID,
  });
  late final List<int> alarmID;

  AlarmIDModel.fromJson(Map<String, dynamic> json) {
    alarmID = List.from(json['alarmID']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['alarmID'] = alarmID;
    return data;
  }
}
