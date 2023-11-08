// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_typing_uninitialized_variables
import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/currentpoin.sspoin.model.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/rewardlist.model.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:gpsid/widgets/redeemPulsa.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

class RedeemPoint extends StatefulWidget {
  final bool darkMode;
  const RedeemPoint({Key? key, required this.darkMode}) : super(key: key);

  @override
  State<RedeemPoint> createState() => _RedeemPointState();
}

var size, width, height;
List<String> pricepulse = [
  '30',
  '60',
  '180',
  '360',
];

class _RedeemPointState extends State<RedeemPoint> {
  late Future<dynamic> _getRewardList;
  late RewardListModel rewardList;
  String currentPoin = '-';

  @override
  void initState() {
    super.initState();
    _getRewardList = getRewardList();
  }

  Future<dynamic> getRewardList() async {
    final result = await APIService().getRewardList();
    final poin = await APIService().getCurrentPoin();
    if (poin is SSPOINCurrentPoinModel) {
      setState(() {
        currentPoin = poin.data.currentPoint.toString();
      });
    } else {
      setState(() {
        currentPoin = '-';
      });
    }
    print(result);
    return result;
  }

  redeem(int id) async {
    Dialogs().loadingDialog(context);
    final result = await APIService().redeemPoin(id, '');
    if (result is MessageModel) {
      if (result.status == true) {
        Dialogs().hideLoaderDialog(context);
        showSuccess(context, result.message);
      } else {
        Dialogs().hideLoaderDialog(context);
        showInfoAlert(context, result.message, '');
      }
    } else {
      Dialogs().hideLoaderDialog(context);
      showInfoAlert(context, result.message, '');
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.darkMode ? whiteCardColor : bluePrimary,
        title: Text(AppLocalizations.of(context)!.redeemPoin),
      ),
      backgroundColor: whiteColor,
      body: FutureBuilder(
          future: _getRewardList,
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
                rewardList = snapshot.data;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 5),
                      child: SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                              color: whiteCardColor,
                              border: Border.all(
                                color: bluePrimary,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  '${AppLocalizations.of(context)!.totalSSpoin} :',
                                  style: reguler.copyWith(
                                    fontSize: 14,
                                    color: bluePrimary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Image.asset(
                                        'assets/sspoint2.png',
                                        height: 16,
                                      ),
                                    ),
                                    Text(
                                      currentPoin,
                                      style: reguler.copyWith(
                                        fontSize: 14,
                                        color: bluePrimary,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 2),
                                      child: Text(
                                        AppLocalizations.of(context)!.point,
                                        style: reguler.copyWith(
                                          fontSize: 14,
                                          color: bluePrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: rewardList.data.results.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rewardList
                                      .data.results[index].rewardCategoryName,
                                  style: bold.copyWith(
                                    fontSize: 14,
                                    color: blackPrimary,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: 300,
                                  child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: rewardList.data.results[index]
                                          .dataVoucher.length,
                                      itemBuilder: (context, idx) {
                                        if (rewardList
                                                .data
                                                .results[index]
                                                .dataVoucher[idx]
                                                .rewardCategoryId ==
                                            2) {
                                          return RedeemPulsa(
                                            gsmNumber: '0',
                                            rewardName: rewardList
                                                .data
                                                .results[index]
                                                .dataVoucher[idx]
                                                .rewardName,
                                            rewardDescription: rewardList
                                                .data
                                                .results[index]
                                                .dataVoucher[idx]
                                                .rewardDescription,
                                            rewardImageUrl: rewardList
                                                .data
                                                .results[index]
                                                .dataVoucher[idx]
                                                .rewardImageUrl,
                                            rewardCategoryName: rewardList
                                                .data
                                                .results[index]
                                                .dataVoucher[idx]
                                                .rewardCategoryName,
                                            rewardPoint: rewardList
                                                .data
                                                .results[index]
                                                .dataVoucher[idx]
                                                .rewardPoint,
                                            rewardCategoryId: rewardList
                                                .data
                                                .results[index]
                                                .dataVoucher[idx]
                                                .rewardCategoryId,
                                            rewardId: rewardList
                                                .data
                                                .results[index]
                                                .dataVoucher[idx]
                                                .rewardId,
                                            darkMode: widget.darkMode,
                                          );
                                        } else {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                              right: 12,
                                            ),
                                            width: 165,
                                            // height: 250,
                                            child: InkWell(
                                              onTap: () {
                                                if (rewardList
                                                        .data
                                                        .results[index]
                                                        .dataVoucher[idx]
                                                        .rewardCategoryId ==
                                                    2) {
                                                  showInfoAlert(
                                                      context, 'Pulsa', '');
                                                } else {
                                                  redeemDialog(
                                                      context,
                                                      rewardList
                                                          .data
                                                          .results[index]
                                                          .dataVoucher[idx]
                                                          .rewardId,
                                                      rewardList
                                                          .data
                                                          .results[index]
                                                          .dataVoucher[idx]
                                                          .rewardDescription,
                                                      currentPoin,
                                                      rewardList
                                                          .data
                                                          .results[index]
                                                          .dataVoucher[idx]
                                                          .rewardPoint
                                                          .toString(),
                                                      rewardList
                                                          .data
                                                          .results[index]
                                                          .dataVoucher[idx]
                                                          .rewardCategoryId);
                                                }

                                                print(
                                                    'ID: ${rewardList.data.results[index].dataVoucher[idx].rewardId}');
                                                // redeem(rewardList
                                                //     .data
                                                //     .results[index]
                                                //     .dataVoucher[idx]
                                                //     .rewardId);
                                              },
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                color: widget.darkMode
                                                    ? whiteCardColor
                                                    : null,
                                                elevation: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                        width: double.infinity,
                                                        height: 150,
                                                        child: Image.network(
                                                          rewardList
                                                              .data
                                                              .results[index]
                                                              .dataVoucher[idx]
                                                              .rewardImageUrl,
                                                          fit: BoxFit.cover,
                                                        )),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Image.asset(
                                                                  'assets/sspoint.png',
                                                                  width: 14,
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  NumberFormat
                                                                          .decimalPattern()
                                                                      .format(rewardList
                                                                          .data
                                                                          .results[
                                                                              index]
                                                                          .dataVoucher[
                                                                              idx]
                                                                          .rewardPoint)
                                                                      .replaceAll(
                                                                          ',',
                                                                          '.'),
                                                                  style: reguler
                                                                      .copyWith(
                                                                    fontSize:
                                                                        12,
                                                                    color: widget
                                                                            .darkMode
                                                                        ? whiteColorDarkMode
                                                                        : blackSecondary1,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 3),
                                                              child: Text(
                                                                rewardList
                                                                    .data
                                                                    .results[
                                                                        index]
                                                                    .dataVoucher[
                                                                        idx]
                                                                    .rewardName,
                                                                style: bold
                                                                    .copyWith(
                                                                  fontSize: 12,
                                                                  color:
                                                                      blackPrimary,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }),
                                ),
                              ],
                            ));
                      },
                    ))
                  ],
                );
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
                        SkeletonTheme(
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
