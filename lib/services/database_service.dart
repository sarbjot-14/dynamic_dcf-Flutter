import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/portfolio.dart';

class DatabaseService {
  void addPortfolio(Portfolio port) {
    Firestore.instance
        .collection('portfolio')
        .add(port.toJson())
        .then((result) => {});
  }

  Future<QuerySnapshot> getPortfolio() {
    //List<Portfolio> portfolioList = List<Portfolio>();

    return Firestore.instance.collection("portfolio").getDocuments();
  }

  String updateData(Portfolio port, String docId) {
    //print("updating doc $docId");
    Firestore.instance
        .collection('portfolio')
        .document(docId)
        .updateData(port.toJson());
  }

  String deletePortfolio(String docId) {
    //print("updating doc $docId");
    Firestore.instance.collection('portfolio').document(docId).delete();
  }
}
