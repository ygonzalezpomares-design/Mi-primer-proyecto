/// Contrato para la pantalla de Dashboard
/// Define los métodos que debe implementar la vista y el presentador
abstract class DashboardContract {
  /// Interfaz de la Vista
  /// Muestra un indicador de carga
  void showLoading();

  /// Oculta el indicador de carga
  void hideLoading();

  /// Actualiza las estadísticas generales
  void updateEstadisticas({
    required int totalCompetidores,
    required int totalEquipos,
    required int totalEjercicios,
    required int totalEvaluados,
  });

  /// Actualiza la lista de eventos
  void updateEventos(List<Map<String, dynamic>> eventos);

  /// Actualiza el ranking de competidores
  void updateRankingCompetidores(List<Map<String, dynamic>> ranking);

  /// Actualiza el ranking de equipos
  void updateRankingEquipos(List<Map<String, dynamic>> ranking);

  /// Muestra un mensaje de error
  void showError(String message);
}

/// Interfaz del Presentador
abstract class Presenter {
  /// Carga todos los datos del dashboard
  Future<void> loadData();

  /// Carga los rankings según el evento y filtros seleccionados
  Future<void> loadRankings({
    required String? evento,
    required String sexo,
    required bool mostrandoEquipos,
  });

  /// Refresca todos los datos
  Future<void> refreshData();

  /// Limpia recursos del presentador
  void dispose();
}
