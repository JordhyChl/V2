// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, file_names, deprecated_member_use, avoid_print, constant_identifier_names

import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpsid/common.dart';
import 'package:gpsid/pages/checkout.page.dart';
import 'package:gpsid/service/api.dart';
import 'package:gpsid/theme.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditCardPayment extends StatefulWidget {
  final int totalUnit;
  final int totalPrice;
  final bool darkMode;

  const CreditCardPayment({
    Key? key,
    required this.totalUnit,
    required this.totalPrice,
    required this.darkMode,
  }) : super(key: key);

  @override
  State<CreditCardPayment> createState() => _CreditCardPaymentState();
}

enum CardType {
  Master,
  Visa,
  Verve,
  Discover,
  AmericanExpress,
  DinersClub,
  Jcb,
  Others,
  Invalid
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('-'); // Add double spaces.
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class CardMonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != newText.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class CardUtils {
  static CardType getCardTypeFrmNumber(String input) {
    CardType cardType;
    if (input.startsWith(RegExp(
        r'((5[1-5])|(222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720))'))) {
      cardType = CardType.Master;
    } else if (input.startsWith(RegExp(r'[4]'))) {
      cardType = CardType.Visa;
    } else if (input.startsWith(RegExp(r'((506(0|1))|(507(8|9))|(6500))'))) {
      cardType = CardType.Verve;
    } else if (input.startsWith(RegExp(r'((34)|(37))'))) {
      cardType = CardType.AmericanExpress;
    } else if (input.startsWith(RegExp(r'((6[45])|(6011))'))) {
      cardType = CardType.Discover;
    } else if (input.startsWith(RegExp(r'((30[0-5])|(3[89])|(36)|(3095))'))) {
      cardType = CardType.DinersClub;
    } else if (input.startsWith(RegExp(r'(352[89]|35[3-8][0-9])'))) {
      cardType = CardType.Jcb;
    } else if (input.length <= 8) {
      cardType = CardType.Others;
    } else {
      cardType = CardType.Invalid;
    }
    return cardType;
  }

  static Widget? getCardIcon(CardType? cardType) {
    String img = "";
    Icon? icon;
    switch (cardType) {
      case CardType.Master:
        img = 'mastercard.png';
        break;
      case CardType.Visa:
        img = 'visa.png';
        break;
      case CardType.Verve:
        icon = const Icon(
          Icons.credit_card,
          size: 24.0,
          color: Color(0xFFB8B5C3),
        );
        break;
      case CardType.AmericanExpress:
        img = 'american-express.png';
        break;
      case CardType.Discover:
        img = 'discover.png';
        break;
      case CardType.DinersClub:
        icon = const Icon(
          Icons.credit_card,
          size: 24.0,
          color: Color(0xFFB8B5C3),
        );
        break;
      case CardType.Jcb:
        img = 'jcb.png';
        break;
      case CardType.Others:
        icon = const Icon(
          Icons.credit_card,
          size: 24.0,
          color: Color(0xFFB8B5C3),
        );
        break;
      default:
        icon = const Icon(
          Icons.warning,
          size: 24.0,
          color: Color(0xFFB8B5C3),
        );
        break;
    }
    Widget? widget;
    if (img.isNotEmpty) {
      widget = Image.asset(
        'assets/credit_card_logo/$img',
        width: 40.0,
      );
    } else {
      widget = icon;
    }
    return widget;
  }

  static String getCleanedNumber(String text) {
    RegExp regExp = RegExp(r"[^0-9]");
    return text.replaceAll(regExp, '');
  }

  static String? validateCardNum(String? input) {
    if (input == null || input.isEmpty) {
      return "This field is required";
    }
    input = getCleanedNumber(input);
    if (input.length < 8) {
      return "Card is invalid";
    }
    int sum = 0;
    int length = input.length;
    for (var i = 0; i < length; i++) {
      // get digits in reverse order
      int digit = int.parse(input[length - i - 1]);
      // every 2nd number multiply with 2
      if (i % 2 == 1) {
        digit *= 2;
      }
      sum += digit > 9 ? (digit - 9) : digit;
    }
    if (sum % 10 == 0) {
      return null;
    }
    return "Card is invalid";
  }

  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    if (value.length < 3 || value.length > 4) {
      return "CVV is invalid";
    }
    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    int year;
    int month;
    if (value.contains(RegExp(r'(/)'))) {
      var split = value.split(RegExp(r'(/)'));
      month = int.parse(split[0]);
      year = int.parse(split[1]);
    } else {
      month = int.parse(value.substring(0, (value.length)));
      year = -1; // Lets use an invalid year intentionally
    }
    if ((month < 1) || (month > 12)) {
      // A valid month is between 1 (January) and 12 (December)
      return 'Expiry month is invalid';
    }
    var fourDigitsYear = convertYearTo4Digits(year);
    if ((fourDigitsYear < 1) || (fourDigitsYear > 2099)) {
      // We are assuming a valid should be between 1 and 2099.
      // Note that, it's valid doesn't mean that it has not expired.
      return 'Expiry year is invalid';
    }
    if (!hasDateExpired(month, year)) {
      return "Card has expired";
    }
    return null;
  }

