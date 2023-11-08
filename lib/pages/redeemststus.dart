// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_typing_uninitialized_variables
import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/rewardstatus.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

class RedeemStatus extends StatefulWidget {
  final bool darkMode;
  const RedeemStatus({Key? key, required this.darkMode}) : super(key: key);

  @override
  State<RedeemStatus> createState() => _RedeemStatusState();
}

var size, width, height;
List<String> pricepulse = [
  '30',
  '60',
  '180',
  '360',
];

class _RedeemStatusState extends State<RedeemStatus> {
  late Future<dynamic> _getRedeemStatus;
  late RedeemStatusModel redeemStatus;
  String currentPoin = '-';
  String lang = '';

  @override
  void initState() {
    super.initState();
    _getRedeemStatus = getRedeemStatus();
    // getLocalLang();
  }

  Future<dynamic> getRedeemStatus() async {
    // Locale myLocale = Localizations.localeOf(context);
    // Locale locale = await GeneralService().getLocalLang(context);
    // lang = myLocale.toString();

    var dateFrom = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day - 7);
    var dateTo = DateTime.now();
    var getDateFrom = DateFormat('yyyy-MM-dd').format(dateFrom.toLocal());
    var getDateTo = DateFormat('yyyy-MM-dd').format(dateTo.toLocal());
    // final result = await APIService().getRewardList();
    // final poin = await APIService().getCurrentPoin();
    final result = await APIService().getRedeemStatus(getDateFrom, getDateTo);
    if (result is ErrorTrapModel) {
      print(result.statusError);
    } else {
      print(result);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.darkMode ? whiteCardColor : bluePrimary,
        title: Text(
          AppLocalizations.of(context)!.redeemStatus,
          style: bold.copyWith(
              fontSize: 16,
              color: widget.darkMode ? whiteColorDarkMode : whiteColor),
        ),
      ),
      backgroundColor: whiteColor,
      body: FutureBuilder(
          future: _getRedeemStatus,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            Locale myLocale = Localizations.localeOf(context);
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
                if (snapshot.data is MessageModel) {
                  var message = snapshot.data;
                  return Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/handling/emptyall.png',
                            height: 240,
                            width: 240,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 50, right: 50, top: 10),
                            child: Text(
                              message.message,
                              textAlign: TextAlign.center,
                              style: bold.copyWith(
                                fontSize: 14,
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
                  redeemStatus = snapshot.data;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 8, left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.redeemCode,
                                textAlign: TextAlign.start,
                                style: bold.copyWith(
                                  fontSize: 14,
                                  color: blackPrimary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.redeemStatus,
                                textAlign: TextAlign.end,
                                style: bold.copyWith(
                                  fontSize: 14,
                                  color: blackPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: redeemStatus.data.result.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {},
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: Text(
                                                  redeemStatus.data
                                                      .result[index].redeemNo,
                                                  style: reguler.copyWith(
                                                      color: widget.darkMode
                                                          ? whiteColorDarkMode
                                                          : blackSecondary2,
                                                      fontSize: 12),
                                                ),
                                              ),
                                              Text(
                                                  redeemStatus
                                                      .data
                                                      .result[index]
                                                      .requestDate,
                                                  style: reguler.copyWith(
                                                      color: widget.darkMode
                                                          ? whiteColorDarkMode
                                                          : blackSecondary3,
                                                      fontSize: 10))
                                            ],
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8),
                                                  child: Text(
                                                      redeemStatus
                                                          .data
                                                          .result[index]
                                                          .rewardName,
                                                      textAlign: TextAlign.end,
                                                      style: reguler.copyWith(
                                                          color: widget.darkMode
                                                              ? whiteColorDarkMode
                                                              : blackSecondary2,
                                                          fontSize: 12)),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius: const BorderRadius.all(
                                                          Radius.circular(4)),
                                                      color: myLocale.languageCode ==
                                                              'id'
                                                          ? redeemStatus
                                                                      .data
                                                                      .result[
                                                                          index]
                                                                      .statusRedeemIdn
                                                                      .toLowerCase() ==
                                                                  'proses verifikasi'
                                                              ? yellowSecondary
                                                              : redeemStatus.data.result[index].statusRedeemIdn.toLowerCase() ==
                                                                      'sedang dikirim'
                                                                  ? blueGradient
                                                                  : redeemStatus.data.result[index].statusRedeemIdn.toLowerCase() ==
                                                                          'berhasil'
                                                                      ? blueGradientSecondary2
                                                                      : redeemStatus.data.result[index].statusRedeemIdn.toLowerCase() ==
                                                                              'gagal'
                                                                          ? redSecondary
                                                                          : greyColor
                                                          : myLocale.languageCode ==
                                                                  'en'
                                                              ? redeemStatus
                                                                          .data
                                                                          .result[index]
                                                                          .statusRedeemEng
                                                                          .toLowerCase() ==
                                                                      'verification'
                                                                  ? yellowSecondary
                                                                  : redeemStatus.data.result[index].statusRedeemEng.toLowerCase() == 'sending'
                                                                      ? blueGradient
                                                                      : redeemStatus.data.result[index].statusRedeemEng.toLowerCase() == 'success'
                                                                          ? greenSecondary
                                                                          : redeemStatus.data.result[index].statusRedeemEng.toLowerCase() == 'failed'
                                                                              ? redSecondary
                                                                              : greyColor
                                                              : greyColor),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8,
                                                            right: 8,
                                                            top: 2,
                                                            bottom: 2),
                                                    child: Text(
                                                      myLocale.languageCode ==
                                                              'id'
                                                          ? redeemStatus
                                                              .data
                                                              .result[index]
                                                              .statusRedeemIdn
                                                          : redeemStatus
                                                              .data
                                                              .result[index]
                                                              .statusRedeemEng,
                                                      style: reguler.copyWith(
                                                          fontSize: 10,
                                                          color: myLocale.languageCode ==
                                                                  'id'
                                                              ? redeemStatus
                                                                          .data
                                                                          .result[
                                                                              index]
                                                                          .statusRedeemIdn
                                                                          .toLowerCase() ==
                                                                      'proses verifikasi'
                                                                  ? yellowPrimary
                                                                  : redeemStatus
                                                                              .data
                                                                              .result[
                                                                                  index]
                                                                              .statusRedeemIdn
                                                                              .toLowerCase() ==
                                                                          'sedang dikirim'
                                                                      ? blackPrimary
                                                                      : redeemStatus.data.result[index].statusRedeemIdn.toLowerCase() ==
                                                                              'berhasil'
                                                                          ? greenPrimary
                                                                          : redeemStatus.data.result[index].statusRedeemIdn.toLowerCase() ==
                                                                                  'gagal'
                                                                              ? redPrimary
                                                                              : blackPrimary
                                                              : myLocale.languageCode ==
                                                                      'en'
                                                                  ? redeemStatus
                                                                              .data
                                                                              .result[index]
                                                                              .statusRedeemEng
                                                                              .toLowerCase() ==
                                                                          'verification'
                                                                      ? yellowPrimary
                                                                      : redeemStatus.data.result[index].statusRedeemEng.toLowerCase() == 'sending'
                                                                          ? blackPrimary
                                                                          : redeemStatus.data.result[index].statusRedeemEng.toLowerCase() == 'success'
                                                                              ? greenPrimary
                                                                              : redeemStatus.data.result[index].statusRedeemEng.toLowerCase() == 'failed'
                                                                                  ? redPrimary
                                                                                  : blackPrimary
                                                                  : blackPrimary),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 20),
                                      child: Divider(
                                        height: 1,
                                        thickness: .5,
                                        indent: 0,
                                        endIndent: 0,
                                        color: greyColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      )
                    ],
                  );
                }
              }
            }
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: 5,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SkeletonAvatar(
                          style: SkeletonAvatarStyle(
                              shape: BoxShape.rectangle,
                              width: 140,
                              height: 30),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 172,
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (context, idx) {
                                return Container(
                                  margin: const EdgeInsets.only(
                                    right: 12,
                                  ),
                                  width: 120,
                                  height: 172,
                                  child: SkeletonTheme(
                                    themeMode: widget.darkMode
                                        ? ThemeMode.dark
                                        : ThemeMode.light,
                                    child: const SkeletonAvatar(
                                      style: SkeletonAvatarStyle(
                                          shape: BoxShape.rectangle,
                                          width: 140,
                                          height: 30),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ));
              },
            );
          }),
    );
  }
}
