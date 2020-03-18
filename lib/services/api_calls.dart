import 'dart:convert';

import 'package:dynamic_dcf/models/stock.dart';
import 'package:http/http.dart' as http;

class Api_Calls {
  String uid;

  String url;

  Future<List<Stock>> searchTicker(String ticker) async {
    var stockList = List<Stock>();
    var response = await http.get(
        'https://financialmodelingprep.com/api/v3/search?query=${ticker.toUpperCase()}&limit=50');
    if (response.statusCode == 200) {
      var stocks = json.decode(response.body);
      for (var stock in stocks) {
        stockList.add(Stock.fromJson(stock));
      }
      return stockList;
    } else {
      print("api call failed");
    }
  }

  Future<double> getEPS(String ticker) async {
    var stockList = List<Stock>();
    var response = await http.get(
        'https://financialmodelingprep.com/api/v3/financials/income-statement/AAPL');
    if (response.statusCode == 200) {
      var stocks = json.decode(response.body);
      //print(stocks['financials']);
      var lastYear = stocks['financials'][0];
      //print(lastYear);
      var eps = lastYear['EPS Diluted'];
      //print("eps is $eps");
      return double.parse(eps);
    } else {
      print("api call failed (eps)");
    }
  }
}
