// ignore_for_file: no_leading_underscores_for_local_identifiers, non_constant_identifier_names

class Banner {
  Banner({
    required this.status,
    required this.message,
    required this.data,
  });
  late final bool status;
  late final String message;
  late final DataBanner data;

  Banner.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = DataBanner.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data.toJson();
    return _data;
  }
}

class DataBanner {
  DataBanner({
    required this.TotalAllData,
    required this.CurrentPage,
    required this.PerPage,
    required this.TotalPage,
    required this.ResultBanner,
  });
  late final int TotalAllData;
  late final int CurrentPage;
  late final int PerPage;
  late final int TotalPage;
  late final List<Result> ResultBanner;

  DataBanner.fromJson(Map<String, dynamic> json) {
    TotalAllData = json['TotalAllData'];
    CurrentPage = json['CurrentPage'];
    PerPage = json['PerPage'];
    TotalPage = json['TotalPage'];
    ResultBanner =
        List.from(json['Result']).map((e) => Result.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['TotalAllData'] = TotalAllData;
    _data['CurrentPage'] = CurrentPage;
    _data['PerPage'] = PerPage;
    _data['TotalPage'] = TotalPage;
    _data['Result'] = ResultBanner.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Result {
  Result({
    required this.Id,
    required this.Name,
    required this.File,
    required this.Status,
    required this.Position,
    required this.FileMobile,
    required this.Url_link,
  });
  late final int Id;
  late final String Name;
  late final String File;
  late final int Status;
  late final int Position;
  late final String FileMobile;
  late final String Url_link;

  Result.fromJson(Map<String, dynamic> json) {
    Id = json['Id'];
    Name = json['Name'];
    File = json['File'];
    Status = json['Status'];
    Position = json['Position'];
    FileMobile = json['File_mobile'];
    Url_link = json['Url_link'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Id'] = Id;
    _data['Name'] = Name;
    _data['File'] = File;
    _data['Status'] = Status;
    _data['Position'] = Position;
    _data['File_mobile'] = FileMobile;
    _data['Url_link'] = Url_link;
    return _data;
  }
}
