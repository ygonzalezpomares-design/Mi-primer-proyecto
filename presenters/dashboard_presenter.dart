import '../database_helper.dart';
import '../contracts/dashboard_contract.dart';

/// Presentador para la pantalla de Dashboard
/// Maneja la lógica de negocio del dashboard
class DashboardPresenter implements Presenter {
  final DashboardContract _view;
  final DatabaseHelper _dbHelper;

  DashboardPresenter(this._view) : _dbHelper = DatabaseHelper();

  @override
  Future<void> loadData() async {
    _view.showLoading();

    try {
      // Cargar estadísticas
      final competidores = await _dbHelper.getCompetidores();
      final equipos = await _dbHelper.getEquipos();
      final ejercicios = await _dbHelper.getEjercicios();
      final evaluados = await _dbHelper.getEvaluacionesRecientes();

      // Cargar eventos
      final eventos = await _dbHelper.getEventos();

      _view.updateEstadisticas(
        totalCompetidores: competidores.length,
        totalEquipos: equipos.length,
        totalEjercicios: ejercicios.length,
        totalEvaluados: evaluados.length,
      );

      _view.updateEventos(eventos);
      _view.hideLoading();
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al cargar datos: ${e.toString()}");
    }
  }

  @override
  Future<void> loadRankings({
    required String? evento,
    required String sexo,
    required bool mostrandoEquipos,
  }) async {
    if (evento == null) return;

    try {
      if (mostrandoEquipos) {
        // Cargar ranking de equipos (sin filtro de sexo)
        final rankingEquipos = await _dbHelper.getRankingGeneralEquipos(
          evento: evento,
        );
        _view.updateRankingEquipos(rankingEquipos);
      } else {
        // Determinar el valor del filtro de sexo para competidores
        String? filtroSexo;
        if (sexo == 'Masculino') {
          filtroSexo = 'M';
        } else if (sexo == 'Femenino') {
          filtroSexo = 'F';
        }

        // Cargar ranking de competidores con filtro de sexo
        final rankingCompetidores = await _dbHelper
            .getRankingGeneralCompetidores(evento: evento, sexo: filtroSexo);
        _view.updateRankingCompetidores(rankingCompetidores);
      }
    } catch (e) {
      _view.showError("Error al cargar rankings: ${e.toString()}");
    }
  }

  @override
  Future<void> refreshData() async {
    await loadData();
  }

  @override
  void dispose() {
    // Limpiar recursos si es necesario
  }
}
