import 'package:dynamic_dcf/pages/root_page.dart';
import 'package:dynamic_dcf/services/authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dynamic DCF Calculator',
      theme: ThemeData(
        // Define the default brightness and colors.
        //brightness: Brightness.dark,
        primaryColor: Color(0xFF37325E), //Colors.lightBlue[800],

        accentColor: Color(0xFFEAC435),

        // Define the default font family.
        fontFamily: 'Georgia',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      home: new RootPage(
          auth: new Auth()), // MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
