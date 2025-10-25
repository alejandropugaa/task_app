import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'calendar_screen.dart';
import 'create_task_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Lista de widgets (pantallas)
  // Usamos 'late' para poder inicializarlas en initState
  late List<Widget> _widgetOptions;

  // Creamos GlobalKeys para poder refrescar las pantallas manualmente si es necesario
  // Aunque la mejor forma es reconstruir la lista
  final GlobalKey<State<HomeScreen>> _homeKey = GlobalKey<State<HomeScreen>>();
  final GlobalKey<State<CalendarScreen>> _calendarKey =
      GlobalKey<State<CalendarScreen>>();

  @override
  void initState() {
    super.initState();
    // Inicializamos la lista de pantallas
    _buildWidgetOptions();
  }

  // Método para construir (o reconstruir) la lista de pantallas
  void _buildWidgetOptions() {
    _widgetOptions = <Widget>[
      HomeScreen(key: _homeKey), // Asignamos las keys
      CalendarScreen(key: _calendarKey),
      const Center(child: Text('Chat Screen (Placeholder)')), // Placeholder
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Método para navegar a la pantalla de creación
  void _navigateToCreateTask() async {
    // Navegamos y esperamos un resultado
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
    );

    // Si el resultado es 'true', significa que se creó una tarea
    if (result == true) {
      // Forzamos la reconstrucción de las pantallas de Home y Calendar
      // para que carguen los nuevos datos
      setState(() {
        _buildWidgetOptions();
      });

      // Opcional: si la pantalla actual es Home o Calendar, podríamos
      // llamar a su método de refresco directamente usando las GlobalKeys,
      // pero reconstruir es más simple y efectivo.
      // (_homeKey.currentState as _HomeScreenState?)?._loadTasks();
      // (_calendarKey.currentState as _CalendarScreenState?)?._loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTask, // Llama al nuevo método
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2.0,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(icon: Icons.list_alt, index: 0),
            _buildNavItem(icon: Icons.calendar_today_outlined, index: 1),
            const SizedBox(width: 40), // Espacio para el FAB
            _buildNavItem(icon: Icons.chat_bubble_outline, index: 2),
            _buildNavItem(icon: Icons.person_outline, index: 3),
          ],
        ),
      ),
    );
  }

  // Helper para los ítems de navegación
  Widget _buildNavItem({required IconData icon, required int index}) {
    return IconButton(
      icon: Icon(icon),
      color: _selectedIndex == index ? Colors.deepPurple : Colors.grey,
      onPressed: () => _onItemTapped(index),
    );
  }
}
