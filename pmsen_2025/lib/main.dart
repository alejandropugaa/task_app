import 'package:flutter/material.dart';
import 'package:pmsen_2025/screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'package:pmsen_2025/utils/theme_app.dart';
import 'package:pmsen_2025/utils/value_listener.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ValueListener.isDark,
      builder: (context, value, _) {
        return MaterialApp(
          theme: value ? ThemeApp.darkTheme() : ThemeApp.lightTheme(),
          routes: {'/home': (context) => HomeScreen()},
          title: 'Material App',
          home: LoginScreen(),
        );
      },
    );
  }
}
