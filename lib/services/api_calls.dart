import 'dart:convert';

import 'package:dynamic_dcf/models/stock.dart';
import 'package:http/http.dart' as http;

class Api_Calls {
  String uid;

  String url;

  Future<List<Stock>> searchTicker(String ticker) async {
    var stockList = List<Stock>();
    var response = await http.get(
        'https://financialmodelingprep.com/api/v3/search?query=${ticker.toUpperCase()}&limit=150');
    if (response.statusCode == 200) {
      var stocks = json.decode(response.body);
      for (var stock in stocks) {
        stockList.add(Stock.fromJson(stock));
      }
      stockList.sort((stock1, stock2) {
        return stock1.symbol.length - stock2.symbol.length;
      });

      return stockList;
    } else {
      print("api call failed");
    }
  }

  Future<double> getEPS(String ticker) async {
    var stockList = List<Stock>();
    var response = await http.get(
        'https://financialmodelingprep.com/api/v3/financials/income-statement/$ticker');
    if (response.statusCode == 200) {
      var stocks = json.decode(response.body);

      var lastYear = stocks['financials'][0];

      var eps = lastYear['EPS Diluted'];
      //print("eps is  $eps for ticker $ticker");
      return double.parse(eps);
    } else {
      print("api call failed (eps)");
    }
  }

  Future<dynamic> getPrice(String portList) async {
    //print(portList.substring(1));
    var response = await http.get(
        'https://financialmodelingprep.com/api/v3/stock/real-time-price/${portList.substring(1)}');
    if (response.statusCode == 200) {
      var stockPrices = json.decode(response.body);
      return stockPrices;
      //return double.parse(eps);
    } else {
      print("api call failed (eps)");
    }
  }

  Future<dynamic> getRatios(String ticker) async {
    var response = await http.get(
        'https://financialmodelingprep.com/api/v3/financial-ratios/${ticker.toUpperCase()}');

    if (response.statusCode == 200) {
      var ratios = json.decode(response.body);
      //print(ratios);
      return ratios;
    } else {
      print("api call failed");
    }
  }
}
