// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/theme.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TrackReplayReport extends StatelessWidget {
  var size, height, width;

  TrackReplayReport({Key? key}) : super(key: key);

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
                    AppLocalizations.of(context)!.runningReport,
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
                'Total Moving Time',
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
                  '1 ${AppLocalizations.of(context)!.hour} 16 ${AppLocalizations.of(context)!.minutes} 49 ${AppLocalizations.of(context)!.second}',
                  style: bold.copyWith(
                    fontSize: 16,
                    color: blackPrimary,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              hourMeterModel(context),
              const SizedBox(
                height: 20,
              ),
              hourMeterModel(context),
              const SizedBox(
                height: 20,
              ),
              hourMeterModel(context),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  hourMeterModel(context) {
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
              Image.asset('assets/hourmetermap.png'),
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
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(width: 1, color: whiteColor)),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 10,
                          ),
                        ),
                        Text(
                          'Playback',
                          style: reguler.copyWith(
                            fontSize: 10,
                            color: whiteColor,
                          ),
                        ),
                      ],
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
                          'Sabtu, 1 April 2022, 22:00',
                          style: bold.copyWith(
                            fontSize: 8,
                            color: blackPrimary,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          'Gambir, Jakarta Pusat, 10160, Indonesia',
                          style: reguler.copyWith(
                            fontSize: 8,
                            color: blackSecondary3,
                          ),
                        ),
                        Text(AppLocalizations.of(context)!.seeDetails,
                            style: bold.copyWith(
                                fontSize: 8,
                                color: bluePrimary,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline)),
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
                          'Sabtu, 1 April 2022, 22:00',
                          style: bold.copyWith(
                            fontSize: 8,
                            color: blackPrimary,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          'Gambir, Jakarta Pusat, 10160, Indonesia',
                          style: reguler.copyWith(
                            fontSize: 8,
                            color: blackSecondary3,
                          ),
                        ),
                        Text(AppLocalizations.of(context)!.seeDetails,
                            style: bold.copyWith(
                                fontSize: 8,
                                color: bluePrimary,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                rowDataModel(
                  const Icon(
                    Icons.electric_car,
                    size: 12,
                  ),
                  'Moving Time',
                  '5 ${AppLocalizations.of(context)!.minutes} 30 ${AppLocalizations.of(context)!.second}',
                ),
                const SizedBox(
                  height: 8,
                ),
                rowDataModel(
                  const Icon(
                    Icons.speed,
                    size: 12,
                  ),
                  'Average Speed',
                  '60km/h',
                ),
                const SizedBox(
                  height: 8,
                ),
                rowDataModel(
                  const Icon(
                    Icons.speed,
                    size: 12,
                  ),
                  'Max Speed',
                  '100km/h',
                ),
                const SizedBox(
                  height: 8,
                ),
                rowDataModel(
                  const Icon(
                    Icons.adjust,
                    size: 12,
                  ),
                  'Drive Millage',
                  '1000m',
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row rowDataModel(
    Icon iconModel,
    String statusModel,
    String dataModel,
  ) {
    return Row(
      children: [
        iconModel,
        const SizedBox(
          width: 10,
        ),
        Text(
          statusModel,
          style: reguler.copyWith(
            fontSize: 8,
            color: blackSecondary3,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Text(
          dataModel,
          style: bold.copyWith(
            fontSize: 8,
            color: blackPrimary,
          ),
        ),
      ],
    );
  }
}
