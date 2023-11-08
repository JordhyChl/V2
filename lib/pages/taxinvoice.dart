// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, avoid_print

import 'package:flutter/material.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/model/errortrap.model.dart';
import 'package:gpsid/model/localdata.model.dart';
import 'package:gpsid/model/message.model.dart';
import 'package:gpsid/model/npwp.model.dart';
import 'package:gpsid/pages/paymentmethod.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/service/general.dart';
import 'package:gpsid/theme.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class TaxInvoice extends StatefulWidget {
  final int totalUnit;
  final int totalPrice;
  final List<dynamic> idCart;
  final List<dynamic> cart;
  final bool darkMode;
  const TaxInvoice(
      {Key? key,
      required this.idCart,
      required this.totalUnit,
      required this.totalPrice,
      required this.cart,
      required this.darkMode})
      : super(key: key);

  @override
  State<TaxInvoice> createState() => _TaxInvoiceState();
}

class _TaxInvoiceState extends State<TaxInvoice> {
  final TextEditingController taxNumber = TextEditingController();
  final TextEditingController taxOwner = TextEditingController();
  final TextEditingController taxAddress = TextEditingController();
  final TextEditingController whatsAppNum = TextEditingController();
  final TextEditingController email = TextEditingController();
  late Future<dynamic> _getNPWP;
  late NPWPListModel npwp;
  var maskFormatterNPWP = MaskTextInputFormatter(
      mask: '##.###.###.#-###.###',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  var maskFormatterPhone = MaskTextInputFormatter(
      mask: '+62 ####-####-###',
      filter: {"#": RegExp(r'[0-9]')},
      initialText: '+62',
      type: MaskAutoCompletionType.lazy);

  @override
  void dispose() {
    taxNumber.dispose();
    taxOwner.dispose();
    taxAddress.dispose();
    whatsAppNum.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getNPWP = getNPWP();
  }

  Future<dynamic> getNPWP() async {
    LocalData localData = await GeneralService().readLocalUserStorage();
    final result = await APIService().getNPWP(localData.Username, 'portal');
    if (result is ErrorTrapModel) {
      showInfoAlert(context, result.statusError, '');
    } else {
      print(result);
      if (result is NPWPListModel) {
        if (result.data.isNotEmpty) {
          setState(() {
            taxNumber.text = maskFormatterNPWP.maskText(result.data[0].npwpNo);
            whatsAppNum.text = maskFormatterPhone.maskText(
                result.data[0].npwpWa.startsWith('0')
                    ? result.data[0].npwpWa.replaceFirst('0', ' ')
                    : result.data[0].npwpWa);
            taxOwner.text = result.data[0].npwpName;
            taxAddress.text = result.data[0].npwpAddr;
            email.text = result.data[0].npwpEmail;
          });
        }
      }
    }
    return result;
  }

  editNPWP(String username, String npwpNo, String npwpName, String npwpAddress,
      String npwpWA, String npwpEmail) async {
    await Dialogs().loadingDialog(context);
    final res = await APIService()
        .editNPWP(username, npwpNo, npwpName, npwpAddress, npwpWA, npwpEmail);
    if (res is ErrorTrapModel) {
      Navigator.of(context).pop();
      showInfoAlert(context, res.statusError, res.bodyError);
    } else {
      if (res is MessageModel) {
        Navigator.of(context).pop();
        showInfoAlert(context, res.message, '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // size = MediaQuery.of(context).size;
    // width = size.width;
    // height = size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                widget.darkMode ? whiteCardColor : blueGradientSecondary1,
                widget.darkMode ? whiteCardColor : blueGradientSecondary2,
              ],
            ),
          ),
        ),
        leading: IconButton(
          iconSize: 32,
          // padding: const EdgeInsets.only(top: 20),
          icon: const Icon(Icons.arrow_back_outlined),
          color: Colors.white,
          // onPressed: () => Navigator.of(context).pop(),
          onPressed: () {
            // Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.taxInvoice,
          style: bold.copyWith(
            fontSize: 16,
            color: widget.darkMode ? whiteColorDarkMode : whiteColor,
          ),
        ),
      ),
      backgroundColor: whiteColor,
      body: FutureBuilder(
          future: _getNPWP,
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
                              color: blackSecondary2,
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
                              color: blackSecondary2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                npwp = snapshot.data;
                return SingleChildScrollView(
                  physics: const ScrollPhysics(parent: BouncingScrollPhysics()),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Text(AppLocalizations.of(context)!.taxNumber,
                                  style: bold.copyWith(
                                    fontSize: 14,
                                    color: blackPrimary,
                                  )),
                              const SizedBox(
                                height: 8,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.1,
                                child: TextFormField(
                                  controller: taxNumber,
                                  style: reguler.copyWith(
                                    fontSize: 13,
                                    color: blackPrimary,
                                  ),
                                  inputFormatters: [maskFormatterNPWP],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    fillColor:
                                        widget.darkMode ? whiteCardColor : null,
                                    counterText:
                                        '${AppLocalizations.of(context)!.example} : 12.345.678.9-123.456',
                                    filled: true,
                                    hintText:
                                        AppLocalizations.of(context)!.insertTax,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: blackPrimary,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 3,
                                        color: blueGradient,
                                      ),
                                    ),
                                    hintStyle: reguler.copyWith(
                                      fontSize: 12,
                                      color: widget.darkMode
                                          ? whiteColorDarkMode
                                          : blackSecondary3,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Visibility(
                        visible: npwp.data.isEmpty ? false : true,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Container(
                            color: whiteCardColor,
                            height: 200,
                            width: double.infinity,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: npwp.data.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  width: double.infinity,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        taxNumber.text = maskFormatterNPWP
                                            .maskText(npwp.data[index].npwpNo);
                                        whatsAppNum.text = maskFormatterPhone
                                            .maskText(npwp.data[index].npwpWa
                                                    .startsWith('0')
                                                ? npwp.data[index].npwpWa
                                                    .replaceFirst('0', ' ')
                                                : npwp.data[index].npwpWa);
                                        taxOwner.text =
                                            npwp.data[index].npwpName;
                                        taxAddress.text =
                                            npwp.data[index].npwpAddr;
                                        email.text = npwp.data[index].npwpEmail;
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  maskFormatterNPWP.maskText(
                                                      npwp.data[index].npwpNo),
                                                  style: bold.copyWith(
                                                      color: widget.darkMode
                                                          ? whiteColorDarkMode
                                                          : blackSecondary1,
                                                      fontSize: 10),
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2.2,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5),
                                                    child: Text(
                                                      npwp.data[index].npwpAddr,
                                                      style: reguler.copyWith(
                                                          color: widget.darkMode
                                                              ? whiteColorDarkMode
                                                              : blackSecondary3,
                                                          fontSize: 10),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  npwp.data[index].npwpName,
                                                  style: bold.copyWith(
                                                      color: widget.darkMode
                                                          ? whiteColorDarkMode
                                                          : blackSecondary1,
                                                      fontSize: 10),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: Row(
                                                    children: [
                                                      // Icon(
                                                      //   Icons.whatsapp_outlined,
                                                      //   size: 12,
                                                      //   color: blackSecondary3,
                                                      // ),
                                                      Text(
                                                          maskFormatterPhone.maskText(npwp
                                                                  .data[index]
                                                                  .npwpWa
                                                                  .startsWith(
                                                                      '0')
                                                              ? npwp.data[index]
                                                                  .npwpWa
                                                                  .replaceFirst(
                                                                      '0', ' ')
                                                              : npwp.data[index]
                                                                  .npwpWa),
                                                          style: reguler.copyWith(
                                                              color: widget
                                                                      .darkMode
                                                                  ? whiteColorDarkMode
                                                                  : blackSecondary3,
                                                              fontSize: 10)),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Divider(
                                            height: 1,
                                            thickness: 0.5,
                                            indent: 0,
                                            endIndent: 0,
                                            color: greyColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Text(AppLocalizations.of(context)!.taxOwner,
                                  style: bold.copyWith(
                                    fontSize: 14,
                                    color: blackPrimary,
                                  )),
                              const SizedBox(
                                height: 8,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.1,
                                child: TextFormField(
                                  controller: taxOwner,
                                  style: reguler.copyWith(
                                    fontSize: 13,
                                    color: blackPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor:
                                        widget.darkMode ? whiteCardColor : null,
                                    hintText: AppLocalizations.of(context)!
                                        .insertTaxOwner,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: blackPrimary,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 3,
                                        color: blueGradient,
                                      ),
                                    ),
                                    hintStyle: reguler.copyWith(
                                      fontSize: 12,
                                      color: blackSecondary3,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 40,
                              ),
                              Text(AppLocalizations.of(context)!.taxAddress,
                                  style: bold.copyWith(
                                    fontSize: 14,
                                    color: blackPrimary,
                                  )),
                              const SizedBox(
                                height: 8,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.1,
                                child: TextFormField(
                                  controller: taxAddress,
                                  style: reguler.copyWith(
                                    fontSize: 13,
                                    color: blackPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor:
                                        widget.darkMode ? whiteCardColor : null,
                                    hintText: AppLocalizations.of(context)!
                                        .insertTaxAddress,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: blackPrimary,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 3,
                                        color: blueGradient,
                                      ),
                                    ),
                                    hintStyle: reguler.copyWith(
                                      fontSize: 12,
                                      color: blackSecondary3,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 40,
                              ),
                              Text(AppLocalizations.of(context)!.waNumber,
                                  style: bold.copyWith(
                                    fontSize: 14,
                                    color: blackPrimary,
                                  )),
                              const SizedBox(
                                height: 8,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.1,
                                child: TextFormField(
                                  controller: whatsAppNum,
                                  style: reguler.copyWith(
                                    fontSize: 13,
                                    color: blackPrimary,
                                  ),
                                  inputFormatters: [maskFormatterPhone],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor:
                                        widget.darkMode ? whiteCardColor : null,
                                    counterText:
                                        '${AppLocalizations.of(context)!.example} : +62 8122-xxxx-xxx',
                                    hintText: AppLocalizations.of(context)!
                                        .insertWANumber,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: blackPrimary,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 3,
                                        color: blueGradient,
                                      ),
                                    ),
                                    hintStyle: reguler.copyWith(
                                      fontSize: 12,
                                      color: blackSecondary3,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 40,
                              ),
                              Text(AppLocalizations.of(context)!.email,
                                  style: bold.copyWith(
                                    fontSize: 14,
                                    color: blackPrimary,
                                  )),
                              const SizedBox(
                                height: 8,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.1,
                                child: TextFormField(
                                  controller: email,
                                  style: reguler.copyWith(
                                    fontSize: 13,
                                    color: blackPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor:
                                        widget.darkMode ? whiteCardColor : null,
                                    hintText: AppLocalizations.of(context)!
                                        .insertEmail,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: blackPrimary,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 3,
                                        color: blueGradient,
                                      ),
                                    ),
                                    hintStyle: reguler.copyWith(
                                      fontSize: 12,
                                      color: blackSecondary3,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            }
            return const Center(
              child: Text('Loading...'),
            );
          }),
      bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          width: double.infinity,
          height: 80.0,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Divider(
                  height: 2,
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                  color: greyColor,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigator.pop(context);
                          Navigator.of(context).pop();
                          // Navigator.of(context).pop();
                          // _doSubmit(_portalProfileModel.id);
                          // if (_formEdit.currentState.validate()) {
                          //   _doSubmit(_portalProfileModel.id);
                          // }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: whiteColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(color: blueGradient, width: 1),
                            ),
                            textStyle: const TextStyle(
                              color: Colors.white,
                            )),
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: new BorderRadius.circular(10.0),
                        //   side: BorderSide(
                        //     color: Theme.of(context).accentColor,
                        //   ),
                        // ),
                        // color: Theme.of(context).accentColor,
                        // textColor: Colors.white,
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: TextStyle(
                            color: blueGradient,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          print(
                              'npwp: ${maskFormatterNPWP.unmaskText(taxNumber.text)} || owner: ${taxOwner.text} || address: ${taxAddress.text} || whatsapp: 0${maskFormatterPhone.unmaskText(whatsAppNum.text)} || email: ${email.text}');
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentMethod(
                                totalUnit: widget.totalUnit,
                                totalPrice: widget.totalPrice,
                                npwp: 1,
                                idCart: widget.idCart,
                                npwpNo: maskFormatterNPWP
                                    .unmaskText(taxNumber.text),
                                npwpName: taxOwner.text,
                                npwpAddress: taxAddress.text,
                                npwpEmail: email.text,
                                npwpWa: maskFormatterPhone
                                    .unmaskText(whatsAppNum.text),
                                cart: widget.cart,
                                darkMode: widget.darkMode,
                              ),
                            ),
                          );
                          // editNPWP(
                          //     local.Username,
                          //     maskFormatterNPWP.unmaskText(taxNumber.text),
                          //     taxOwner.text,
                          //     taxAddress.text,
                          //     '0${maskFormatterPhone.unmaskText(whatsAppNum.text)}',
                          //     email.text);
                          // _doSubmit(_portalProfileModel.id);
                          // if (_formEdit.currentState.validate()) {
                          //   _doSubmit(_portalProfileModel.id);
                          // }
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            backgroundColor: bluePrimary,
                            textStyle: const TextStyle(
                              color: Colors.white,
                            )),
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: new BorderRadius.circular(10.0),
                        //   side: BorderSide(
                        //     color: Theme.of(context).accentColor,
                        //   ),
                        // ),
                        // color: Theme.of(context).accentColor,
                        // textColor: Colors.white,
                        child: Text(
                          AppLocalizations.of(context)!.useTaxInvoice,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
