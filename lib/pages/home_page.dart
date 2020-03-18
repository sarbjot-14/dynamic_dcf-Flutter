import 'package:dynamic_dcf/models/stock.dart';
import 'package:dynamic_dcf/screens/new_dcf.dart';
import 'package:dynamic_dcf/services/api_calls.dart';
import 'package:dynamic_dcf/services/authentication.dart';
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
        title: Text("Dynamic DCF Calculator"),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: signOut)
        ],
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
