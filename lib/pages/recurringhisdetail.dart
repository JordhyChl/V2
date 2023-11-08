import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/recurringhistdetail.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

class RecurringHistoryDetail extends StatefulWidget {
  final String recurringNo;
  final bool darkMode;
  const RecurringHistoryDetail(
      {Key? key, required this.recurringNo, required this.darkMode})
      : super(key: key);

  @override
  State<RecurringHistoryDetail> createState() => _RecurringHistoryDetailState();
}

class _RecurringHistoryDetailState extends State<RecurringHistoryDetail> {
  late RecurringHistDetailModel recurringHistDetailModel;
  late Future<dynamic> _getRecurringHistDetail;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    _getRecurringHistDetail = getRecurringHistDetail();
  }

  Future<dynamic> getRecurringHistDetail() async {
    final result =
        await APIService().getRecurringHistDetail(widget.recurringNo);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                widget.darkMode ? whiteCardColor : blueGradientSecondary2,
                widget.darkMode ? whiteCardColor : blueGradientSecondary1,
              ])),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back,
                size: 26,
              ),
            ),
            Text(
              'Detail Recurring History',
              style: bold.copyWith(
                fontSize: 14,
                color: widget.darkMode ? whiteColorDarkMode : whiteColor,
              ),
            ),
            Container(
              width: 10,
            )
          ],
        ),
      ),
      backgroundColor: whiteColor,
      body: FutureBuilder(
          future: _getRecurringHistDetail,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data is ErrorTrapModel) {
                return Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/handling/500error.png',
                          height: 240,
                          width: 240,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 50, right: 50, top: 10),
                          child: Text(
                            AppLocalizations.of(context)!.error500,
                            textAlign: TextAlign.center,
                            style: bold.copyWith(
                              fontSize: 14,
                              color: widget.darkMode
                                  ? whiteColorDarkMode
                                  : blackSecondary2,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 30, right: 30, top: 10),
                          child: Text(
                            AppLocalizations.of(context)!.error500Sub,
                            textAlign: TextAlign.center,
                            style: reguler.copyWith(
                              fontSize: 12,
                              color: widget.darkMode
                                  ? whiteColorDarkMode
                                  : blackSecondary2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                recurringHistDetailModel = snapshot.data;
                return Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.recurringInfo,
                              style: bold.copyWith(
                                fontSize: 12,
                                color: widget.darkMode
                                    ? whiteColorDarkMode
                                    : bluePrimary,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                bottom: 20,
                              ),
                              padding: const EdgeInsets.all(
                                16,
                              ),
                              decoration: BoxDecoration(
                                color: whiteCardColor,
                              ),
                              width: double.infinity,
                              // height: 160,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .repaymentNumber,
                                        style: reguler.copyWith(
                                          fontSize: 12,
                                          color: widget.darkMode
                                              ? whiteColorDarkMode
                                              : blackSecondary3,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          recurringHistDetailModel
                                              .data.result.orderId
                                              .toString(),
                                          textAlign: TextAlign.end,
                                          style: bold.copyWith(
                                            fontSize: 12,
                                            color: blackPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.totalUnit,
                                        style: reguler.copyWith(
                                          fontSize: 12,
                                          color: widget.darkMode
                                              ? whiteColorDarkMode
                                              : blackSecondary3,
                                        ),
                                      ),
                                      Text(
                                        '${recurringHistDetailModel.data.result.totalUnit} Unit',
                                        style: reguler.copyWith(
                                          fontSize: 12,
                                          color: blackPrimary,
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .totalPrice,
                                        style: reguler.copyWith(
                                          fontSize: 12,
                                          color: widget.darkMode
                                              ? whiteColorDarkMode
                                              : blackSecondary3,
                                        ),
                                      ),
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'id',
                                          decimalDigits: 0,
                                          symbol: 'Rp. ',
                                        ).format(recurringHistDetailModel.data
                                            .result.recurringDetail.paidAmount),
                                        style: reguler.copyWith(
                                          fontSize: 12,
                                          color: blackPrimary,
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    width: 80,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: greenSecondary,
                                    ),
                                    child: Text(
                                      recurringHistDetailModel
                                          .data.result.status
                                          .toUpperCase(),
                                      style: reguler.copyWith(
                                        fontSize: 12,
                                        color: recurringHistDetailModel
                                                    .data.result.status ==
                                                'paid'
                                            ? greenPrimary
                                            : recurringHistDetailModel
                                                        .data.result.status ==
                                                    'pending'
                                                ? redPrimary
                                                : recurringHistDetailModel.data
                                                            .result.status ==
                                                        'cancel'
                                                    ? redPrimary
                                                    : greyColor,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.detailUnit,
                                  style: bold.copyWith(
                                    fontSize: 12,
                                    color: bluePrimary,
                                  ),
                                ),
                                Text(
                                  '${recurringHistDetailModel.data.result.totalUnit} Unit',
                                  style: reguler.copyWith(
                                    fontSize: 12,
                                    color: blackPrimary,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height / 2.5,
                              child: ListView.builder(
                                itemCount: recurringHistDetailModel
                                    .data.result.cartDetail.length,
                                itemBuilder: (context, index) {
                                  DateTime? getTrxDate = DateTime.parse(
                                          recurringHistDetailModel.data.result
                                              .cartDetail[index].expired)
                                      .toLocal();
                                  String setTrxDate = DateFormat('dd MMMM yyyy')
                                      .format(getTrxDate);

                                  DateTime? getExpDate = DateTime.parse(
                                          recurringHistDetailModel.data.result
                                              .cartDetail[index].nextExpired)
                                      .toLocal();
                                  String setExpDate = DateFormat('dd MMMM yyyy')
                                      .format(getExpDate);
                                  return Container(
                                    decoration:
                                        BoxDecoration(color: whiteCardColor),
                                    padding: const EdgeInsets.all(10),
                                    width: double.infinity,
                                    height: 210,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .numberPlate,
                                              style: reguler.copyWith(
                                                fontSize: 12,
                                                color: widget.darkMode
                                                    ? whiteColorDarkMode
                                                    : blackSecondary3,
                                              ),
                                            ),
                                            Text(
                                              recurringHistDetailModel
                                                  .data
                                                  .result
                                                  .cartDetail[index]
                                                  .platNomor,
                                              style: reguler.copyWith(
                                                fontSize: 12,
                                                color: blackPrimary,
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .gsmnumber,
                                              style: reguler.copyWith(
                                                fontSize: 12,
                                                color: widget.darkMode
                                                    ? whiteColorDarkMode
                                                    : blackSecondary3,
                                              ),
                                            ),
                                            Text(
                                              recurringHistDetailModel
                                                  .data
                                                  .result
                                                  .cartDetail[index]
                                                  .nomorGsm,
                                              style: reguler.copyWith(
                                                fontSize: 12,
                                                color: blackPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .package,
                                              style: reguler.copyWith(
                                                fontSize: 12,
                                                color: widget.darkMode
                                                    ? whiteColorDarkMode
                                                    : blackSecondary3,
                                              ),
                                            ),
                                            Text(
                                              recurringHistDetailModel
                                                  .data
                                                  .result
                                                  .cartDetail[index]
                                                  .paket,
                                              style: reguler.copyWith(
                                                fontSize: 12,
                                                color: blackPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .price,
                                              style: reguler.copyWith(
                                                fontSize: 12,
                                                color: widget.darkMode
                                                    ? whiteColorDarkMode
                                                    : blackSecondary3,
                                              ),
                                            ),
                                            Text(
                                              NumberFormat.currency(
                                                locale: 'id',
                                                decimalDigits: 0,
                                                symbol: 'Rp. ',
                                              ).format(recurringHistDetailModel
                                                  .data
                                                  .result
                                                  .cartDetail[index]
                                                  .harga),
                                              style: reguler.copyWith(
                                                fontSize: 12,
                                                color: blackPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Divider(
                                          height: 1,
                                          thickness: 1,
                                          indent: 0,
                                          endIndent: 0,
                                          color: greyColor,
                                        ),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .transactionDate,
                                                  style: reguler.copyWith(
                                                    fontSize: 12,
                                                    color: widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : blackSecondary3,
                                                  ),
                                                ),
                                                Text(
                                                  setTrxDate,
                                                  style: bold.copyWith(
                                                    fontSize: 12,
                                                    color: blackPrimary,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .nextExpire,
                                                  style: reguler.copyWith(
                                                    fontSize: 12,
                                                    color: widget.darkMode
                                                        ? whiteColorDarkMode
                                                        : blackSecondary3,
                                                  ),
                                                ),
                                                Text(
                                                  setExpDate,
                                                  style: bold.copyWith(
                                                    fontSize: 12,
                                                    color: blackPrimary,
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                );
              }
            }
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonTheme(
                      themeMode:
                          widget.darkMode ? ThemeMode.dark : ThemeMode.light,
                      child: const SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                          width: 110,
                          height: 25,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SkeletonTheme(
                      themeMode:
                          widget.darkMode ? ThemeMode.dark : ThemeMode.light,
                      child: const SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                          width: double.infinity,
                          height: 160,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SkeletonTheme(
                      themeMode:
                          widget.darkMode ? ThemeMode.dark : ThemeMode.light,
                      child: const SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                          width: 95,
                          height: 25,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SkeletonTheme(
                      themeMode:
                          widget.darkMode ? ThemeMode.dark : ThemeMode.light,
                      child: const SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                          width: double.infinity,
                          height: 160,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Container unitModal(context) {
    return Container(
      decoration: BoxDecoration(color: whiteCardColor),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      height: 210,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.numberPlate,
                style: reguler.copyWith(
                  fontSize: 10,
                  color: blackSecondary3,
                ),
              ),
              Text(
                'B 1234 QWE',
                style: reguler.copyWith(
                  fontSize: 10,
                  color: blackPrimary,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.gsmnumber,
                style: reguler.copyWith(
                  fontSize: 10,
                  color: blackSecondary3,
                ),
              ),
              Text(
                '082123456789',
                style: reguler.copyWith(
                  fontSize: 10,
                  color: blackPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.package,
                style: reguler.copyWith(
                  fontSize: 10,
                  color: blackSecondary3,
                ),
              ),
              Text(
                '360 Hari + 120 Hari',
                style: reguler.copyWith(
                  fontSize: 10,
                  color: blackPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.price,
                style: reguler.copyWith(
                  fontSize: 10,
                  color: blackSecondary3,
                ),
              ),
              Text(
                'Rp.500.000',
                style: reguler.copyWith(
                  fontSize: 10,
                  color: blackPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: 0,
            endIndent: 0,
            color: greyColor,
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expired',
                    style: reguler.copyWith(
                      fontSize: 10,
                      color: blackSecondary3,
                    ),
                  ),
                  Text(
                    '01 Januari 2022',
                    style: bold.copyWith(
                      fontSize: 10,
                      color: blackPrimary,
                    ),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Expired',
                    style: reguler.copyWith(
                      fontSize: 10,
                      color: blackSecondary3,
                    ),
                  ),
                  Text(
                    '01 Februari 2023',
                    style: bold.copyWith(
                      fontSize: 10,
                      color: blackPrimary,
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
