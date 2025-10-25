import 'package:flutter/material.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/screens/task_details_screen.dart';
import 'package:task_app/screens/task_map_screen.dart';
import 'package:task_app/services/database_service.dart';
import 'package:task_app/widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dbService = DatabaseService.instance;
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    // initState no puede ser async, así que llamamos a _loadTasks
    // pero no podemos 'await' su resultado aquí.
    _loadTasks();
  }

  // --- CAMBIO 1: La función ahora es Future<void> ---
  Future<void> _loadTasks() async {
    // 1. Creamos el nuevo future
    final newFuture = _dbService.getTasks();

    // 2. Actualizamos el estado para que la UI use el nuevo future
    setState(() {
      _tasksFuture = newFuture;
    });

    // 3. AHORA SÍ: Esperamos a que el future se complete.
    // Esto es lo que le dice al RefreshIndicator que deje de girar.
    await newFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        // --- CAMBIO 2: onRefresh ahora apunta a la función async ---
        onRefresh: _loadTasks,
        child: SingleChildScrollView(
          // --- CAMBIO 3: Añadimos físicas ---
          // Esto permite que el "pull-to-refresh" funcione
          // incluso si el contenido es muy corto.
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hola, Alejandro",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Vamos a completar algunas tareas",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              _buildTaskCarousel(context),
              const SizedBox(height: 30),
              _buildSectionHeader(context, 'Categorías', () {}),
              _buildCategoryItem(
                'Limpieza',
                '1.2k tareas',
                'lib/assets/images/clean.png',
              ),
              _buildCategoryItem(
                'Plomería',
                '800 tareas',
                'lib/assets/images/plumber.png',
              ),
              _buildCategoryItem(
                'Paseo',
                '1.5k tareas',
                'lib/assets/images/dog.png',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (El resto del código: _buildTaskCarousel, _buildSectionHeader,
  // y _buildCategoryItem no necesitan cambios y permanecen igual)

  Widget _buildTaskCarousel(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 230,
          child: FutureBuilder<List<Task>>(
            future: _tasksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay tareas publicadas.'));
              }

              final tasks = snapshot.data!;

              return Column(
                children: [
                  _buildSectionHeader(
                    context,
                    'Tareas Recientes',
                    () {},
                    isFirst: true,
                    tasks: tasks,
                  ),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailsScreen(task: task),
                              ),
                            );
                            if (result == true) {
                              // Esto sigue funcionando bien, pero _loadTasks
                              // ahora es async, aunque no necesitamos "await" aquí.
                              _loadTasks();
                            }
                          },
                          child: TaskCard(task: task),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onViewAll, {
    bool isFirst = false,
    List<Task> tasks = const [],
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            if (isFirst) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskMapScreen(tasks: tasks),
                ),
              );
            } else {
              onViewAll();
            }
          },
          child: Text(isFirst ? 'Ver en mapa >' : 'Ver todo >'),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String title, String subtitle, String imagePath) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.1),
          // Asumo que tienes la imagen, si no, usa un Icon()
          child: Image.asset(imagePath, width: 24, height: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
