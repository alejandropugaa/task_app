class Profile {
  final String id;
  final String fullName;
  final String avatarUrl;
  final double rating;

  Profile({
    required this.id,
    required this.fullName,
    required this.avatarUrl,
    required this.rating,
  });

  // Factory para leer desde un Map de SQLite
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      fullName: map['fullName'] ?? 'Usuario Anónimo',
      avatarUrl: map['avatarUrl'] ?? 'lib/assets/images/default_avatar.png',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Método para convertir el objeto a un Map para insertar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'rating': rating,
    };
  }
}
