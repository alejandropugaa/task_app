import 'package:flutter/material.dart';
import 'colors_app.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int contador = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Practica 1 by Alejandro'),
          backgroundColor: Colors.blue,
        ),
        body: Container(
          child: Center(
            child: Text(
              'Contador $contador',
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'Blona',
                color: ColorsApp.textColor,
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.ads_click),
          onPressed: () {
            contador++;
            print(contador);
            setState(() {});
          },
        ),
      ),
    );
  }
}
