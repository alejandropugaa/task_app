import 'package:flutter/material.dart';
import 'package:task_app/models/profile_model.dart';
import 'package:task_app/services/database_service.dart';
import 'package:task_app/widgets/profile_avatar.dart'; // <-- Importa el nuevo widget
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _dbService = DatabaseService.instance;
  late Future<Profile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = _dbService.getCurrentUserProfile();
    });
  }

  // Navega a editar y refresca al volver
  void _navigateToEdit(Profile profile) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: profile),
      ),
    );

    // Si 'result' es true, significa que se guardaron cambios
    if (result == true) {
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<Profile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No se encontró el perfil.'));
          }

          final profile = snapshot.data!;

          return Column(
            children: [
              _buildHeader(context, profile),
              _buildProfileOptions(context, profile),
            ],
          );
        },
      ),
    );
  }

  // Widget para el encabezado morado
  Widget _buildHeader(BuildContext context, Profile profile) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.deepPurple[300],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const Text(
            'Mi Perfil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // --- USA EL NUEVO WIDGET ---
          ProfileAvatar(avatarUrl: profile.avatarUrl, radius: 45),
          const SizedBox(height: 12),
          Text(
            profile.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rating: ${profile.rating}', // Muestra el rating real
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _StatItem(value: '22', label: 'Tareas Completadas'),
              _StatItem(value: '15', label: 'En Progreso'),
              _StatItem(value: '\$850', label: 'Ganado'),
            ],
          ),
        ],
      ),
    );
  }

  // Opciones del perfil
  Widget _buildProfileOptions(BuildContext context, Profile profile) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _OptionItem(
            icon: Icons.edit_outlined,
            title: 'Editar Perfil',
            onTap: () {
              // Pasa el perfil cargado a la pantalla de edición
              _navigateToEdit(profile);
            },
          ),
          _OptionItem(
            icon: Icons.settings_outlined,
            title: 'Configuración',
            onTap: () {},
          ),
          _OptionItem(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            onTap: () {},
          ),
          _OptionItem(
            icon: Icons.help_outline,
            title: 'Ayuda y Soporte',
            onTap: () {},
          ),
          const SizedBox(height: 20),
          _OptionItem(icon: Icons.logout, title: 'Cerrar Sesión', onTap: () {}),
        ],
      ),
    );
  }
}

// --- Widgets Auxiliares (sin cambios) ---
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
