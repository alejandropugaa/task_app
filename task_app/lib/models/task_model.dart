import 'package:task_app/models/profile_model.dart';

class Task {
  final int id; // ID de la base de datos (INTEGER)
  final String title;
  final String description;
  final String reward;
  final String location;
  final String taskImagePath; // Ruta local del archivo
  final DateTime dueDate;
  final String posterId; // ID del publicador
  final Profile poster; // Objeto de perfil relacionado

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.location,
    required this.taskImagePath,
    required this.dueDate,
    required this.posterId,
    required this.poster,
  });

  // Factory para leer desde el Map de SQLite (que viene del JOIN)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      reward: map['reward'],
      location: map['location'],
      taskImagePath: map['taskImagePath'],
      dueDate: DateTime.parse(map['dueDate']),
      posterId: map['posterId'],
      // Creamos el objeto Profile con los campos traídos por el JOIN
      poster: Profile(
        id: map['posterId'],
        fullName: map['fullName'],
        avatarUrl: map['avatarUrl'],
        rating: map['rating'],
      ),
    );
  }

  // Método para convertir el objeto a un Map para insertar en SQLite
  // Nota: No guardamos el objeto 'poster' completo, solo su ID.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reward': reward,
      'location': location,
      'taskImagePath': taskImagePath,
      'dueDate': dueDate.toIso8601String(),
      'posterId': posterId,
    };
  }
}
