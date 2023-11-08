class VehicleStatusModel {
  VehicleStatusModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataVehicleStatus data;

  VehicleStatusModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataVehicleStatus.fromJson(json['data'] ?? []);
  }

  Map<String, dynamic> toJson() {
    final dataVehStatus = <String, dynamic>{};
    dataVehStatus['status'] = status;
    dataVehStatus['message'] = message;
    dataVehStatus['data'] = data.toJson();
    return dataVehStatus;
  }
}

class DataVehicleStatus {
  DataVehicleStatus({
    required this.status,
    required this.unit,
  });
  late final String status;
  late final int unit;

  DataVehicleStatus.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    unit = json['Unit'];
  }

  Map<String, dynamic> toJson() {
    final dataVehicleStatus = <String, dynamic>{};
    dataVehicleStatus['Status'] = status;
    dataVehicleStatus['Unit'] = unit;
    return dataVehicleStatus;
  }
}
