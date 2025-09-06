import 'package:flutter/material.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:pmsen_2025/utils/value_listener.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _SelectedTab { home, favorite, search, person }

class _HomeScreenState extends State<HomeScreen> {
  _SelectedTab _selectedTab = _SelectedTab.home;

  void _handleIndexChanged(int index) {
    setState(() {
      _selectedTab = _SelectedTab.values[index];
    });
  }

  Widget _getScreenForTab(_SelectedTab tab) {
    switch (tab) {
      case _SelectedTab.home:
        return Center(
          child: Text("Menú de opciones", style: TextStyle(fontSize: 20)),
        );
      case _SelectedTab.favorite:
        return Center(child: Text("Favoritos", style: TextStyle(fontSize: 20)));
      case _SelectedTab.search:
        return Center(child: Text("Buscar", style: TextStyle(fontSize: 20)));
      case _SelectedTab.person:
        return Center(child: Text("Perfil", style: TextStyle(fontSize: 20)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: ValueListener.isDark,
            builder: (context, isDarkMode, child) {
              return IconButton(
                icon: Icon(isDarkMode ? Icons.sunny : Icons.nightlight),
                onPressed: () {
                  ValueListener.isDark.value = !isDarkMode;
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(),
      body: _getScreenForTab(_selectedTab),
      bottomNavigationBar: SafeArea(
        child: DotNavigationBar(
          margin: EdgeInsets.symmetric(horizontal: 10),
          currentIndex: _SelectedTab.values.indexOf(_selectedTab),
          dotIndicatorColor: Colors.white,
          unselectedItemColor: Colors.grey[300],
          splashBorderRadius: 50,
          onTap: _handleIndexChanged,
          items: [
            DotNavigationBarItem(
              icon: Icon(Icons.home),
              selectedColor: Color(0xff73544C),
            ),
            DotNavigationBarItem(
              icon: Icon(Icons.favorite),
              selectedColor: Color(0xff73544C),
            ),
            DotNavigationBarItem(
              icon: Icon(Icons.search),
              selectedColor: Color(0xff73544C),
            ),
            DotNavigationBarItem(
              icon: Icon(Icons.person),
              selectedColor: Color(0xff73544C),
            ),
          ],
        ),
      ),
    );
  }
}
