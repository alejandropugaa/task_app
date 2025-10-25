import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_app/models/profile_model.dart';
import 'package:task_app/services/database_service.dart';
import 'package:task_app/widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  // Recibe el perfil actual para editarlo
  final Profile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _dbService = DatabaseService.instance;
  final _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  // (Controladores para email y teléfono omitidos por simplicidad, pero se añaden fácil)

  XFile? _imageFile; // Para la nueva imagen seleccionada
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Carga los datos del perfil en los controladores
    _nameController = TextEditingController(text: widget.profile.fullName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Método para seleccionar imagen (Cámara o Galería)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 600,
        imageQuality: 70,
        preferredCameraDevice: CameraDevice.front,
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

  // Método para guardar los cambios en la BD
  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Determina qué ruta de avatar guardar:
      // Si se seleccionó una imagen nueva, usa su ruta.
      // Si no, usa la ruta del avatar antiguo que ya estaba en el perfil.
      final String newAvatarUrl = _imageFile?.path ?? widget.profile.avatarUrl;

      await _dbService.updateUserProfile(
        fullName: _nameController.text,
        avatarUrl: newAvatarUrl,
      );

      if (mounted) {
        // Devuelve 'true' a la pantalla anterior (ProfileScreen)
        // para indicarle que debe refrescarse.
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // --- SECCIÓN DE AVATAR ---
                _buildAvatarPicker(),
                const SizedBox(height: 30),

                // --- CAMPOS DEL FORMULARIO ---
                _buildTextField(
                  label: 'Nombre Completo',
                  controller: _nameController,
                  icon: Icons.person_outline,
                ),
                // (Aquí puedes añadir más campos como email, teléfono)
                const SizedBox(height: 20),

                // --- BOTÓN DE GUARDAR ---
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar Cambios',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
    );
  }

  // Widget para el selector de avatar
  Widget _buildAvatarPicker() {
    return Center(
      child: Stack(
        children: [
          // Muestra la imagen nueva (si existe) o la antigua
          _imageFile != null
              ? CircleAvatar(
                  radius: 60,
                  backgroundImage: FileImage(File(_imageFile!.path)),
                )
              : ProfileAvatar(avatarUrl: widget.profile.avatarUrl, radius: 60),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  // Muestra un diálogo para elegir cámara o galería
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Cámara'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Galería'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper reutilizable para crear campos
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
