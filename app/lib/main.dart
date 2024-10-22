import 'dart:io';

import 'package:app/pages/login_page.dart';
import 'package:app/pages/user_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  // startApp();
  // HttpOverrides.global = MyHttpOverrides();
  runApp(const MainApp());

}

// Future<void> startApp() async {
//   await dotenv.load(fileName: ".env");
//   runApp(const MainApp());
// }

class MainApp extends StatelessWidget{
  const MainApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
      routes:{
        '/login': (context) => const LoginPage(),
        '/user': (context) => const UserPage(),
      }
    );
  }
}

