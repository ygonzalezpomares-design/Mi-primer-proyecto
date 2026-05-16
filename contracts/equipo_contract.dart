// Contrato para la pantalla de Equipos
// Define los métodos que debe implementar la vista y el presentador

// Interfaz de la Vista
abstract class EquipoContract {
  /// Muestra un indicador de carga
  void showLoading();

  /// Oculta el indicador de carga
  void hideLoading();

  /// Actualiza la lista de datos (equipos o competidores)
  void updateDatos(List<Map<String, dynamic>> datos);

  /// Actualiza la lista de datos filtrados
  void updateDatosFiltrados(List<Map<String, dynamic>> datosFiltrados);

  /// Actualiza la lista de todos los competidores
  void updateTodosLosCompetidores(List<Map<String, dynamic>> competidores);

  /// Actualiza la lista de todos los eventos
  void updateTodosLosEventos(List<Map<String, dynamic>> eventos);

  /// Muestra el formulario para crear/editar equipo o competidor
  void showFormDialog({Map<String, dynamic>? item});

  /// Muestra la ficha de detalles con resumen
  void showFichaDialog(Map<String, dynamic> item);

  /// Muestra el diálogo de confirmación de eliminación
  void showDeleteConfirmation(Map<String, dynamic> item);

  /// Muestra un mensaje
  void showMessage(String message);

  /// Muestra un mensaje de éxito
  void showSuccess(String message);

  /// Muestra un mensaje de error
  void showError(String message);
}

/// Interfaz del Presentador
abstract class EquipoPresenterContract {
  /// Carga todos los datos necesarios
  Future<void> loadData({required bool isTeamMode});

  /// Filtra los datos según un texto de búsqueda
  void filterData(String query, List<Map<String, dynamic>> allData);

  /// Guarda un equipo (crear o actualizar)
  Future<void> saveEquipo({
    required String nombre,
    required String curso,
    required String? evento,
    required List<int> integrantesIds,
    int? id,
  });

  /// Guarda un competidor (crear o actualizar)
  Future<void> saveCompetidor({
    required String nombre,
    required String curso,
    required String sexo,
    required String? evento,
    int? id,
  });

  /// Elimina un equipo
  Future<void> deleteEquipo(int equipoId);

  /// Elimina un competidor
  Future<void> deleteCompetidor(int competidorId);

  /// Obtiene el resumen de un competidor con sus ejercicios y puntajes
  Future<Map<String, dynamic>> getResumenCompetidor(int competidorId);

  /// Obtiene el resumen de un equipo con sus integrantes y puntajes
  Future<Map<String, dynamic>> getResumenEquipo(int equipoId);

  /// Muestra el formulario para crear/editar
  void showForm({Map<String, dynamic>? item});

  /// Muestra la ficha de detalles
  void showFicha(Map<String, dynamic> item, bool isTeamMode);

  /// Solicita confirmación para eliminar
  void requestDelete(Map<String, dynamic> item, bool isTeamMode);

  /// Limpia recursos del presentador
  void dispose();
}
