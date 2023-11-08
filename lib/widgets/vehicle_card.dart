// import 'package:flutter/material.dart';
// import 'package:gpsid/common.dart';
// import 'package:gpsid/model/vehicleModel.dart';
// import 'package:gpsid/theme.dart';
// import '../model/vehicle.dart';
// import 'add_vehicle.dart';

// class VehicleCard extends StatelessWidget {
//   final VehicleModel vehicleModel;
//   const VehicleCard(this.vehicleModel, {Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
    
//     return GestureDetector(
//       onTap: () => Navigator.pushNamed(context, '/vehicledetail'),
//       child: FutureBuilder(
//           future: VehicleAPI.,
//           builder: (context, data) {
//             if (data.hasError) {
//               return Center(
//                 child: Text('${data.error}'),
//               );
//             } else if (data.hasData) {
//               var items = data.data as List<Vehicle>;
//               return Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: ListView.builder(
//                   scrollDirection: Axis.vertical,
//                   itemCount: items == null ? 0 : items.length,
//                   itemBuilder: (context, index) {
//                     return Card(
//                       margin: const EdgeInsets.only(
//                         bottom: 20,
//                       ),
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4),
//                         side: BorderSide(
//                           color: greyColor,
//                           width: 1,
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       items[index].plat.toString(),
//                                       style: bold.copyWith(
//                                         fontSize: 18,
//                                         color: blackSecondary1,
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 4,
//                                     ),
//                                     Row(
//                                       children: [
//                                         Text(
//                                           '${AppLocalizations.of(context)!.lastUpdate} :',
//                                           style: reguler.copyWith(
//                                             fontSize: 12,
//                                             color: blackSecondary2,
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           width: 2,
//                                         ),
//                                         Text(
//                                           items[index].lastUpdate.toString(),
//                                           style: reguler.copyWith(
//                                               fontSize: 12,
//                                               color: blackSecondary2),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                                 Image.asset(
//                                   'assets/${items[index].vehicles.toString()}_${items[index].status.toString().toLowerCase()}.png',
//                                   width: 50,
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(
//                               height: 8,
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Row(
//                                       children: [
//                                         const Icon(Icons.speed),
//                                         const SizedBox(width: 5),
//                                         Text(
//                                           '${items[index].speed.toString()} km/h',
//                                           style: bold.copyWith(
//                                             fontSize: 12,
//                                             color: blackSecondary1,
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           width: 11,
//                                         ),
//                                       ],
//                                     ),
//                                     Row(
//                                       children: [
//                                         const Icon(Icons.info_outline_rounded),
//                                         const SizedBox(
//                                           width: 5,
//                                         ),
//                                         Text(
//                                           _statusCondition(
//                                               items[index].status.toString()),
//                                           style: bold.copyWith(
//                                             fontSize: 12,
//                                             color: _colorCondition(
//                                               items[index].status,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                                 Text(
//                                   '${items[index].unit.toString()} - ${items[index].device.toString()}',
//                                   style: bold.copyWith(
//                                     fontSize: 14,
//                                     color: blackPrimary,
//                                   ),
//                                 )
//                               ],
//                             ),
//                             const SizedBox(
//                               height: 10,
//                             ),
//                             Divider(
//                               height: 2,
//                               thickness: 1,
//                               indent: 0,
//                               endIndent: 0,
//                               color: greyColor,
//                             ),
//                             const SizedBox(
//                               height: 10,
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 AddPackage(),
//                                 Row(
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Text(
//                                           '${AppLocalizations.of(context)!.subscriptionEnded} :',
//                                           style: reguler.copyWith(
//                                             fontSize: 10,
//                                             color: blackSecondary2,
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           width: 2,
//                                         ),
//                                         Text(
//                                           items[index].lastPulsa.toString(),
//                                           style: reguler.copyWith(
//                                             fontSize: 10,
//                                             color: blackSecondary2,
//                                           ),
//                                         ),
//                                       ],
//                                     )
//                                   ],
//                                 )
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             } else {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//           }),
//     );
//   }
// }

// _colorCondition(sts) {
//   if (sts == 'bergerak') {
//     return bluePrimary;
//   } else if (sts == 'berhenti') {
//     return redPrimary;
//   } else if (sts == 'parkir') {
//     return yellowPrimary;
//   } else {
//     return blackPrimary;
//   }
// }

// _statusCondition(sts) {
//   if (sts == 'bergerak') {
//     return 'Bergerak';
//   } else if (sts == 'berhenti') {
//     return 'Berhenti';
//   } else if (sts == 'parkir') {
//     return 'Parkir';
//   } else {
//     return 'No Data';
//   }
//   ;
// }
