import '../database_helper.dart';
import '../contracts/ejercicios_contract.dart';

/// Presentador para la pantalla de Ejercicios
/// Maneja la lógica de negocio de ejercicios y eventos
class EjerciciosPresenter implements EjerciciosPresenterContract {
  final EjerciciosContract _view;
  final DatabaseHelper _dbHelper;

  // Caché de datos
  List<Map<String, dynamic>> _ejercicios = [];
  // ignore: unused_field
  List<Map<String, dynamic>> _eventos = [];
  List<Map<String, dynamic>> _equipos = [];

  EjerciciosPresenter(this._view) : _dbHelper = DatabaseHelper() {
    // Escuchar cambios en la base de datos
    _dbHelper.addListener(_onDatabaseChanged);
  }

  void _onDatabaseChanged() {
    loadData();
  }

  @override
  Future<void> loadData() async {
    try {
      await Future.wait([loadEjercicios(), loadEventos(), loadEquipos()]);
    } catch (e) {
      _view.showError("Error al cargar datos: ${e.toString()}");
    }
  }

  @override
  Future<void> loadEjercicios() async {
    try {
      final ejercicios = await _dbHelper.getEjercicios();
      _ejercicios = ejercicios;
      _view.updateEjercicios(ejercicios);
    } catch (e) {
      _view.showError("Error al cargar ejercicios: ${e.toString()}");
    }
  }

  @override
  Future<void> loadEventos() async {
    try {
      final eventos = await _dbHelper.getEventos();
      _eventos = eventos;
      _view.updateEventos(eventos);
    } catch (e) {
      _view.showError("Error al cargar eventos: ${e.toString()}");
    }
  }

  @override
  Future<void> loadEquipos() async {
    try {
      final equipos = await _dbHelper.getEquipos();
      _equipos = equipos;
      _view.updateEquipos(equipos);
    } catch (e) {
      _view.showError("Error al cargar equipos: ${e.toString()}");
    }
  }

  @override
  Future<void> saveEjercicio({
    required String nombre,
    required String clasificacion,
    required List<String> participantesIds,
    int? id,
  }) async {
    final sanitizedNombre = _sanitizeInput(nombre);

    if (sanitizedNombre.isEmpty) {
      _view.showError("El nombre del ejercicio es obligatorio");
      return;
    }

    if (!_validarNombreEjercicio(sanitizedNombre)) {
      _view.showError("El nombre solo puede contener letras, números y espacios (2-50 caracteres)");
      return;
    }

    if (clasificacion.isEmpty) {
      _view.showError("Debes seleccionar una clasificación");
      return;
    }

    _view.showLoading();

    try {
      final data = {
        'id': id,
        'nombre': nombre.trim(),
        'clasificacion': clasificacion,
        'participantes': participantesIds.join(','),
      };

      int resultado;
      if (id == null) {
        // Crear nuevo ejercicio
        resultado = await _dbHelper.insertEjercicio(data);
      } else {
        // Actualizar ejercicio existente
        resultado = await _dbHelper.updateEjercicio(data);
      }

      _view.hideLoading();

      if (resultado > 0) {
        _view.showSuccess(
          id == null
              ? "Ejercicio creado exitosamente"
              : "Ejercicio actualizado exitosamente",
        );
        await loadEjercicios();
      } else {
        _view.showError("Error al guardar el ejercicio");
      }
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al guardar ejercicio: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteEjercicio(int ejercicioId) async {
    _view.showLoading();

    try {
      final resultado = await _dbHelper.deleteEjercicio(ejercicioId);

      _view.hideLoading();

      if (resultado > 0) {
        _view.showSuccess("Ejercicio eliminado exitosamente");
        await loadEjercicios();
      } else {
        _view.showError("Error al eliminar el ejercicio");
      }
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al eliminar ejercicio: ${e.toString()}");
    }
  }

  @override
  Future<void> updateEventoAsignaciones({
    required int eventoId,
    required List<int> ejerciciosIds,
    required List<int> equiposIds,
  }) async {
    _view.showLoading();

    try {
      // Convertir listas a strings separados por comas
      final ejerciciosStr = ejerciciosIds.isEmpty
          ? '-'
          : ejerciciosIds.join(',');
      final equiposStr = equiposIds.isEmpty ? '-' : equiposIds.join(',');

      final resultado = await _dbHelper.updateEvento({
        'id': eventoId,
        'ejercicios_ids': ejerciciosStr,
        'equipos_ids': equiposStr,
      });

      _view.hideLoading();

      if (resultado > 0) {
        _view.showSuccess("Evento actualizado exitosamente");
        await loadEventos();
      } else {
        _view.showError("Error al actualizar el evento");
      }
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al actualizar evento: ${e.toString()}");
    }
  }

  @override
  void showEjercicioDetails(Map<String, dynamic> ejercicio) {
    _view.showEjercicioDetails(ejercicio);
  }

  @override
  void showEventoDetails(Map<String, dynamic> evento) {
    _view.showEventoDetails(evento);
  }

  @override
  void requestDeleteEjercicio(Map<String, dynamic> ejercicio) {
    _view.showDeleteConfirmation(ejercicio);
  }

  @override
  void showEjercicioForm({Map<String, dynamic>? ejercicio}) {
    _view.showEjercicioForm(ejercicio: ejercicio);
  }

  @override
  String translateEjerciciosIdsToNames(String? idsString) {
    if (idsString == null || idsString == '-' || idsString.isEmpty) {
      return 'Ninguno';
    }

    try {
      final ids = idsString.split(',').map((e) => int.parse(e.trim())).toList();
      final nombres = <String>[];

      for (var id in ids) {
        final ejercicio = _ejercicios.firstWhere(
          (e) => e['id'] == id,
          orElse: () => {'nombre': 'ID: $id'},
        );
        nombres.add(ejercicio['nombre'].toString());
      }

      return nombres.isEmpty ? 'Ninguno' : nombres.join(', ');
    } catch (e) {
      return 'Error al cargar ejercicios';
    }
  }

  @override
  String translateEquiposIdsToNames(String? idsString) {
    if (idsString == null || idsString == '-' || idsString.isEmpty) {
      return 'Ninguno';
    }

    try {
      final ids = idsString.split(',').map((e) => int.parse(e.trim())).toList();
      final nombres = <String>[];

      for (var id in ids) {
        final equipo = _equipos.firstWhere(
          (e) => e['id'] == id,
          orElse: () => {'nombre': 'ID: $id'},
        );
        nombres.add(equipo['nombre'].toString());
      }

      return nombres.isEmpty ? 'Ninguno' : nombres.join(', ');
    } catch (e) {
      return 'Error al cargar equipos';
    }
  }

  @override
  void dispose() {
    _dbHelper.removeListener(_onDatabaseChanged);
  }

String _sanitizeInput(String input) {
    String result = input.trim();
    result = result.replaceAll('<', '');
    result = result.replaceAll('>', '');
    result = result.replaceAll('"', '');
    result = result.replaceAll("'", '');
    result = result.replaceAll(';', '');
    result = result.replaceAll('\\', '');
    return result;
  }

  bool _validarNombreEjercicio(String nombre) {
    if (nombre.length < 2 || nombre.length > 50) return false;
    if (!RegExp(r'^[A-ZÁÉÍÓÚÑ]').hasMatch(nombre)) return false;
    return RegExp(r'^[A-ZÁÉÍÓÚÑ][a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s]*$').hasMatch(nombre);
  }
}
