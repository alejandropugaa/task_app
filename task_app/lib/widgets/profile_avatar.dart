import 'dart:io';
import 'package:flutter/material.dart';

// Este widget helper decide si mostrar una imagen de 'assets' o de 'file'
class ProfileAvatar extends StatelessWidget {
  final String avatarUrl;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.avatarUrl,
    required this.radius,
  });

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('lib/assets/')) {
      // Es la imagen por defecto
      return AssetImage(path);
    } else {
      // Es una imagen de archivo local
      return FileImage(File(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: _getImageProvider(avatarUrl),
      // Manejo de error si la imagen del archivo no se encuentra
      onBackgroundImageError: (exception, stackTrace) {
        // Si falla (ej. se borró el archivo), muestra el avatar por defecto
        const AssetImage('lib/assets/images/default_avatar.png');
      },
      backgroundColor: Colors.grey[200],
    );
  }
}
