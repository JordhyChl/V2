class VehicleIconRegisterModel {
  VehicleIconRegisterModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final List<DataVehicleIconRegister> data;

  VehicleIconRegisterModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = List.from(json['data'])
        .map((e) => DataVehicleIconRegister.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.map((e) => e.toJson()).toList();
    return _data;
  }
}

class DataVehicleIconRegister {
  DataVehicleIconRegister({
    required this.value,
    required this.title,
    required this.parking,
    required this.accOn,
    required this.lost,
    required this.alarm,
  });
  late final int value;
  late final String title;
  late final String parking;
  late final String accOn;
  late final String lost;
  late final String alarm;

  DataVehicleIconRegister.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    title = json['title'];
    parking = json['parking'];
    accOn = json['acc_on'];
    lost = json['lost'];
    alarm = json['alarm'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['value'] = value;
    _data['title'] = title;
    _data['parking'] = parking;
    _data['acc_on'] = accOn;
    _data['lost'] = lost;
    _data['alarm'] = alarm;
    return _data;
  }
}
