import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/pages/vehiclelist.dart';
import 'package:gpsid/theme.dart';
import 'package:gpsid/model/unit.dart';

class StatusUnitCard extends StatelessWidget {
  final bool all;
  final StatusUnit unit;
  final bool darkmode;

  const StatusUnitCard(this.unit,
      {super.key, required this.all, required this.darkmode});

  @override
  Widget build(BuildContext context) {
    Locale myLocale = Localizations.localeOf(context);
    return InkWell(
      onTap: () {
        // Navigator.pushNamed(context, '/vehiclelist');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleList(
              status: unit.status,
              darkMode: darkmode,
            ),
          ),
        );
      },
      child: Container(
        width: 135,
        // height: 84,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              all ? blueGradientSecondary1 : whiteCardColor,
              all ? blueGradientSecondary2 : whiteCardColor
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          // color: all ? blueGradient : whiteColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 1,
            color: all ? whiteColor : whiteCardColor,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 5,
          ),
          child: all
              ? Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/vehicle/carwhite.png',
                          width: 32,
                          height: 32,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.all,
                            style: bold.copyWith(
                              fontSize: 12,
                              color: whiteColor,
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.totalUnit,
                              style: bold.copyWith(
                                fontSize: 10,
                                color: whiteColor,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              '${unit.jumlah} ${myLocale.languageCode == 'en' ? int.parse(unit.jumlah) >= 1 ? '${AppLocalizations.of(context)!.unitCart}s' : AppLocalizations.of(context)!.unitCart : AppLocalizations.of(context)!.unitCart}',
                              style: reguler.copyWith(
                                fontSize: 10,
                                color: whiteColor,
                              ),
                            )
                          ],
                        ),
                        Image.asset(
                          'assets/arrow_icon.png',
                          width: 12,
                          color: darkmode ? whiteColorDarkMode : whiteColor,
                        ),
                      ],
                    )
                  ],
                )
              // ? Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Column(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Image.asset(
              //             'assets/vehicle/carwhite.png',
              //             width: 32,
              //             height: 32,
              //           ),
              //           Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text(
              //                 AppLocalizations.of(context)!.all,
              //                 style: bold.copyWith(
              //                   fontSize: 12,
              //                   color: unit.warna,
              //                 ),
              //               ),
              //               const SizedBox(
              //                 height: 2,
              //               ),
              //             ],
              //           ),
              //           Image.asset(
              //             'assets/arrow_icon.png',
              //             width: 12,
              //             color: blackSecondary3,
              //           ),
              //         ],
              //       )
              //     ],
              //   )
              : Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          unit.mobil,
                          width: 32,
                          height: 32,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Text(
                            unit.status,
                            style: bold.copyWith(
                              fontSize: 12,
                              color: darkmode ? whiteColorDarkMode : unit.warna,
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.totalUnit,
                              style: bold.copyWith(
                                fontSize: 10,
                                color: blackPrimary,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              '${unit.jumlah} Unit',
                              style: reguler.copyWith(
                                fontSize: 10,
                                color: darkmode
                                    ? whiteColorDarkMode
                                    : blackSecondary2,
                              ),
                            )
                          ],
                        ),
                        Image.asset(
                          'assets/arrow_icon.png',
                          width: 12,
                          color: blackPrimary,
                        ),
                      ],
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
