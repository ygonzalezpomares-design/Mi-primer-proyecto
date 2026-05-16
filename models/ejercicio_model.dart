class Ejercicio {
  final int id;
  final String nombre;
  final String clasificacion;
  final String participantes;

  Ejercicio({
    required this.id,
    required this.nombre,
    required this.clasificacion,
    required this.participantes,
  });

  // Crear desde un Map (desde la BD)
  factory Ejercicio.fromMap(Map<String, dynamic> map) {
    return Ejercicio(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      clasificacion: map['clasificacion'] as String,
      participantes: map['participantes'] as String? ?? '-',
    );
  }

  // Convertir a Map (para guardar en BD)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'clasificacion': clasificacion,
      'participantes': participantes,
    };
  }
}
