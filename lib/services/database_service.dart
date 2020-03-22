import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/portfolio.dart';

//String userId;
//Query _todoQuery = _database
//    .reference()
//    .child("todo")
//    .orderByChild("userId")
//    .equalTo(widget.userId);
class DatabaseService {
  //final FirebaseDatabase _database = FirebaseDatabase.instance;
  void addPortfolio(Portfolio port) {
    //Portfolio todo = new Portfolio(todoItem.toString(), widget.userId, false);
    //_database.reference().child("portfolio").push().set(port.toJson());

    Firestore.instance
        .collection('portfolio')
        .add(port.toJson())
        .then((result) => {});
  }

  Future<QuerySnapshot> getPortfolio() {
    List<Portfolio> portfolioList = List<Portfolio>();
    print("got called");
    return Firestore.instance.collection("portfolio").getDocuments();
  }

  String updateData(Portfolio port, String docId) {
    print("updating doc $docId");
    Firestore.instance
        .collection('portfolio')
        .document(docId)
        .updateData(port.toJson());
  }

  String deletePortfolio(String docId) {
    print("updating doc $docId");
    Firestore.instance.collection('portfolio').document(docId).delete();
  }
}
