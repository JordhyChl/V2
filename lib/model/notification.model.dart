

class Notification {
  String? status;
  String? title;
  String? content;
  String? subcontent;
  String? time;

  Notification({
    required this.status,
    required this.title,
    required this.content,
    required this.subcontent,
    required this.time,
  });

   Notification.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    title = json['title'];
    content =  json['content'];
    subcontent =   json['subcontent'];
    time = json['time'];
  }
}
