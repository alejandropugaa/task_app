import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/services/database_service.dart';

class CreateTaskScreen extends StatefulWidget {
  // Opcional: Si se pasa una tarea, la pantalla entra en "Modo Edición"
  final Task? taskToEdit;

  const CreateTaskScreen({super.key, this.taskToEdit});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rewardController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _selectedDate;
  XFile? _imageFile; // Para almacenar el archivo de imagen seleccionado

  bool _isLoading = false;
  final _dbService = DatabaseService.instance;
  final _imagePicker = ImagePicker();

  bool get _isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      // Si estamos editando, llenamos los campos con la info existente
      final task = widget.taskToEdit!;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _rewardController.text = task.reward;
      _locationController.text = task.location;
      _selectedDate = task.dueDate;
      // Si la tarea ya tiene una imagen, la cargamos
      if (task.taskImagePath.isNotEmpty) {
        _imageFile = XFile(task.taskImagePath);
      }
    }
  }

  // Método para seleccionar imagen (Cámara o Galería)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  // Método para mostrar el DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Método para guardar o actualizar la tarea
  Future<void> _saveTask() async {
    // Validar el formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Validar que se haya seleccionado una fecha
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una fecha.')),
      );
      return;
    }
    // Validar que se haya seleccionado una imagen
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, agrega una imagen para la tarea.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEditing) {
        // --- MODO ACTUALIZAR ---
        await _dbService.updateTask(
          id: widget.taskToEdit!.id,
          title: _titleController.text,
          description: _descriptionController.text,
          reward: _rewardController.text,
          location: _locationController.text,
          dueDate: _selectedDate!,
          taskImagePath: _imageFile!.path,
        );
      } else {
        // --- MODO CREAR ---
        await _dbService.createTask(
          title: _titleController.text,
          description: _descriptionController.text,
          reward: _rewardController.text,
          location: _locationController.text,
          dueDate: _selectedDate!,
          taskImagePath: _imageFile!.path,
        );
      }

      // Si todo sale bien, cerramos la pantalla
      // Enviamos 'true' para indicar que la lista anterior debe refrescarse
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la tarea: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Tarea' : 'Crear Nueva Tarea'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  // --- SELECCIÓN DE IMAGEN ---
                  _buildImagePicker(),
                  const SizedBox(height: 20),

                  _buildTextFormField(
                    label: 'Título de la tarea',
                    controller: _titleController,
                  ),
                  _buildTextFormField(
                    label: 'Descripción',
                    controller: _descriptionController,
                    maxLines: 4,
                  ),
                  _buildTextFormField(
                    label: 'Recompensa (ej. \$50)',
                    controller: _rewardController,
                  ),
                  _buildTextFormField(
                    label: 'Ubicación',
                    controller: _locationController,
                  ),
                  _buildDatePicker(),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Actualizar Tarea' : 'Publicar Tarea',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget para el selector de imagen
  Widget _buildImagePicker() {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                )
              : const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Cámara'),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            TextButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Galería'),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ],
    );
  }

  // Widget helper para crear campos de texto
  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.deepPurple),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo no puede estar vacío';
          }
          return null;
        },
      ),
    );
  }

  // Widget helper para el selector de fecha
  Widget _buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
        title: Text(
          _selectedDate == null
              ? 'Seleccionar fecha límite'
              : 'Fecha: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _selectDate(context),
      ),
    );
  }
}
