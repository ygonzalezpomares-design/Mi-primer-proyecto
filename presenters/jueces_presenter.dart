import '../database_helper.dart';
import '../contracts/jueces_contract.dart';

/// Presentador para la pantalla de Jueces
/// Maneja la lógica de negocio de evaluaciones y calificaciones
class JuecesPresenter implements Presenter {
  final JuecesContract _view;
  final DatabaseHelper _dbHelper;

  JuecesPresenter(this._view) : _dbHelper = DatabaseHelper();

  @override
  Future<void> loadData() async {
    _view.showLoading();

    try {
      final pendientes = await _dbHelper.getEvaluacionesPendientes();
      final recientes = await _dbHelper.getEvaluacionesRecientes();
      final equipos = await _dbHelper.getEquipos();

      _view.hideLoading();
      _view.updatePendientes(pendientes);
      // No llamamos updatePendientesFiltrados aquí:
      // la screen re-aplica el filtro activo al recibir updatePendientes
      _view.updateRecientes(recientes);
      _view.updateEquipos(equipos);
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al cargar datos: ${e.toString()}");
    }
  }

  @override
  void filterByEquipo(
    String? equipoNombre,
    List<Map<String, dynamic>> allPendientes,
  ) {
    if (equipoNombre == null || equipoNombre == 'Todos') {
      _view.updatePendientesFiltrados(allPendientes);
      return;
    }

    final filtrados = allPendientes.where((comp) {
      return comp['nombre_equipo'] == equipoNombre;
    }).toList();

    _view.updatePendientesFiltrados(filtrados);
  }

