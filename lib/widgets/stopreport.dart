// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/theme.dart';
import 'package:timeline_tile/timeline_tile.dart';

// ignore: must_be_immutable
class StopReportPage extends StatelessWidget {
  var size, height, width;

  StopReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 143,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                blueGradientSecondary1,
                blueGradientSecondary2,
              ],
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      size: 32,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.stopReport,
                    textAlign: TextAlign.center,
                    style: bold.copyWith(
                      fontSize: 16,
                      color: whiteColor,
                    ),
                  ),
                  Container(
                    width: 30,
                  )
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                'B 1234 GHJ',
                style: reguler.copyWith(
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  autofocus: false,
                  style: bold.copyWith(
                    fontSize: 10,
                    color: blackSecondary1,
                  ),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: yellowPrimary, width: 1),
                    ),
                    isDense: true,
                    fillColor: whiteCardColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                    hintStyle: reguler.copyWith(
                      fontSize: 10,
                      color: blackSecondary1,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 25,
                    ),
                    contentPadding: const EdgeInsets.only(top: 10),
                  ),
                ),
              )
            ],
          ),
        ),
        backgroundColor: bluePrimary,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        width: width,
        height: height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.totalStop,
                style: reguler.copyWith(
                  fontSize: 12,
                  color: blackSecondary3,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: whiteCardColor,
                ),
                width: double.infinity,
                height: 50,
                child: Text(
                  '1 Jam 16 Menit 49 Detik',
                  style: bold.copyWith(
                    fontSize: 16,
                    color: blackPrimary,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              stopReportModel(context),
              const SizedBox(
                height: 20,
              ),
              stopReportModel(context),
              const SizedBox(
                height: 20,
              ),
              stopReportModel(context),
            ],
          ),
        ),
      ),
    );
  }

  stopReportModel(context) {
    return Container(
      width: double.infinity,
      height: height / 3.5,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: whiteCardColor,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Image.asset('assets/stopreportimage.png'),
              Positioned(
                bottom: 20,
                left: 10,
                right: 10,
                child: SizedBox(
                  width: 120,
                  height: 30,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bluePrimary,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const StopMap()));
                    },
                    child: Text(
                      'Open Maps',
                      style: reguler.copyWith(
                        fontSize: 10,
                        color: whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 8,
          ),
          SizedBox(
            width: 190,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TimelineTile(
                  afterLineStyle: LineStyle(color: greyColor, thickness: 1),
                  indicatorStyle: IndicatorStyle(
                    indicator: Image.asset('assets/start_icon.png'),
                  ),
                  isFirst: true,
                  endChild: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.startParking,
                          style: reguler.copyWith(
                            fontSize: 8,
                            color: blackSecondary3,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Sabtu, 1 April 2022, 22:00',
                          style: bold.copyWith(
                            fontSize: 8,
                            color: blackPrimary,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Divider(
                          thickness: 1.5,
                          height: 1,
                          indent: 0,
                          endIndent: 0,
                          color: greyColor,
                        ),
                      ],
                    ),
                  ),
                ),
                TimelineTile(
                  beforeLineStyle: LineStyle(color: greyColor, thickness: 1),
                  indicatorStyle: IndicatorStyle(
                    indicator: Image.asset('assets/stop_icon.png'),
                  ),
                  isLast: true,
                  endChild: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          AppLocalizations.of(context)!.doneParking,
                          style: reguler.copyWith(
                            fontSize: 8,
                            color: blackSecondary3,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Sabtu, 1 April 2022, 22:00',
                          style: bold.copyWith(
                            fontSize: 8,
                            color: blackPrimary,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Divider(
                          thickness: 1.5,
                          height: 1,
                          indent: 0,
                          endIndent: 0,
                          color: greyColor,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  AppLocalizations.of(context)!.address,
                  style: reguler.copyWith(
                    fontSize: 8,
                    color: blackSecondary3,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'Jl. Cideng Timur No.81, Petojo Sel., Kecamatan Gambir, Kota Jakarta Pusat, Daerah Khusus Ibukota Jakarta 10160',
                  style: bold.copyWith(
                    fontSize: 8,
                    color: blackPrimary,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StopMap extends StatelessWidget {
  const StopMap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/stopmap.png',
            fit: BoxFit.fill,
          ),
          Positioned(
              top: 60,
              left: 30,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bluePrimary,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: whiteColor,
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