  static int convertYearTo4Digits(int year) {
    if (year < 100 && year >= 0) {
      var now = DateTime.now();
      String currentYear = now.year.toString();
      String prefix = currentYear.substring(0, currentYear.length - 2);
      year = int.parse('$prefix${year.toString().padLeft(2, '0')}');
    }
    return year;
  }

  static bool hasDateExpired(int month, int year) {
    return isNotExpired(year, month);
  }

  static bool isNotExpired(int year, int month) {
    // It has not expired if both the year and date has not passed
    return !hasYearPassed(year) && !hasMonthPassed(year, month);
  }

  static List<int> getExpiryDate(String value) {
    var split = value.split(RegExp(r'(/)'));
    return [int.parse(split[0]), int.parse(split[1])];
  }

  static bool hasMonthPassed(int year, int month) {
    var now = DateTime.now();
    // The month has passed if:
    // 1. The year is in the past. In that case, we just assume that the month
    // has passed
    // 2. Card's month (plus another month) is more than current month.
    return hasYearPassed(year) ||
        convertYearTo4Digits(year) == now.year && (month < now.month + 1);
  }

  static bool hasYearPassed(int year) {
    int fourDigitsYear = convertYearTo4Digits(year);
    var now = DateTime.now();
    // The year has passed if the year we are currently is more than card's
    // year
    return fourDigitsYear < now.year;
  }
}

class _CreditCardPaymentState extends State<CreditCardPayment> {
  final _formCheckout = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvNumberController = TextEditingController();
  final TextEditingController _expDateCardController = TextEditingController();
  final TextEditingController _paymentMethodController =
      TextEditingController();

  late List<Map<String, dynamic>> _installments;
  late Map<String, dynamic> _selectedInstallments;
  bool _isRecurring = false;
  bool isCheck = false;
  CardType cardType = CardType.Invalid;