  /// Detecta al iniciar si hay un equipo con evaluación parcial en curso.
  /// Devuelve el nombre del equipo o null si no hay ninguno.
  Future<String?> getEquipoConEvaluacionParcial() async {
    try {
      final db = await _dbHelper.database;
      // Equipos que tienen AL MENOS un competidor evaluado
      final conEvaluados = await db.rawQuery('''
        SELECT DISTINCT e.nombre FROM equipos e
        JOIN equipo_integrantes ei ON e.id = ei.equipo_id
        JOIN competidores c ON c.id = ei.competidor_id
        WHERE c.evaluacion_ejercicios != '-'
          AND c.evaluacion_ejercicios IS NOT NULL
          AND c.evaluacion_ejercicios != ''
      ''');
      for (final row in conEvaluados) {
        final nombre = row['nombre'] as String;
        final completo = await equipoCompletamenteEvaluado(nombre);
        if (!completo) return nombre; // Parcialmente evaluado
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Verifica si el equipo tiene al menos un competidor ya evaluado
  Future<bool> equipoTieneEvaluados(String equipoNombre) async {
    try {
      // ignore: unused_local_variable
      final recientes = await _dbHelper.getEvaluacionesRecientes();
      // getEvaluacionesRecientes solo trae los últimos 5, así que usamos pendientes + recientes
      // Mejor: verificar en todos los competidores del equipo
      // ignore: unused_local_variable
      final todos = await _dbHelper.getEvaluacionesPendientes();
      // Los evaluados son los que NO están en pendientes
      // Necesitamos consultar todos los competidores del equipo
      return await _equipoTieneAlgunEvaluado(equipoNombre);
    } catch (e) {
      return false;
    }
  }

  Future<bool> _equipoTieneAlgunEvaluado(String equipoNombre) async {
    try {
      // Buscar competidores del equipo que YA fueron evaluados
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        '''
        SELECT c.id FROM competidores c
        LEFT JOIN equipo_integrantes ei ON c.id = ei.competidor_id
        LEFT JOIN equipos e ON ei.equipo_id = e.id
        WHERE e.nombre = ?
          AND c.evaluacion_ejercicios != '-'
          AND c.evaluacion_ejercicios IS NOT NULL
          AND c.evaluacion_ejercicios != ''
        LIMIT 1
      ''',
        [equipoNombre],
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si TODOS los competidores del equipo ya fueron evaluados
  Future<bool> equipoCompletamenteEvaluado(String equipoNombre) async {
    try {
      final db = await _dbHelper.database;

      // Total de competidores del equipo
      final total = await db.rawQuery(
        '''
        SELECT COUNT(*) as cnt FROM competidores c
        LEFT JOIN equipo_integrantes ei ON c.id = ei.competidor_id
        LEFT JOIN equipos e ON ei.equipo_id = e.id
        WHERE e.nombre = ?
      ''',
        [equipoNombre],
      );

      // Evaluados del equipo
      final evaluados = await db.rawQuery(
        '''
        SELECT COUNT(*) as cnt FROM competidores c
        LEFT JOIN equipo_integrantes ei ON c.id = ei.competidor_id
        LEFT JOIN equipos e ON ei.equipo_id = e.id
        WHERE e.nombre = ?
          AND c.evaluacion_ejercicios != '-'
          AND c.evaluacion_ejercicios IS NOT NULL
          AND c.evaluacion_ejercicios != ''
      ''',
        [equipoNombre],
      );

      final totalCnt = (total.first['cnt'] as int?) ?? 0;
      final evaluadosCnt = (evaluados.first['cnt'] as int?) ?? 0;

      return totalCnt > 0 && totalCnt == evaluadosCnt;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> openEvaluacion(Map<String, dynamic> competidor) async {
    try {
      // Obtener los ejercicios del evento del equipo del competidor
      final ejercicios = await _dbHelper.getEjerciciosDeCompetidor(
        competidor['id'],
      );

      if (ejercicios.isEmpty) {
        _view.showError(
          "Este competidor no tiene ejercicios del evento (sin equipo o equipo sin evento)",
        );
        return;
      }

      _view.showEvaluacionDialog(competidor, ejercicios);
    } catch (e) {
      _view.showError("Error al abrir evaluación: ${e.toString()}");
    }
  }

  @override
  Future<void> saveEvaluacion({
    required int competidorId,
    required Map<String, double> puntajes,
    required List<String> ejercicios,
  }) async {
    _view.showLoading();

    try {
      // Calcular suma total de TODOS los ejercicios
      double sumaTotal = 0.0;
      List<String> detalles = [];

      for (final entry in puntajes.entries) {
        sumaTotal += entry.value;
        detalles.add("${entry.key}: ${entry.value}");
      }

      // Guardar en la base de datos — sin incluir 'id' dentro del mapa de datos
      final db = await _dbHelper.database;
      await db.update(
        'competidores',
        {
          'evaluacion_ejercicios': detalles.join(" | "),
          'evaluacion_gral': sumaTotal.toString(),
          'ejercicios_participados': ejercicios.join(', '),
        },
        where: 'id = ?',
        whereArgs: [competidorId],
      );

      _view.hideLoading();
      _view.showSuccess("Evaluación guardada exitosamente");

      // Recargar datos
      await loadData();
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al guardar evaluación: ${e.toString()}");
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRankingCompetidor({
    required int competidorId,
    required List<String> ejercicios,
  }) async {
    try {
      final db = await _dbHelper.database;

      // Leer evaluacion_gral, evento y sexo directamente
      final compResult = await db.query(
        'competidores',
        columns: ['evaluacion_gral', 'evento', 'sexo'],
        where: 'id = ?',
        whereArgs: [competidorId],
      );

      if (compResult.isEmpty) return [];

      final evalGral = compResult.first['evaluacion_gral']?.toString() ?? '0';
      final puntajeTotal = double.tryParse(evalGral) ?? 0.0;
      final evento = compResult.first['evento']?.toString();
      final sexo = compResult.first['sexo']?.toString();

      // Ranking general filtrado por evento y sexo
      final ranking = await _dbHelper.getRankingGeneralCompetidores(
        evento: (evento == null || evento == '-' || evento.isEmpty)
            ? null
            : evento,
        sexo: (sexo == null || sexo == '-' || sexo.isEmpty) ? null : sexo,
      );

      int posicionGeneral = 0;
      for (final entry in ranking) {
        if (entry['id'] == competidorId) {
          posicionGeneral = entry['posicion_general'] as int;
          break;
        }
      }

      // Si no encontró posición en el ranking filtrado, intentar sin filtros
      if (posicionGeneral == 0) {
        final rankingGlobal = await _dbHelper.getRankingGeneralCompetidores();
        for (final entry in rankingGlobal) {
          if (entry['id'] == competidorId) {
            posicionGeneral = entry['posicion_general'] as int;
            break;
          }
        }
      }

      if (posicionGeneral == 0 || puntajeTotal == 0.0) return [];

      return [
        {
          'ejercicio': 'Puntuación Total',
          'posicion': posicionGeneral,
          'puntaje': puntajeTotal,
        },
      ];
    } catch (e) {
      _view.showError("Error al obtener ranking: ${e.toString()}");
      return [];
    }
  }

  @override
  Future<void> showRankingAfterSave({
    required int competidorId,
    required String nombreCompetidor,
    required List<String> ejercicios,
  }) async {
    try {
      final posiciones = await getRankingCompetidor(
        competidorId: competidorId,
        ejercicios: ejercicios,
      );

      _view.showRankingDialog(competidorId, nombreCompetidor, posiciones);
    } catch (e) {
      _view.showError("Error al mostrar ranking: ${e.toString()}");
    }
  }

  @override
  void dispose() {
    // Limpiar recursos si es necesario
  }
}
