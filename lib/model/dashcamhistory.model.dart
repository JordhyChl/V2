// ignore_for_file: no_leading_underscores_for_local_identifiers

class DashcamHistoryModel {
  DashcamHistoryModel({
    required this.status,
    required this.dataDashcamHist,
    required this.message,
  });
  late final bool status;
  late final DataDashcamHist dataDashcamHist;
  late final String message;

  DashcamHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    dataDashcamHist = DataDashcamHist.fromJson(json['data']);
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['data'] = dataDashcamHist.toJson();
    _data['message'] = message;
    return _data;
  }
}

class DataDashcamHist {
  DataDashcamHist({
    required this.id,
    required this.imei,
    required this.dateHistory,
    required this.filelistCamera1,
    required this.createdAt,
    required this.updatedAt,
    required this.filelistCamera2,
    required this.gps,
  });
  late final int id;
  late final String imei;
  late final String dateHistory;
  late final FilelistCamera1 filelistCamera1;
  late final String createdAt;
  late final String updatedAt;
  late final FilelistCamera2 filelistCamera2;
  late final Gps gps;

  DataDashcamHist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imei = json['imei'];
    dateHistory = json['date_history'];
    filelistCamera1 = FilelistCamera1.fromJson(json['filelist_camera1']);
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    filelistCamera2 = FilelistCamera2.fromJson(json['filelist_camera2']);
    gps = Gps.fromJson(json['gps']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['imei'] = imei;
    _data['date_history'] = dateHistory;
    _data['filelist_camera1'] = filelistCamera1.toJson();
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['filelist_camera2'] = filelistCamera2.toJson();
    _data['gps'] = gps.toJson();
    return _data;
  }
}

class FilelistCamera1 {
  FilelistCamera1({
    required this.listFile,
    required this.timeSlider,
    required this.startTime,
  });
  late final List<ListFile> listFile;
  late final int timeSlider;
  late final String startTime;

  FilelistCamera1.fromJson(Map<String, dynamic> json) {
    listFile =
        List.from(json['list_file']).map((e) => ListFile.fromJson(e)).toList();
    timeSlider = json['time_slider'];
    startTime = json['start_time'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['list_file'] = listFile.map((e) => e.toJson()).toList();
    _data['time_slider'] = timeSlider;
    _data['start_time'] = startTime;
    return _data;
  }
}

class ListFile {
  ListFile({
    required this.file,
    required this.time,
  });
  late final String file;
  late final String time;

  ListFile.fromJson(Map<String, dynamic> json) {
    file = json['file'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['file'] = file;
    _data['time'] = time;
    return _data;
  }
}

class FilelistCamera2 {
  FilelistCamera2({
    required this.listFile,
    required this.timeSlider,
    required this.startTime,
  });
  late final List<ListFile> listFile;
  late final int timeSlider;
  late final String startTime;

  FilelistCamera2.fromJson(Map<String, dynamic> json) {
    listFile =
        List.from(json['list_file']).map((e) => ListFile.fromJson(e)).toList();
    timeSlider = json['time_slider'];
    startTime = json['start_time'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['list_file'] = listFile.map((e) => e.toJson()).toList();
    _data['time_slider'] = timeSlider;
    _data['start_time'] = startTime;
    return _data;
  }
}

class Gps {
  Gps({
    required this.imei,
    required this.limitLive,
  });
  late final String imei;
  late final int limitLive;

  Gps.fromJson(Map<String, dynamic> json) {
    imei = json['imei'];
    limitLive = json['limit_live'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['imei'] = imei;
    _data['limit_live'] = limitLive;
    return _data;
  }
}
