import 'dart:math';

import 'package:dynamic_dcf/services/api_calls.dart';
import 'package:flutter/material.dart';

class NewDCF extends StatefulWidget {
  String passedSymbol;

  NewDCF({Key key, @required this.passedSymbol}) : super(key: key);
  @override
  _NewDCFState createState() => _NewDCFState(passedSymbol: passedSymbol);
}

class _NewDCFState extends State<NewDCF> {
  double earningsLastYear = 0;
  List<double> earnings = List<double>(11);
  List<double> presentValueEarnings = List<double>(11);
  double presentValue = 0;
  int firstPeriod = 5;
  int secondPeriod = 5;
  double discountRate = 0.8;
  double terminalMultiple = 18;
  double growthRateP1 = 0.15;
  double growthRateP2 = 0.10;
  double safetyMargin = 0.10;
  Api_Calls ApiCalls = Api_Calls();
  String passedSymbol;
  _NewDCFState({this.passedSymbol});
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => {
          ApiCalls.getEPS(passedSymbol).then((eps) {
            print("eps is $eps");
            setState(() {
              earningsLastYear = 6.67;
              updatePresentValue();
            });
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(passedSymbol),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Text('fair value'),
                Text(
                  presentValue.toString(),
                  style: TextStyle(fontSize: 50),
                )
              ],
            ),
          ),
          Center(
            child: Card(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Text('Growth for years 1-5'),
                    Slider(
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
    //print(earnings);
    /////
    presentValueEarnings[0] = earnings[0] * (pow(1 + discountRate, -1));

    for (int i = 1; i < 11; i++) {
      var year = i + 1;
      presentValueEarnings[i] = earnings[i] * (pow(1 + discountRate, -year));
    }
    print(presentValueEarnings);
    double sum = 0;
    presentValueEarnings.forEach((num e) {
      sum += e;
    });
    sum = sum - (sum * safetyMargin);
    setState(() {
      presentValue = double.parse((sum).toStringAsFixed(2));
    });
  }
}
