// ignore_for_file: no_leading_underscores_for_local_identifiers

class PointHistoryModel {
  PointHistoryModel({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataPointHist data;

  PointHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataPointHist.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataPointHist {
  DataPointHist({
    required this.totalAllData,
    required this.summary,
    required this.result,
  });
  late final int totalAllData;
  late final Summary summary;
  late final List<ResultPointHist> result;

  DataPointHist.fromJson(Map<String, dynamic> json) {
    totalAllData = json['total_all_data'];
    summary = Summary.fromJson(json['summary']);
    result = List.from(json['result'] ?? [])
        .map((e) => ResultPointHist.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['total_all_data'] = totalAllData;
    _data['summary'] = summary.toJson();
    _data['result'] = result.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Summary {
  Summary({
    required this.totalPointBefore,
    required this.totalPointIn,
    required this.totalPointOut,
    required this.totalPointAfter,
  });
  late final int totalPointBefore;
  late final int totalPointIn;
  late final int totalPointOut;
  late final int totalPointAfter;

  Summary.fromJson(Map<String, dynamic> json) {
    totalPointBefore = json['total_point_before'];
    totalPointIn = json['total_point_in'];
    totalPointOut = json['total_point_out'];
    totalPointAfter = json['total_point_after'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['total_point_before'] = totalPointBefore;
    _data['total_point_in'] = totalPointIn;
    _data['total_point_out'] = totalPointOut;
    _data['total_point_after'] = totalPointAfter;
    return _data;
  }
}

class ResultPointHist {
  ResultPointHist({
    required this.createdAt,
    required this.trxName,
    required this.referenceTrxId,
    required this.ssPointBefore,
    required this.ssPointTrx,
    required this.ssPointAfter,
    required this.expDate,
    required this.userPoint,
    required this.imei,
    required this.gsmNo,
    required this.plate,
    required this.trxDate,
  });
  late final String createdAt;
  late final String trxName;
  late final int referenceTrxId;
  late final int ssPointBefore;
  late final int ssPointTrx;
  late final int ssPointAfter;
  late final String expDate;
  late final String userPoint;
  late final String imei;
  late final String gsmNo;
  late final String plate;
  late final String trxDate;

  ResultPointHist.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'];
    trxName = json['trx_name'];
    referenceTrxId = json['reference_trx_id'];
    ssPointBefore = json['ss_point_before'];
    ssPointTrx = json['ss_point_trx'];
    ssPointAfter = json['ss_point_after'];
    expDate = json['exp_date'];
    userPoint = json['user_point'];
    imei = json['imei'];
    gsmNo = json['gsm_no'];
    plate = json['plate'];
    trxDate = json['trx_date'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['created_at'] = createdAt;
    _data['trx_name'] = trxName;
    _data['reference_trx_id'] = referenceTrxId;
    _data['ss_point_before'] = ssPointBefore;
    _data['ss_point_trx'] = ssPointTrx;
    _data['ss_point_after'] = ssPointAfter;
    _data['exp_date'] = expDate;
    _data['user_point'] = userPoint;
    _data['imei'] = imei;
    _data['gsm_no'] = gsmNo;
    _data['plate'] = plate;
    _data['trx_date'] = trxDate;
    return _data;
  }
}
