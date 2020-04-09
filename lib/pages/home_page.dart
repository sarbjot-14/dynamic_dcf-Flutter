import 'package:dynamic_dcf/models/portfolio.dart';
import 'package:dynamic_dcf/models/stock.dart';
import 'package:dynamic_dcf/screens/new_dcf.dart';
import 'package:dynamic_dcf/services/api_calls.dart';
import 'package:dynamic_dcf/services/authentication.dart';
import 'package:dynamic_dcf/services/database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<String> _choices = <String>[
    'About',
    'Disclaimer',
    'Logout'
  ];
  final RefreshController _refreshController = RefreshController();
  @override
  void initState() {
    super.initState();
    updatePortfolio();
    //_checkEmailVerification();
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  int _counter = 0;
  Api_Calls ApiCalls = Api_Calls();
  var searchedTickers = List<Stock>();
  List<Portfolio> portfolios = null;
  List<dynamic> allRatios = List<dynamic>();
  dynamic priceList = null;

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

  Future<void> updatePortfolio() {
    print("sick");
    String tickerList = '';
    DatabaseService().getPortfolio().then((snapshot) {
      portfolios = null;
      List<Portfolio> tempPortfolios = List<Portfolio>();

      snapshot.documents.forEach((f) {
        Portfolio tempPort =
            Portfolio.fromJson(f.data, f.documentID); //Portfolio(userId:
        tempPortfolios.add(tempPort);
        tickerList = tickerList + ',' + tempPort.symbol;
        //print(tempPort.userId);
      });
      tempPortfolios =
          tempPortfolios.where((port) => port.userId == widget.userId).toList();
      if (tempPortfolios.length == 0) {
        setState(() {
          portfolios = null;
          allRatios = List<dynamic>();
        });
        return null;
      }
      tempPortfolios.forEach((port) {
        Api_Calls().getRatios(port.symbol).then((ratio) {
          allRatios.add(ratio);
          setState(() {
            portfolios = tempPortfolios;
          });
        });
      });
      priceList == null;
      Api_Calls().getPrice(tickerList).then((prices) {
        priceList = prices;
        //print("prices $prices");
      });
    });
    return null;
  }

  String getMetric(String ticker, String type, String metric) {
    //print("getting metric $ticker $type $metric");

    if (allRatios.where((r) => r['symbol'] == ticker).toList().isEmpty) {
      return '-';
    } else if (type == "date") {
      return allRatios.where((r) => r['symbol'] == ticker).toList()[0]['ratios']
          [0]['date'];
    } else {
      if (allRatios.where((r) => r['symbol'] == ticker).toList()[0]['ratios'][0]
              [type][metric] ==
          '') {
        return '-';
      } else if (metric == "dividendYield") {
        return (double.parse(allRatios
                        .where((r) => r['symbol'] == ticker)
                        .toList()[0]['ratios'][0][type][metric]) *
                    100)
                .toStringAsFixed(2) +
            '%';
      } else {
//        print(allRatios.where((r) => r['symbol'] == ticker).toList()[0]
//            ['ratios'][0][type][metric]);
        return double.parse(allRatios
                .where((r) => r['symbol'] == ticker)
                .toList()[0]['ratios'][0][type][metric])
            .toStringAsFixed(2);
      }
    }
//    print(allRatios.where((r) => r['symbol'] == ticker).toList()[0]['ratios'][0]
//        [type][metric]);
  }

  void _incrementCounter() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setStateModal /*You can rename this!*/) {
            return Column(
//              mainAxisAlignment: MainAxisAlignment.start,
//              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "Search",
                        icon: Icon(Icons.search),
                        contentPadding: EdgeInsets.all(5.0)),
                    onSubmitted: (String ticker) {
                      ApiCalls.searchTicker(ticker).then((values) {
                        searchedTickers.addAll(values);
                        setStateModal(() {
                          List<Stock> tempList = List<Stock>();
                          tempList.addAll(values);
                          searchedTickers = tempList;
                        });
                      });
                    },
                  ),
                ),
                Expanded(
                  child: searchedTickers.length == 0
                      ? Text(
                          "",
                        )
                      : ListView.builder(
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(searchedTickers[index].symbol),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NewDCF(
                                            passedSymbol:
                                                searchedTickers[index].symbol,
                                            userId: widget.userId,
                                            portfolio: null,
                                          )),
                                ).then((value) {
                                  updatePortfolio();
                                });
                              },
                            );
                          },
                          itemCount: searchedTickers.length,
                        ),
                )
              ],
            );
          });
        });
  }

  Widget bodyData() {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: portfolios == null
                    ? <DataColumn>[
                        DataColumn(label: Text('Symbol'), numeric: false),
                        DataColumn(label: Text('Price'), numeric: true),
                      ]
                    : <DataColumn>[
                        DataColumn(label: Text('Symbol'), numeric: false),
                        DataColumn(label: Text('Price'), numeric: true),
                        DataColumn(
                            label: Text('Fair Value '),
                            numeric: true,
                            tooltip: 'Fair value you estimated using DCF'),
                        DataColumn(label: Text('P/E'), numeric: true),
                        DataColumn(
                          label: Text('P/S'),
                          numeric: true,
                        ),
                        DataColumn(label: Text('P/B'), numeric: true),
                        DataColumn(
                          label: Text('PEG'),
                          numeric: true,
                        ),
                        DataColumn(
                            label: Text('Dividend Yield'), numeric: true),
                        DataColumn(
                            label: Text(
                              'Ratios\n Updated',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 10),
                            ),
                            numeric: false),
                      ],
                rows: portfolios == null
                    ? [
                        DataRow(selected: false, cells: [
                          DataCell(Text('Empty')),
                          DataCell(Text('---'))
                        ])
                      ]
                    : portfolios.map((port) {
                        return DataRow(cells: [
                          DataCell(InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewDCF(
                                          passedSymbol: port.symbol,
                                          userId: widget.userId,
                                          portfolio: port,
                                          documentId: port.documentId,
                                        )),
                              ).then((value) {
                                updatePortfolio();
                              });
                            },
                            child: Text(
                              port.symbol,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 18),
                            ),
                          )),
                          DataCell(Text(
                            getPrice(port.symbol),
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18),
                          )),
                          DataCell(Text(port.presentValue.toString()),
                              showEditIcon: true, onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewDCF(
                                        passedSymbol: port.symbol,
                                        userId: widget.userId,
                                        portfolio: port,
                                        documentId: port.documentId,
                                      )),
                            ).then((value) {
                              updatePortfolio();
                            });
                          }),
                          DataCell(Text((double.parse(getPrice(port.symbol)) /
                                  port.earningsLastYear)
                              .toStringAsFixed(1))),
                          DataCell(Text(getMetric(
                              port.symbol,
                              "investmentValuationRatios",
                              "priceToSalesRatio"))),
                          DataCell(Text(getMetric(
                              port.symbol,
                              "investmentValuationRatios",
                              "priceToBookRatio"))),
                          DataCell(Text(getMetric(
                              port.symbol,
                              "investmentValuationRatios",
                              "priceEarningsToGrowthRatio"))),
                          DataCell(Text(getMetric(port.symbol,
                              "investmentValuationRatios", "dividendYield"))),
                          DataCell(Text(
                              getMetric(port.symbol, "date", "dividendYield"))),
                        ]);
                      }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DCF Calculator",
            style: TextStyle(
                color: Colors.white) //Theme.of(context).textTheme.title,

            ),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: selectedMenuItem,
            itemBuilder: (BuildContext context) {
              return _choices.map((String choice) {
                return PopupMenuItem(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: () async {
          await updatePortfolio();
          _refreshController.refreshCompleted();
        },
        child: bodyData(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  String getPrice(String symbol) {
    if (priceList == null) {
      return '0';
    }
    if (priceList['companiesPriceList'] == null) {
      return '0';
    } else {
      return priceList['companiesPriceList']
          .where((s) {
            return s['symbol'] == symbol;
          })
          .toList()[0]['price']
          .toString();
    }
  }

  void selectedMenuItem(String selected) {
    //print(selected);
    String aboutBody =
        "Discounted cash flow (DCF) is a valuation method used to estimate the value of an investment based on its future cash flows. DCF analysis attempts to figure out the value of an investment today, based on projections of how much money it will generate in the future.";
    String disclaimerBody =
        "This app is a resource for educational and general informational purposes and does not constitute actual financial advice. No one should make any investment decision without first consulting his or her own financial advisor and/or conducting his or her own research and due diligence. There is no guarantee or other promise as to any results that may be obtained from using this app. Investing of any kind involves risk and your investments may lose value.";
    if (selected == "Logout") {
      signOut();
    } else if (selected == "About") {
      _showInfo("About", aboutBody).then((nullValue) {
        //Navigator.of(context).pop();
      });
    } else if (selected == "Disclaimer") {
      _showInfo("Disclaimer", disclaimerBody).then((nullValue) {
        //Navigator.of(context).pop();
      });
    }
  }
}
