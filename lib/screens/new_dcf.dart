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

  Future<void> _neverSatisfied() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sorry'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Currenty this model only works for stocks with positive earnings'),
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
            if (eps < 0) {
              print("sorry no negative eps");
              _neverSatisfied().then((nullValue) {
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

  @override
  void dispose() {
    super.dispose();
    //widget.getPortfolio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(passedSymbol),
        actions: <Widget>[
          widget.portfolio != null
              ? new FlatButton(
                  child: new Text('Delete',
                      style:
                          new TextStyle(fontSize: 17.0, color: Colors.white)),
                  onPressed: () {
                    DatabaseService().deletePortfolio(widget.documentId);
                    Navigator.of(context).pop();
                  })
              : Text(''),
          widget.portfolio != null
              ? new FlatButton(
                  child: new Text('Update',
                      style:
                          new TextStyle(fontSize: 17.0, color: Colors.white)),
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
              : IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'Show Snackbar',
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
            child: Row(
              children: <Widget>[
                Text('fair value'),
                Text(
                  presentValue.toString(),
                  style: TextStyle(fontSize: 40),
                ),
                Text('Current Price'),
                Text(
                  currentPrice,
                  style: TextStyle(fontSize: 30),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              //width: MediaQuery.of(context).size.width * 0.95,
              //height: MediaQuery.of(context).size.height * 0.5,
              //color: Colors.grey,
              padding: EdgeInsets.fromLTRB(0, 80, 2, 0),
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60.0),
                      topRight: Radius.circular(60.0))),
              child: Column(
                children: <Widget>[
                  Text('Growth for years 1-5'),
                  SliderTheme(
                    data: SliderThemeData(
                        trackHeight: 5,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 12.0)),
                    child: Slider(
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
                  Text('Growth for years 5-10'),
                  Slider(
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
                  Text('Discount Rate'),
                  Slider(
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
                  Text('Terminal Multiple'),
                  Slider(
                    value: terminalMultiple,
                    min: 1.0,
                    max: 300.0,
                    divisions: 150,
                    label:
                        '${double.parse((terminalMultiple).toStringAsFixed(2))}',
                    onChanged: (double terminal) {
                      setState(() {
                        terminalMultiple = terminal;
                      });
                      updatePresentValue();
                    },
                  ),
                  Text('Margin of Safety'),
                  Slider(
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
}
