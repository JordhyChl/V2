// ignore_for_file: unnecessary_new, prefer_collection_literals

class CheckUpdateModel {
  late int id;
  late String version;
  late String releaseDate;

  CheckUpdateModel(
      {required this.id, required this.version, required this.releaseDate});

  CheckUpdateModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    version = json['version'];
    releaseDate = json['release_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['version'] = version;
    data['release_date'] = releaseDate;
    return data;
  }
}
