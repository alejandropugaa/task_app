import 'package:flutter/material.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/screens/task_details_screen.dart';
import 'package:task_app/widgets/profile_avatar.dart'; // Asegúrate de tener este widget

// 1. Convertido a StatefulWidget
class TaskMapScreen extends StatefulWidget {
  final List<Task> tasks;
  const TaskMapScreen({super.key, required this.tasks});

  // Mantenemos las posiciones aquí
  static const List<Offset> _predefinedPositions = [
    Offset(15, 20),
    Offset(30, 55),
    Offset(45, 30),
    Offset(60, 70),
    Offset(75, 10),
    Offset(25, 80),
    Offset(50, 50),
    Offset(80, 45),
    Offset(35, 5),
    Offset(65, 90),
  ];

  @override
  State<TaskMapScreen> createState() => _TaskMapScreenState();
}

class _TaskMapScreenState extends State<TaskMapScreen> {
  // 2. Variable de estado para la tarea seleccionada
  Task? _selectedTask;

  void _onTaskIconTapped(Task task) {
    setState(() {
      _selectedTask = task;
    });
  }

  void _dismissPreview() {
    setState(() {
      _selectedTask = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas en el Mapa'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      // 3. Usamos un Stack para superponer la tarjeta
      body: Stack(
        children: [
          // --- 1. El Mapa Interactivo ---
          InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20.0),
            minScale: 0.5,
            maxScale: 4.0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return GestureDetector(
                  // 4. Tap en el mapa para cerrar la previsualización
                  onTap: _dismissPreview,
                  child: Stack(
                    children: [
                      // La imagen del mapa de fondo
                      Image.asset(
                        'lib/assets/images/map_placeholder.jpg',
                        width: width,
                        height: height,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Text(
                              'No se pudo cargar la imagen del mapa.',
                            ),
                          ),
                        ),
                      ),

                      // Mapea la lista de tareas a iconos en el Stack
                      ...widget.tasks.asMap().entries.map((entry) {
                        int index = entry.key;
                        Task task = entry.value;

                        final position =
                            TaskMapScreen._predefinedPositions[index %
                                TaskMapScreen._predefinedPositions.length];

                        final top = (position.dx / 100) * height;
                        final left = (position.dy / 100) * width;

                        return Positioned(
                          top: top,
                          left: left,
                          child: _TaskMapIcon(
                            task: task,
                            // 5. Al tocar el icono, se llama a _onTaskIconTapped
                            onTaskSelected: _onTaskIconTapped,
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),

          // --- 2. La Tarjeta de Previsualización (Animada) ---
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            // 6. Aparece desde abajo si _selectedTask no es nulo
            bottom: _selectedTask != null ? 16.0 : -200.0,
            left: 16.0,
            right: 16.0,
            child: _TaskPreviewCard(
              // Evita que se construya si _selectedTask es nulo
              task: _selectedTask,
              onTap: () {
                // 7. Al tocar la tarjeta, navega a detalles
                if (_selectedTask == null) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TaskDetailsScreen(task: _selectedTask!),
                  ),
                );
              },
              onClose: _dismissPreview,
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET DEL ICONO (Modificado) ---
// Ahora pasa la Tarea completa en lugar de un VoidCallback
class _TaskMapIcon extends StatelessWidget {
  final Task task;
  final Function(Task) onTaskSelected;

  const _TaskMapIcon({required this.task, required this.onTaskSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTaskSelected(task),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              task.reward,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          const Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 40,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- ¡NUEVO WIDGET DE PREVISUALIZACIÓN! ---
// Este widget dibuja la tarjeta que se muestra en tu imagen
class _TaskPreviewCard extends StatelessWidget {
  final Task? task;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _TaskPreviewCard({
    required this.task,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Si la tarea es nula (está oculto), no construye nada
    if (task == null) {
      return const SizedBox.shrink();
    }

    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 8,
      shadowColor: Colors.black45,
      child: InkWell(
        onTap: onTap, // Tocar la tarjeta
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // 1. Avatar
              ProfileAvatar(avatarUrl: task!.poster.avatarUrl, radius: 24),
              const SizedBox(width: 12),

              // 2. Info (Nombre + Título)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task!.poster.fullName,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      task!.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 3. Recompensa
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Recompensa",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    task!.reward,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              // 4. Botón de cerrar (alineado)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[500]),
                  onPressed: onClose, // Tocar la X
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
