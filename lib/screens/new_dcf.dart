import 'dart:math';

import 'package:dynamic_dcf/models/portfolio.dart';
import 'package:dynamic_dcf/services/api_calls.dart';
import 'package:dynamic_dcf/services/database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewDCF extends StatefulWidget {
  String passedSymbol;
  String userId;
  Portfolio portfolio;
  String documentId;
  //Function getPortfolio;
  NewDCF(
      {Key key,
      @required this.passedSymbol,
      this.userId,
      this.portfolio,
      this.documentId})
      : super(key: key);
  @override
  _NewDCFState createState() => _NewDCFState(passedSymbol: passedSymbol);
}

class _NewDCFState extends State<NewDCF> {
  double earningsLastYear = 0;
  String name;
  List<double> earnings = List<double>(11);
  List<double> presentValueEarnings = List<double>(11);
  double presentValue = 0;
  int firstPeriod = 5;
  int secondPeriod = 5;
  double discountRate = 0.2;
  double terminalMultiple = 18;
  double growthRateP1 = 0.15;
  double growthRateP2 = 0.10;
  double safetyMargin = 0.10;
  Api_Calls ApiCalls = Api_Calls();
  String passedSymbol;
  String currentPrice = '-';

  Future<void> _neverSatisfied(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sorry'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
                Text('Try again with another stock!'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Return'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _NewDCFState({this.passedSymbol});
  void initState() {
    super.initState();

    if (widget.portfolio != null) {
      discountRate = widget.portfolio.discountRate;
      growthRateP1 = widget.portfolio.growthRateP1;
      growthRateP2 = widget.portfolio.growthRateP2;
      safetyMargin = widget.portfolio.safetyMargin;
      presentValue = widget.portfolio.presentValue;
      terminalMultiple = widget.portfolio.terminalMultiple;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => {
          ApiCalls.getEPS(passedSymbol).then((eps) {
            print("eps is $eps");
            if (eps == null) {
              _neverSatisfied("This stock is not supported").then((nullValue) {
                Navigator.of(context).pop();
              });
            } else if (eps < 0) {
              print("sorry no negative eps");
              _neverSatisfied(
                      'Currenty this model only works for stocks with positive earnings')
                  .then((nullValue) {
                Navigator.of(context).pop();
              });
            } else {
              setState(() {
                earningsLastYear = eps;
                updatePresentValue();
              });
            }
          })
        });
    getPrice(passedSymbol);
  }

  SliderThemeData sliderData() {
    return SliderThemeData(
        activeTickMarkColor: Theme.of(context).accentColor,
        trackHeight: 5,
        inactiveTrackColor: Color(0xFFF1D97E),
        valueIndicatorTextStyle: TextStyle(color: Colors.black),
        activeTrackColor: Theme.of(context).accentColor,
        thumbColor: Theme.of(context).accentColor,
        valueIndicatorColor: Theme.of(context).accentColor,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0));
  }

  Row sliderTitle(String title, String body) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Text(
        title,
        style: TextStyle(
            fontSize: 25, letterSpacing: 2, fontWeight: FontWeight.w600),
      ),
      SizedBox(
        width: 7,
      ),
      GestureDetector(
        onTap: () => _showInfo(title, body),
        child: Icon(
          Icons.info,
          color: Colors.grey,
          size: 25.0,
        ),
      ),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    //widget.getPortfolio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3DF95),
      appBar: AppBar(
        title: Text(passedSymbol),
        actions: <Widget>[
          widget.portfolio != null
              ? new FlatButton(
                  child: new Text('Delete',
                      style: new TextStyle(
                        fontSize: 17.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
                  onPressed: () {
                    DatabaseService().deletePortfolio(widget.documentId);
                    Navigator.of(context).pop();
                  })
              : Text(''),
          widget.portfolio != null
              ? new FlatButton(
                  child: new Text('Update',
                      style: new TextStyle(
                        fontSize: 17.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
                  onPressed: () {
                    Portfolio portfolio = Portfolio(
                      userId: widget.userId,
                      symbol: passedSymbol,
                      discountRate: discountRate,
                      terminalMultiple: terminalMultiple,
                      growthRateP1: growthRateP1,
                      growthRateP2: growthRateP2,
                      safetyMargin: safetyMargin,
                      presentValue: presentValue,
                      earningsLastYear: earningsLastYear,
                    );
                    DatabaseService().updateData(portfolio, widget.documentId);
                    Navigator.of(context).pop();
                  })
              : FlatButton(
                  child: new Text('Save',
                      style: new TextStyle(
                        fontSize: 19.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
                  onPressed: () {
                    Portfolio portfolio = Portfolio(
                      userId: widget.userId,
                      symbol: passedSymbol,
                      discountRate: discountRate,
                      terminalMultiple: terminalMultiple,
                      growthRateP1: growthRateP1,
                      growthRateP2: growthRateP2,
                      safetyMargin: safetyMargin,
                      presentValue: presentValue,
                      earningsLastYear: earningsLastYear,
                    );
                    DatabaseService().addPortfolio(portfolio);
                    Navigator.of(context).pop();
                  },
                ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => _showInfo('Fair Value',
                          'Intrinsic value of stock calculated by Discounted Cash Flow Model based on estimations made below.'),
                      child: Row(children: <Widget>[
                        Text('Fair Value'),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.info,
                          size: 18,
                          color: Colors.grey,
                        )
                      ]),
                    ),
                    Text(
                      '\$' + presentValue.toString(),
                      style: TextStyle(fontSize: 31),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Current Price'),
                    Text(
                      '\$' + currentPrice,
                      style: TextStyle(fontSize: 31),
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              //width: MediaQuery.of(context).size.width * 0.95,
              //height: MediaQuery.of(context).size.height * 0.5,
              //color: Colors.grey,
              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
              padding: EdgeInsets.fromLTRB(0, 20, 2, 0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60.0),
                      topRight: Radius.circular(60.0))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  sliderTitle('Growth for Years 1-5',
                      'Estimate earnings growth for next 5 years.\n\nNote:\nEstimate lower growth to be conservative'),
                  SliderTheme(
                    data: sliderData(),
                    child: Slider(
                      // inactiveColor:Color(0xFFF1D97E), //Theme.of(context).primaryColor,
                      //activeColor: Theme.of(context).accentColor,
                      value: growthRateP1 * 100,
                      min: 1.0,
                      max: 100.0,
                      divisions: 100,
                      label:
                          '${double.parse((growthRateP1 * 100).toStringAsFixed(2))}%',
                      onChanged: (double growthOne) {
                        setState(() {
                          growthRateP1 = growthOne.round().toDouble() / 100;
                        });
                        updatePresentValue();
                      },
                    ),
                  ),
                  sliderTitle('Growth for Years 5-10',
                      'Estimate earnings growth for years 5-10.\n\nNote:\nEstimate lower growth to be conservative'),
                  SliderTheme(
                    data: sliderData(),
                    child: Slider(
                      value: growthRateP2 * 100,
                      min: 1.0,
                      max: 100.0,
                      divisions: 100,
                      label:
                          '${double.parse((growthRateP2 * 100).toStringAsFixed(2))}%',
                      onChanged: (double growthTwo) {
                        setState(() {
                          growthRateP2 = growthTwo.round().toDouble() / 100;
                        });
                        updatePresentValue();
                      },
                    ),
                  ),
                  sliderTitle('Discount Rate',
                      'Your required rate of return. \n\nNote:\nChoosing a low rate of return will inflate the fair value'),
                  SliderTheme(
                    data: sliderData(),
                    child: Slider(
                      value: discountRate * 100,
                      min: 1.0,
                      max: 100.0,
                      divisions: 100,
                      label:
                          '${double.parse((discountRate * 100).toStringAsFixed(2))}%',
                      onChanged: (double discount) {
                        setState(() {
                          discountRate = discount.round().toDouble() / 100;
                        });
                        updatePresentValue();
                      },
                    ),
                  ),
                  sliderTitle('Terminal Multiple',
                      'The terminal multiple is typically calculated by applying an appropriate multiple (EV/EBITDA, EV/EBIT, etc.) to the relevant statistic projected for the last projected year. \n\nNote:\nUltimately it will be an estimate of the P/E ratio of the company in 11 years. To be conservative you will likely want to use a ratio that is lower than whatever the stock\'s P/E ratio is now.\n\nIt helps to look at the average P/E ratio of the stock\'s industry to make better predictions.'),
                  SliderTheme(
                    data: sliderData(),
                    child: Slider(
                      value: terminalMultiple,
                      min: 1.0,
                      max: 200.0,
                      divisions: 100,
                      label:
                          '${double.parse((terminalMultiple).toStringAsFixed(2))}',
                      onChanged: (double terminal) {
                        setState(() {
                          terminalMultiple = terminal;
                        });
                        updatePresentValue();
                      },
                    ),
                  ),
                  sliderTitle("Margin of Safety",
                      'Help you calculate fair price that is below it\'s intrinsic value \n\n\'We insist on a margin of safety in our purchase price.  If we calculate the value of a common stock to be only slightly higher than it\'s price, we\'re not interested in buying.  We believe this margin of safety principle, emphasised by Ben Graham, to be the cornerstone of investment success\' \n-Warren Buffett'),
                  SliderTheme(
                    data: sliderData(),
                    child: Slider(
                      value: safetyMargin * 100,
                      min: 1.0,
                      max: 50.0,
                      divisions: 50,
                      label:
                          '${double.parse((safetyMargin * 100).toStringAsFixed(2))}%',
                      onChanged: (double margin) {
                        setState(() {
                          safetyMargin = margin / 100;
                        });
                        updatePresentValue();
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void updatePresentValue() {
    //print("earnings inside dcf $earningsLastYear");
    earnings[0] = earningsLastYear * growthRateP1 + earningsLastYear;
    for (int i = 1; i < 10; i++) {
      if (i < 5) {
        earnings[i] = earnings[i - 1] * growthRateP1 + earnings[i - 1];
      } else {
        earnings[i] = earnings[i - 1] * growthRateP2 + earnings[i - 1];
      }
    }
    earnings[10] = earnings[9] * terminalMultiple;

    presentValueEarnings[0] = earnings[0] * (pow(1 + discountRate, -1));

    for (int i = 1; i < 11; i++) {
      var year = i + 1;
      presentValueEarnings[i] = earnings[i] * (pow(1 + discountRate, -year));
    }
    //print(presentValueEarnings);
    double sum = 0;
    presentValueEarnings.forEach((num e) {
      sum += e;
    });
    sum = sum - (sum * safetyMargin);
    setState(() {
      presentValue = double.parse((sum).toStringAsFixed(2));
    });
  }

  void getPrice(String passedSymbol) {
    Api_Calls().getPrice(',' + passedSymbol).then((s) {
      //print("getting price in dcf $s");
      setState(() {
        currentPrice = s['price'].toStringAsFixed(2);
      });

      //eturn 'what';
    });
  }

  Future<void> _showInfo(String title, String body) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(body),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Return'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
