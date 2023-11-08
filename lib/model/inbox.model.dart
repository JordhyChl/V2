class InboxModel {
  late int id;
  late String message;
  late String username;
  late String createdAt;
  late int isRead;
  late int type;

  InboxModel(
      {required this.id,
      required this.message,
      required this.username,
      required this.createdAt,
      required this.isRead,
      required this.type});

  InboxModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    message = json['message'];
    username = json['username'];
    createdAt = json['created_at'];
    isRead = json['is_read'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['message'] = message;
    data['username'] = username;
    data['created_at'] = createdAt;
    data['is_read'] = isRead;
    data['type'] = type;
    return data;
  }
}
