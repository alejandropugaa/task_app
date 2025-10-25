import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/services/database_service.dart';
import 'package:task_app/screens/task_details_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _dbService = DatabaseService.instance;

  Map<DateTime, List<Task>> _tasksByDay = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Task> _selectedTasks = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _dbService.getTasks();
    final Map<DateTime, List<Task>> tasksMap = {};

    for (var task in tasks) {
      // Normaliza la fecha a medianoche para agrupar
      final day = DateTime.utc(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      if (tasksMap[day] == null) {
        tasksMap[day] = [];
      }
      tasksMap[day]!.add(task);
    }

    // Comprueba si el widget sigue "montado" antes de llamar a setState
    if (mounted) {
      setState(() {
        _tasksByDay = tasksMap;
        // Actualiza las tareas del día seleccionado
        _selectedTasks = _getTasksForDay(_selectedDay!);
      });
    }
  }

  // Obtiene las tareas para un día específico
  List<Task> _getTasksForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _tasksByDay[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedTasks = _getTasksForDay(selectedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Tareas'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          TableCalendar<Task>(
            locale:
                'es_ES', // Asegúrate de tener intl y flutter_localizations si usas esto
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: _getTasksForDay, // Muestra marcadores
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple[400],
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Tareas para el día seleccionado",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: _selectedTasks.isEmpty
                ? const Center(child: Text("No hay tareas para este día."))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: _selectedTasks.length,
                    itemBuilder: (context, index) {
                      final task = _selectedTasks[index];
                      // --- 2. MODIFICACIÓN AQUÍ ---
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Text(
                            'Publicado por: ${task.poster.fullName}',
                          ),
                          trailing: Text(
                            task.reward,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // 3. Agregamos el evento onTap para navegar
                          onTap: () async {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailsScreen(task: task),
                              ),
                            );

                            // 4. Si se editó o borró (result == true), refrescamos la lista
                            if (result == true) {
                              _loadTasks();
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
