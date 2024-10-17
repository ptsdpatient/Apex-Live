import 'dart:convert';

import 'package:app/utilities/button.dart';
import 'package:app/utilities/input.dart';
import 'package:app/utilities/methods.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../token.dart';


class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  TextEditingController username = TextEditingController(),password=TextEditingController();

  // String apiKey="http://apex-computers.live:2000/";

  String apiKey="http://117.248.105.198:2000/";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authenticateToken();
  }

  Future<void> authenticateToken() async {
    String? token = await storage.read(key: 'token');

    final url = Uri.parse(apiKey+'authenticateToken');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Login successful: ${response.body}');
        Navigator.pushNamed(context, '/user');
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
        removeToken();
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  Future<void> loginUser(String name, String password) async {
    final url = Uri.parse('${apiKey}login');

    final body = jsonEncode({
      'name': name,
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('token')) {
          String token = responseData['token'];
          await saveToken(token);

          print('Login successful: ${response.body}');
          Navigator.pushNamed(context, '/user');
        } else {
          print('Token not found in response');
        }
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(

           child:Column(
              children: [
                  Padding(
                    padding:const EdgeInsets.only(top: 80,bottom: 30),
                    child: Container(
                      height: 300,
                      child: Image.asset('images/icon.png'),
                    ),
                  ),
                  Input(
                    controller: username,
                    label: 'username',
                    icon: Icons.person,
                  ),Input(
                    controller: password,
                    label: 'password',
                    icon: Icons.password,
                  ),Button(context, getWidth(context)*0.5, 'login', () async {
                    await loginUser(username.text, password.text) as Future<void> Function();
                  })
            ],
        )
      )
    );
  }
}