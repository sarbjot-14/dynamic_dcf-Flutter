class Stock {
  String symbol;
  String name;

  Stock({this.symbol, this.name});

  Stock.fromJson(Map<String, dynamic> json) {
    symbol = json['symbol'];
    name = json['name'];
  }
}
