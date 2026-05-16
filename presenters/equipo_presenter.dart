import '../database_helper.dart';
import '../contracts/equipo_contract.dart';

class EquipoPresenter implements EquipoPresenterContract {
  final EquipoContract _view;
  final DatabaseHelper _dbHelper;

  EquipoPresenter(this._view) : _dbHelper = DatabaseHelper();

  @override
  Future<void> loadData({required bool isTeamMode}) async {
    _view.showLoading();

    try {
      final datos = isTeamMode
          ? await _dbHelper.getEquipos()
          : await _dbHelper.getCompetidores();

      final competidores = await _dbHelper.getCompetidores();
      final eventos = await _dbHelper.getEventos();

      final datosOrdenados = List<Map<String, dynamic>>.from(datos);
      datosOrdenados.sort((a, b) {
        String nombreA = (a['nombre'] ?? '').toString().toLowerCase();
        String nombreB = (b['nombre'] ?? '').toString().toLowerCase();
        return nombreA.compareTo(nombreB);
      });

      _view.hideLoading();
      _view.updateDatos(datosOrdenados);
      _view.updateDatosFiltrados(datosOrdenados);
      _view.updateTodosLosCompetidores(competidores);
      _view.updateTodosLosEventos(eventos);
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al cargar datos: ${e.toString()}");
    }
  }

  @override
  void filterData(String query, List<Map<String, dynamic>> allData) {
    final sanitizedQuery = _sanitizeInput(query);
    
    if (sanitizedQuery.isEmpty) {
      _view.updateDatosFiltrados(allData);
      return;
    }

    final filtrados = allData.where((item) {
      final nombre = (item['nombre'] ?? '').toString().toLowerCase();
      final curso = (item['curso'] ?? '').toString().toLowerCase();
      return nombre.contains(sanitizedQuery.toLowerCase()) ||
          curso.contains(sanitizedQuery.toLowerCase());
    }).toList();

    _view.updateDatosFiltrados(filtrados);
  }

  @override
  Future<void> saveEquipo({
    required String nombre,
    required String curso,
    required String? evento,
    required List<int> integrantesIds,
    int? id,
  }) async {
    final sanitizedNombre = _sanitizeInput(nombre);
    final sanitizedCurso = _sanitizeInput(curso);

    if (sanitizedNombre.isEmpty) {
      _view.showError("El nombre del equipo es obligatorio");
      return;
    }

    if (!_validarNombre(sanitizedNombre)) {
      _view.showError("El nombre solo puede contener letras, números y espacios (2-30 caracteres)");
      return;
    }

    if (sanitizedCurso.isEmpty) {
      _view.showError("El curso es obligatorio");
      return;
    }

    if (!_validarCurso(sanitizedCurso)) {
      _view.showError("El curso solo puede contener letras, números y guiones (2-20 caracteres)");
      return;
    }

    final validacion = await _dbHelper.validarComposicionEquipo(integrantesIds);
    if (!(validacion['valido'] as bool)) {
      _view.showError(validacion['mensaje'].toString());
      return;
    }

    _view.showLoading();

    try {
      final data = {
        'nombre': sanitizedNombre,
        'curso': sanitizedCurso,
        'evento': evento ?? '-',
        'evaluacion_gral': '-',
        'posicion': '-',
      };

      if (id == null) {
        int resultado = await _dbHelper.insertEquipo(data, integrantesIds);
        _view.hideLoading();

        if (resultado > 0) {
          _view.showSuccess("Equipo creado exitosamente");
        } else {
          _view.showError("Error al guardar el equipo");
        }
      } else {
        final dataConId = Map<String, dynamic>.from(data);
        dataConId['id'] = id;
        await _dbHelper.updateEquipo(dataConId, integrantesIds);
        _view.hideLoading();
        _view.showSuccess("Equipo actualizado exitosamente");
      }
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al guardar equipo: ${e.toString()}");
    }
  }

