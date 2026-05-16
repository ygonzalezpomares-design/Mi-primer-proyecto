// Contrato para la pantalla de Ejercicios
// Define los métodos que debe implementar la vista y el presentador

// Interfaz de la Vista
abstract class EjerciciosContract {
  /// Muestra un indicador de carga
  void showLoading();

  /// Oculta el indicador de carga
  void hideLoading();

  /// Actualiza la lista de ejercicios
  void updateEjercicios(List<Map<String, dynamic>> ejercicios);

  /// Actualiza la lista de eventos
  void updateEventos(List<Map<String, dynamic>> eventos);

  /// Actualiza la lista de equipos
  void updateEquipos(List<Map<String, dynamic>> equipos);

  /// Muestra el diálogo de detalles de un ejercicio
  void showEjercicioDetails(Map<String, dynamic> ejercicio);

  /// Muestra el formulario para crear/editar ejercicio
  void showEjercicioForm({Map<String, dynamic>? ejercicio});

  /// Muestra el diálogo de confirmación de eliminación
  void showDeleteConfirmation(Map<String, dynamic> ejercicio);

  /// Muestra el diálogo de detalles de un evento
  void showEventoDetails(Map<String, dynamic> evento);

  /// Muestra un mensaje
  void showMessage(String message);

  /// Muestra un mensaje de éxito
  void showSuccess(String message);

  /// Muestra un mensaje de error
  void showError(String message);
}

/// Interfaz del Presentador
abstract class EjerciciosPresenterContract {
  /// Carga todos los datos necesarios
  Future<void> loadData();

  /// Carga solo los ejercicios
  Future<void> loadEjercicios();

  /// Carga solo los eventos
  Future<void> loadEventos();

  /// Carga solo los equipos
  Future<void> loadEquipos();

  /// Crea o actualiza un ejercicio
  Future<void> saveEjercicio({
    required String nombre,
    required String clasificacion,
    required List<String> participantesIds,
    int? id,
  });

  /// Elimina un ejercicio
  Future<void> deleteEjercicio(int ejercicioId);

  /// Actualiza la asignación de ejercicios y equipos a un evento
  Future<void> updateEventoAsignaciones({
    required int eventoId,
    required List<int> ejerciciosIds,
    required List<int> equiposIds,
  });

  /// Muestra los detalles de un ejercicio
  void showEjercicioDetails(Map<String, dynamic> ejercicio);

  /// Muestra los detalles de un evento
  void showEventoDetails(Map<String, dynamic> evento);

  /// Solicita confirmación para eliminar un ejercicio
  void requestDeleteEjercicio(Map<String, dynamic> ejercicio);

  /// Muestra el formulario de ejercicio
  void showEjercicioForm({Map<String, dynamic>? ejercicio});

  /// Traduce IDs de ejercicios a nombres
  String translateEjerciciosIdsToNames(String? idsString);

  /// Traduce IDs de equipos a nombres
  String translateEquiposIdsToNames(String? idsString);

  /// Limpia recursos del presentador
  void dispose();
}
