import 'package:dynamic_dcf/pages/root_page.dart';

///
import 'package:dynamic_dcf/services/authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RootPage(
          auth: new Auth()), // MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