  @override
  Future<void> saveCompetidor({
    required String nombre,
    required String curso,
    required String sexo,
    required String? evento,
    int? id,
  }) async {
    final sanitizedNombre = _sanitizeInput(nombre);
    final sanitizedCurso = _sanitizeInput(curso);

    if (sanitizedNombre.isEmpty) {
      _view.showError("El nombre del competidor es obligatorio");
      return;
    }

    if (!_validarNombreCompetidor(sanitizedNombre)) {
      _view.showError("El nombre solo puede contener letras y espacios (2-50 caracteres)");
      return;
    }

    if (sanitizedCurso.isEmpty) {
      _view.showError("El curso es obligatorio");
      return;
    }

    if (!_validarCurso(sanitizedCurso)) {
      _view.showError("El curso solo puede contener letras, números y guiones (2-20 caracteres)");
      return;
    }

    _view.showLoading();

    try {
      final data = {
        'nombre': sanitizedNombre,
        'curso': sanitizedCurso,
        'sexo': sexo,
        'evento': evento ?? '-',
        'evaluacion_gral': '-',
        'evaluacion_ejercicios': '-',
        'posicion': '-',
        'ejercicios_participados': '-',
      };

      if (id == null) {
        int resultado = await _dbHelper.insertCompetidor(data);
        _view.hideLoading();

        if (resultado > 0) {
          _view.showSuccess("Competidor creado exitosamente");
        } else {
          _view.showError("Error al guardar el competidor");
        }
      } else {
        final dataConId = Map<String, dynamic>.from(data);
        dataConId['id'] = id;
        await _dbHelper.updateCompetidor(dataConId);
        _view.hideLoading();
        _view.showSuccess("Competidor actualizado exitosamente");
      }
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al guardar competidor: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteEquipo(int equipoId) async {
    _view.showLoading();

    try {
      final resultado = await _dbHelper.deleteEquipo(equipoId);

      _view.hideLoading();

      if (resultado > 0) {
        _view.showSuccess("Equipo eliminado exitosamente");
      } else {
        _view.showError("Error al eliminar el equipo");
      }
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al eliminar equipo: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteCompetidor(int competidorId) async {
    _view.showLoading();

    try {
      final resultado = await _dbHelper.deleteCompetidor(competidorId);

      _view.hideLoading();

      if (resultado > 0) {
        _view.showSuccess("Competidor eliminado exitosamente");
      } else {
        _view.showError("Error al eliminar el competidor");
      }
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al eliminar competidor: ${e.toString()}");
    }
  }

  @override
  Future<Map<String, dynamic>> getResumenCompetidor(int competidorId) async {
    try {
      return await _dbHelper.getResumenCompetidor(competidorId);
    } catch (e) {
      _view.showError("Error al obtener resumen: ${e.toString()}");
      return {};
    }
  }

  @override
  Future<Map<String, dynamic>> getResumenEquipo(int equipoId) async {
    try {
      return await _dbHelper.getResumenEquipo(equipoId);
    } catch (e) {
      _view.showError("Error al obtener resumen: ${e.toString()}");
      return {};
    }
  }

  @override
  void showForm({Map<String, dynamic>? item}) {
    _view.showFormDialog(item: item);
  }

  @override
  void showFicha(Map<String, dynamic> item, bool isTeamMode) {
    _view.showFichaDialog(item);
  }

  @override
  void requestDelete(Map<String, dynamic> item, bool isTeamMode) {
    _view.showDeleteConfirmation(item);
  }

  @override
  void dispose() {
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

  bool _validarNombre(String nombre) {
    if (nombre.length < 2 || nombre.length > 30) return false;
    if (!RegExp(r'^[A-ZÁÉÍÓÚÑ]').hasMatch(nombre)) return false;
    return RegExp(r'^[A-ZÁÉÍÓÚÑ][a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s]*$').hasMatch(nombre);
  }

  bool _validarNombreCompetidor(String nombre) {
    if (nombre.length < 2 || nombre.length > 50) return false;
    if (!RegExp(r'^[A-ZÁÉÍÓÚÑ]').hasMatch(nombre)) return false;
    return RegExp(r'^[A-ZÁÉÍÓÚÑ][a-zA-ZáéíóúÁÉÍÓÚñÑ\s]*$').hasMatch(nombre);
  }

  bool _validarCurso(String curso) {
    return RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\-]{2,20}$').hasMatch(curso);
  }
}
