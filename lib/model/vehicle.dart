class Vehicle {
  int? id;
  String? plat;
  String? lastUpdate;
  String? speed;
  String? status;
  String? unit;
  String? lastPulsa;
  String? device;
  String? vehicles;

  Vehicle({
    required this.id,
    required this.plat,
    required this.lastPulsa,
    required this.speed,
    required this.status,
    required this.unit,
    required this.lastUpdate,
    required this.device,
    required this.vehicles,
  });

  Vehicle.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    plat = json["plat"];
    lastPulsa = json['lastPulsa'];
    speed = json['speed'];
    status = json['status'];
    unit = json['unit'];
    lastUpdate = json['lastUpdate'];
    device = json['device'];
    vehicles = json['vehicles'];
  }

  contains(String model) {}
}

class VehicleAPI {
  // static Future<List<Vehicle>> ReadJsonData(String param) async {
  //   String apiURL = "http://localhost:3000/all?${param}";
  //   final url = Uri.parse(apiURL);
  //   final jsondata = await http.get(url);
  //   final List list = json.decode(jsondata.body);
  //   final lists = list.map((json) => Vehicle.fromJson(json)).toList();
  //   return lists;
  // }

}
