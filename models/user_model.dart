class User {
  final int? id;
  final String nombre;
  final String email;
  final String telefono;
  final String password;
  final String role;
  final String? foto;

  User({
    this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.password,
    this.role = 'user',
    this.foto,
  });
  // Convierte un Mapa de SQLite a un objeto User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nombre: map['nombre'],
      email: map['email'],
      telefono: map['telefono'],
      password: map['password'],
      role: map['role'] ?? 'user',
      foto: map['foto'],
    );
  }
  // Convierte a Mapa para insertar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'password': password,
      'role': role,
      'foto': foto,
    };
  }
}
