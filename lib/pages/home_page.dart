import 'package:dynamic_dcf/models/portfolio.dart';
import 'package:dynamic_dcf/models/stock.dart';
import 'package:dynamic_dcf/screens/new_dcf.dart';
import 'package:dynamic_dcf/services/api_calls.dart';
import 'package:dynamic_dcf/services/authentication.dart';
import 'package:dynamic_dcf/services/database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  void updatePortfolio() {
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

      tempPortfolios.forEach((port) {
        Api_Calls().getRatios(port.symbol).then((ratio) {
          allRatios.add(ratio);
          setState(() {
            portfolios = tempPortfolios;
          });
        });
      });

      Api_Calls().getPrice(tickerList).then((prices) {
        priceList = prices;
        //print("prices $prices");
      });
    });
  }

  String getMetric(String ticker, String type, String metric) {
    //print("getting");
    if (allRatios.where((r) => r['symbol'] == ticker).toList().isEmpty) {
      return '-';
    } else {
      return double.parse(allRatios
              .where((r) => r['symbol'] == ticker)
              .toList()[0]['ratios'][0][type][metric])
          .toStringAsFixed(2);
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
              children: <Widget>[
                TextField(
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
                Expanded(
                  child: searchedTickers.length == 0
                      ? Text('Search Tickers')
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
                columns: <DataColumn>[
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
                    label: Text('PES'),
                    numeric: true,
                  ),
                  DataColumn(label: Text('Dividend Yield'), numeric: true),
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
                          DataCell(Text(port.symbol)),
                          DataCell(getPrice(port.symbol)),
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
                          DataCell(Text(getMetric(
                              port.symbol,
                              "investmentValuationRatios",
                              "priceEarningsRatio"))),
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
                          DataCell(Text(getMetric(
                              port.symbol,
                              "cashFlowIndicatorRatios",
                              "dividendPayoutRatio"))),
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
        title: Text("Dynamic DCF Calculator"),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Show Snackbar',
              onPressed: () {
                updatePortfolio();
              }),
          new FlatButton(
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: signOut),
        ],
      ),
      body: Container(
        child: bodyData(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget getPrice(String symbol) {
    if (priceList['companiesPriceList']
            .where((s) {
              return s['symbol'] == symbol;
            })
            .toList()
            .length ==
        0) {
      return Text('--');
    } else {
      return Text(priceList['companiesPriceList']
          .where((s) {
            return s['symbol'] == symbol;
          })
          .toList()[0]['price']
          .toString());
    }
  }
}
