/// Contrato para la pantalla de Jueces
/// Define los métodos que debe implementar la vista y el presentador
abstract class JuecesContract {
  /// Interfaz de la Vista

  /// Muestra un indicador de carga
  void showLoading();

  /// Oculta el indicador de carga
  void hideLoading();

  /// Actualiza la lista de evaluaciones pendientes
  void updatePendientes(List<Map<String, dynamic>> pendientes);

  /// Actualiza la lista de evaluaciones pendientes filtradas
  void updatePendientesFiltrados(List<Map<String, dynamic>> filtrados);

  /// Actualiza la lista de evaluaciones recientes
  void updateRecientes(List<Map<String, dynamic>> recientes);

  /// Actualiza la lista de equipos
  void updateEquipos(List<Map<String, dynamic>> equipos);

  /// Muestra el diálogo de evaluación para un competidor
  void showEvaluacionDialog(
    Map<String, dynamic> competidor,
    List<dynamic> ejercicios,
  );

  /// Muestra el diálogo con el ranking del competidor
  void showRankingDialog(
    int competidorId,
    String nombreCompetidor,
    List<Map<String, dynamic>> posiciones,
  );

  /// Muestra un mensaje
  void showMessage(String message);

  /// Muestra un mensaje de éxito
  void showSuccess(String message);

  /// Muestra un mensaje de error
  void showError(String message);
}

/// Interfaz del Presentador
abstract class Presenter {
  /// Carga todos los datos necesarios
  Future<void> loadData();

  /// Filtra las evaluaciones pendientes por equipo
  void filterByEquipo(
    String? equipoNombre,
    List<Map<String, dynamic>> allPendientes,
  );

  /// Abre el diálogo de evaluación para un competidor
  Future<void> openEvaluacion(Map<String, dynamic> competidor);

  /// Guarda la evaluación de un competidor
  Future<void> saveEvaluacion({
    required int competidorId,
    required Map<String, double> puntajes,
    required List<String> ejercicios,
  });

  /// Obtiene el ranking de un competidor en sus ejercicios
  Future<List<Map<String, dynamic>>> getRankingCompetidor({
    required int competidorId,
    required List<String> ejercicios,
  });

  /// Muestra el ranking después de guardar evaluación
  Future<void> showRankingAfterSave({
    required int competidorId,
    required String nombreCompetidor,
    required List<String> ejercicios,
  });

  /// Limpia recursos del presentador
  void dispose();
}
