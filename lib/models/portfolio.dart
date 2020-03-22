class Portfolio {
  String userId;
  String symbol;
  String name;
  double presentValue;
  double discountRate;
  double terminalMultiple;
  double growthRateP1;
  double growthRateP2;
  double safetyMargin;
  String documentId;

  Portfolio(
      {this.userId,
      this.symbol,
      this.name,
      this.presentValue,
      this.discountRate,
      this.terminalMultiple,
      this.growthRateP1,
      this.growthRateP2,
      this.safetyMargin});

  Portfolio.fromJson(Map<String, dynamic> json, String docId) {
    symbol = json['symbol'];
    userId = json['userId'];
    name = json['name'];
    presentValue = json['presentValue'].toDouble();
    discountRate = json['discountRate'];
    terminalMultiple = json['terminalMultiple'];
    growthRateP1 = json['growthRateP1'];
    growthRateP2 = json['growthRateP2'];
    safetyMargin = json['safetyMargin'];
    documentId = docId;
  }

  toJson() {
    return {
      "userId": userId,
      "symbol": symbol,
      'presentValue': presentValue,
      'discountRate': discountRate,
      'terminalMultiple': terminalMultiple,
      'growthRateP1': growthRateP1,
      'growthRateP2': growthRateP2,
      'safetyMargin': safetyMargin
    };
  }
}
