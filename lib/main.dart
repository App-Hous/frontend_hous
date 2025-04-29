import 'package:flutter/material.dart';
import 'routes.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(ConstrApp());
}

class ConstrApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConstrApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