  @override
  void initState() {
    super.initState();
    _installments = [];
    _selectedInstallments = {};
    _cardNumberController.addListener(
      () {
        getCardTypeFrmNumber();
      },
    );
    setPaymentMethod();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cvvNumberController.dispose();
    _expDateCardController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  void getCardTypeFrmNumber() {
    if (_cardNumberController.text.length <= 6) {
      String input = CardUtils.getCleanedNumber(_cardNumberController.text);
      CardType type = CardUtils.getCardTypeFrmNumber(input);
      if (type != cardType) {
        setState(() {
          cardType = type;
        });
      }
    }
  }

  _doProcess() async {
    Map<String, dynamic> _paramJSON = {
      'cardNumber': _cardNumberController.text.replaceAll('-', ''),
      'cardExpDateMM': _expDateCardController.text.substring(0, 2),
      'cardExpDateYY': _expDateCardController.text
          .substring(_expDateCardController.text.length - 2),
      'cardCVV': _cvvNumberController.text,
      'installment': json.encode(_selectedInstallments),
      'isRecurring': _isRecurring,
      'trxAmt': widget.totalPrice,
    };

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CheckOutPage(
          paramJSON: _paramJSON,
          darkMode: widget.darkMode,
        ),
      ),
    );
  }

  doSelectPaymentMethod(Map<String, dynamic> _installmentData) {
    setState(() {
      _selectedInstallments = _installmentData;
      _paymentMethodController.text = _selectedInstallments['desc'];
      if (_installmentData['count'] > 1) {
        _isRecurring = false;
      }
    });
  }

  setPaymentMethod() {
    _selectedInstallments = {
      'isCheck': true,
      'count': 1,
      'interval': 'month',
      'desc': 'Full Payment ${NumberFormat.currency(
        locale: 'id',
        decimalDigits: 0,
        symbol: 'Rp. ',
      ).format(widget.totalPrice)}',
      'detail': '{}',
    };
    _paymentMethodController.text = _selectedInstallments['desc'];
    setState(() {});
  }

  getInstallment() async {
    await Dialogs().loadingDialog(context);
    _installments.clear();
    Map<String, dynamic> _installmentData = {
      'isCheck': true,
      'count': 1,
      'interval': 'month',
      'desc': 'Full Payment ${NumberFormat.currency(
        locale: 'id',
        decimalDigits: 0,
        symbol: 'Rp. ',
      ).format(widget.totalPrice)}',
    };
    _installments.add(_installmentData);

    Map<String, dynamic> _cardInfo = {
      'cardNumber': _cardNumberController.text.replaceAll('-', ''),
      'cardExpDateMM': _expDateCardController.text.substring(0, 2),
      'cardExpDateYY': _expDateCardController.text
          .substring(_expDateCardController.text.length - 2),
      'cardCVV': _cvvNumberController.text,
    };
    final _results = await APIService().getInstallment(_cardInfo);
    await Dialogs().hideLoaderDialog(context);
    if (_results['status']) {
      final _installmentDatas = _results['data']['installments'];
      for (var _installment in _installmentDatas) {
        Map<String, dynamic> _installmentData = {
          'isCheck': false,
          'count': _installment['count'],
          'interval': _installment['interval'],
          'desc':
              "${_installment['description'].split(',')[0]}, ${_installment['count']} x ${NumberFormat.currency(
            locale: 'id',
            decimalDigits: 0,
            symbol: 'Rp. ',
          ).format(_installment['installment_amount'])}",
        };
        _installments.add(_installmentData);
      }

      showModalBottomSheet(
        isDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: double.infinity,
                height: 80 * double.parse(_installments.length.toString()),
                child: ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: _installments.length,
                  itemBuilder: (BuildContext context, int idx) {
                    return SizedBox(
                      height: 50,
                      child: InkWell(
                        onTap: () {
                          doSelectPaymentMethod(_installments[idx]);
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text(_installments[idx]['desc']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                ),
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formCheckout,
      child: Scaffold(
        backgroundColor: whiteColor,
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
            color: widget.darkMode ? whiteColorDarkMode : whiteColor,
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.creditCard,
            style: bold.copyWith(
              fontSize: 16,
              color: widget.darkMode ? whiteColorDarkMode : whiteColor,
            ),
          ),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height * (60 / 100),
          child: SingleChildScrollView(
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
                        Text(AppLocalizations.of(context)!.cardNumber,
                            style: bold.copyWith(
                              fontSize: 14,
                              color: blackPrimary,
                            )),
                        const SizedBox(
                          height: 8,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * (95 / 100),
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(19),
                              CardNumberInputFormatter(),
                            ],
                            keyboardType: TextInputType.number,
                            controller: _cardNumberController,
                            maxLength: 19,
                            style: reguler.copyWith(
                              fontSize: 13,
                              color: blackPrimary,
                            ),
                            validator: CardUtils.validateCardNum,
                            decoration: InputDecoration(
                              suffix: CardUtils.getCardIcon(cardType),
                              counterText: 'Ex: 4811-1111-1111-1114',
                              counterStyle:
                                  reguler.copyWith(color: blackPrimary),
                              filled: true,
                              fillColor:
                                  widget.darkMode ? whiteCardColor : whiteColor,
                              hintText: AppLocalizations.of(context)!
                                  .insertCardNumber,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Exp Date',
                              style: bold.copyWith(
                                fontSize: 14,
                                color: blackPrimary,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  (45 / 100),
                              child: TextFormField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                  CardMonthInputFormatter()
                                ],
                                maxLength: 5,
                                controller: _expDateCardController,
                                validator: CardUtils.validateDate,
                                style: reguler.copyWith(
                                  fontSize: 13,
                                  color: blackPrimary,
                                ),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  fillColor: widget.darkMode
                                      ? whiteCardColor
                                      : whiteColor,
                                  counterText: 'Ex: 01/23',
                                  counterStyle:
                                      reguler.copyWith(color: blackPrimary),
                                  filled: true,
                                  hintText: 'MM/YY',
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
                        const SizedBox(
                          width: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Text('CVV / CVN',
                                style: bold.copyWith(
                                  fontSize: 14,
                                  color: blackPrimary,
                                )),
                            const SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  (45 / 100),
                              child: TextFormField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                maxLength: 3,
                                keyboardType: TextInputType.number,
                                controller: _cvvNumberController,
                                validator: CardUtils.validateCVV,
                                obscureText: true,
                                style: reguler.copyWith(
                                  fontSize: 13,
                                  color: blackPrimary,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  hintText: '123',
                                  fillColor: widget.darkMode
                                      ? whiteCardColor
                                      : whiteColor,
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
                                  counterText: 'Ex: 123',
                                  counterStyle:
                                      reguler.copyWith(color: blackPrimary),
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
                        Text(AppLocalizations.of(context)!.paymentMethod,
                            style: bold.copyWith(
                              fontSize: 14,
                              color: blackPrimary,
                            )),
                        const SizedBox(
                          height: 8,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * (95 / 100),
                          child: TextFormField(
                            readOnly: true,
                            controller: _paymentMethodController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter payment method';
                              }
                              return null;
                            },
                            style: reguler.copyWith(
                              fontSize: 13,
                              color: blackPrimary,
                            ),
                            onTap: () {
                              if (_formCheckout.currentState!.validate()) {
                                getInstallment();
                              }
                            },
                            decoration: InputDecoration(
                              filled: true,
                              hintText: '',
                              fillColor:
                                  widget.darkMode ? whiteCardColor : whiteColor,
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
                Row(
                  children: [
                    Checkbox(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      value: _isRecurring,
                      side: BorderSide(
                          color: widget.darkMode
                              ? whiteColorDarkMode
                              : blackPrimary),
                      onChanged: (value) {
                        setPaymentMethod();
                        !_isRecurring
                            ? setState(() {
                                _isRecurring = true;
                              })
                            : setState(() {
                                _isRecurring = false;
                              });
                      },
                    ),
                    Text('Recurring',
                        style: bold.copyWith(fontSize: 12, color: blackPrimary))
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * (95 / 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.recurringTC,
                          style: reguler.copyWith(
                              fontSize: 12, color: blackPrimary)),
                      const SizedBox(
                        height: 10,
                      ),
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text:
                                AppLocalizations.of(context)!.termsAndCondition,
                            style: TextStyle(
                                color: blueGradient,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                String url = "https://pulsa2.gps.id/term";
                                var urllaunchable = await canLaunch(
                                    url); //canLaunch is from url_launcher package
                                if (urllaunchable) {
                                  await launch(
                                      url); //launch is from url_launcher package to launch URL
                                } else {
                                  print("URL can't be launched.");
                                }
                              })
                      ])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
            ),
            width: double.infinity,
            height: 120.0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.totalUnit,
                              style: reguler.copyWith(
                                  fontSize: 12, color: blackPrimary)),
                          Text(
                            '${widget.totalUnit} ${AppLocalizations.of(context)!.unitCart}',
                            style: bold.copyWith(
                                fontSize: 14, color: blackPrimary),
                          ),
                        ],
                      ),
                      // const SizedBox(
                      //   width: 160,
                      // ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * (75 / 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(AppLocalizations.of(context)!.totalPrice,
                                style: reguler.copyWith(
                                    fontSize: 12, color: blackPrimary)),
                            Text(
                              NumberFormat.currency(
                                locale: 'id',
                                decimalDigits: 0,
                                symbol: 'Rp. ',
                              ).format(widget.totalPrice),
                              style: bold.copyWith(
                                  fontSize: 14, color: blackPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Divider(
                    height: 2,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                    color: greyColor,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // SizedBox(
                      //   width: MediaQuery.of(context).size.width * (40 / 100),
                      //   child: ElevatedButton(
                      //     onPressed: () {},
                      //     style: ElevatedButton.styleFrom(
                      //         backgroundColor: whiteColor,
                      //         shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(10.0),
                      //           side: BorderSide(color: blueGradient, width: 1),
                      //         ),
                      //         textStyle: const TextStyle(
                      //           color: Colors.white,
                      //         )),
                      //     child: Text(
                      //       AppLocalizations.of(context)!.orderDetail,
                      //       style: TextStyle(
                      //         color: blueGradient,
                      //         fontSize: 14,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(
                      //   width: 10,
                      // ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * (80 / 100),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formCheckout.currentState!.validate()) {
                              _doProcess();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(
                                  color: greenPrimary,
                                ),
                              ),
                              backgroundColor: greenPrimary,
                              // disabledBackgroundColor: greyColor,
                              // backgroundColor: Theme.of(context).accentColor,
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
                            AppLocalizations.of(context)!.process,
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
      ),
    );
  }
}
