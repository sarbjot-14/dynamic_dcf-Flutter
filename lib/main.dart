import 'package:dynamic_dcf/screens/new_dcf.dart';
import 'package:dynamic_dcf/services/api_calls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'model/stock.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Api_Calls ApiCalls = Api_Calls();
  var searchedTickers = List<Stock>();

  void _incrementCounter() {
    double heightOfModalBottomSheet = 300;
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
                                          )),
                                );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
