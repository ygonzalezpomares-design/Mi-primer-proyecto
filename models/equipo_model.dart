import 'ejercicio_model.dart';

class Equipo {
  final int id;
  final String nombre;
  final String curso;
  final String evento;
  final String evaluacionGral;
  final String posicion;

  // 🎯 Lista de ejercicios (NO se guarda en BD, se calcula)
  final List<Ejercicio> ejercicios;

  Equipo({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.evento,
    required this.evaluacionGral,
    required this.posicion,
    required this.ejercicios,
  });

  // Crear desde un Map (desde la BD)
  factory Equipo.fromMap(Map<String, dynamic> map) {
    return Equipo(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      curso: map['curso'] as String,
      evento: map['evento'] as String? ?? '-',
      evaluacionGral: map['evaluacion_gral'] as String? ?? '-',
      posicion: map['posicion'] as String? ?? '-',
      ejercicios:
          [], // Inicialmente vacío, se llenará con getEquipoConEjercicios
    );
  }

  // Convertir a Map (para guardar en BD)
  // NOTA: ejercicios NO se guarda en la BD
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'curso': curso,
      'evento': evento,
      'evaluacion_gral': evaluacionGral,
      'posicion': posicion,
      // ejercicios NO se incluye aquí porque no es una columna de la BD
    };
  }

  // Método para copiar el equipo con nuevos ejercicios
  Equipo copyWith({List<Ejercicio>? ejercicios}) {
    return Equipo(
      id: id,
      nombre: nombre,
      curso: curso,
      evento: evento,
      evaluacionGral: evaluacionGral,
      posicion: posicion,
      ejercicios: ejercicios ?? this.ejercicios,
    );
  }
}
