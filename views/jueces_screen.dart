import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/ejercicio_model.dart';
import '../presenters/jueces_presenter.dart';
import '../contracts/jueces_contract.dart';
import '../widgets/common_widgets.dart';

class JuecesScreen extends StatefulWidget {
  const JuecesScreen({super.key});

  @override
  State<JuecesScreen> createState() => _JuecesScreenState();
}

class _JuecesScreenState extends State<JuecesScreen> implements JuecesContract {
  late JuecesPresenter _presenter;
  // ignore: unused_field
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Map<String, dynamic>> _pendientes = [];
  List<Map<String, dynamic>> _recientes = [];
  List<Map<String, dynamic>> _equipos = [];
  String? _equipoSeleccionado;
  List<Map<String, dynamic>> _pendientesFiltrados = [];
  // ignore: unused_field
  bool _isLoading = false;

  /// true cuando ya se evaluó a alguien del equipo pero no a todos
  bool _equipoBloqueado = false;

  @override
  void initState() {
    super.initState();
    _presenter = JuecesPresenter(this);
    _presenter.loadData();
  }

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  // Implementación de JuecesContract.View
  @override
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void updatePendientes(List<Map<String, dynamic>> pendientes) {
    if (mounted) {
      setState(() => _pendientes = pendientes);
      if (_equipoSeleccionado != null && _equipoSeleccionado != 'Todos') {
        // Ya hay equipo seleccionado: re-aplicar filtro y verificar bloqueo
        _aplicarFiltro();
        _evaluarBloqueoEquipo(_equipoSeleccionado!);
      } else {
        // Sin equipo seleccionado: detectar si hay uno con evaluación parcial
        _autoDetectarEquipoParcial();
      }
    }
  }

  /// Al iniciar, si hay un equipo con evaluación en curso lo selecciona
  /// automáticamente y lo bloquea para que el juez continúe con él.
  Future<void> _autoDetectarEquipoParcial() async {
    final equipoParcial = await _presenter.getEquipoConEvaluacionParcial();
    if (!mounted) return;
    if (equipoParcial != null) {
      setState(() {
        _equipoSeleccionado = equipoParcial;
        _equipoBloqueado = true;
      });
      _aplicarFiltro();
    } else {
      setState(() => _pendientesFiltrados = []);
    }
  }

  @override
  void updatePendientesFiltrados(List<Map<String, dynamic>> filtrados) {
    if (mounted) setState(() => _pendientesFiltrados = filtrados);
  }

  @override
  void updateRecientes(List<Map<String, dynamic>> recientes) {
    if (mounted) setState(() => _recientes = recientes);
  }

  @override
  void updateEquipos(List<Map<String, dynamic>> equipos) {
    if (mounted) {
      // Si el equipo seleccionado ya no existe en la lista, resetear
      final nombres = equipos.map((e) => e['nombre'].toString()).toSet();
      setState(() {
        _equipos = equipos;
        if (_equipoSeleccionado != null &&
            !nombres.contains(_equipoSeleccionado)) {
          _equipoSeleccionado = null;
          _equipoBloqueado = false;
          _pendientesFiltrados = [];
        }
      });
    }
  }

  @override
  void showEvaluacionDialog(
    Map<String, dynamic> competidor,
    List<dynamic> ejercicios,
  ) {
    _abrirEvaluacion(competidor, ejercicios as List<Ejercicio>);
  }

  @override
  void showRankingDialog(
    int competidorId,
    String nombreCompetidor,
    List<Map<String, dynamic>> posiciones,
  ) {
    _mostrarRankingDialog(competidorId, nombreCompetidor, posiciones);
  }

  @override
  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  void showError(String message) {
    if (!mounted) return;
    MessageOverlay.showError(context, message);
  }

  // Métodos auxiliares
  Future<void> _cargarDatos() async {
    await _presenter.loadData();
  }

  void _aplicarFiltro() {
    _presenter.filterByEquipo(_equipoSeleccionado, _pendientes);
  }

  /// Verifica si el equipo tiene evaluados parciales y actualiza el bloqueo
  Future<void> _evaluarBloqueoEquipo(String equipoNombre) async {
    final tieneEvaluados = await _presenter.equipoTieneEvaluados(equipoNombre);
    final completamenteEvaluado = await _presenter.equipoCompletamenteEvaluado(
      equipoNombre,
    );
    if (!mounted) return;
    setState(() {
      _equipoBloqueado = tieneEvaluados && !completamenteEvaluado;
    });
  }

  /// Maneja el cambio de equipo respetando el bloqueo
  Future<void> _onEquipoChanged(String? nuevoEquipo) async {
    if (_equipoBloqueado) {
      showError(
        "Debes evaluar a todos los competidores del equipo actual antes de cambiar de equipo.",
      );
      return;
    }
    setState(() {
      _equipoSeleccionado = nuevoEquipo;
      if (nuevoEquipo == null || nuevoEquipo == 'Todos') {
        _pendientesFiltrados = [];
      }
    });
    if (nuevoEquipo != null && nuevoEquipo != 'Todos') {
      _aplicarFiltro();
      await _evaluarBloqueoEquipo(nuevoEquipo);
    }
  }

  // 📝 DIÁLOGO DE EVALUACIÓN CON DISEÑO MEJORADO
  void _abrirEvaluacion(
    Map<String, dynamic> comp,
    List<Ejercicio> ejerciciosDelEvento,
  ) async {
    // Controladores para los puntos de cada ejercicio
    Map<String, TextEditingController> controllers = {
      for (var ej in ejerciciosDelEvento) ej.nombre: TextEditingController(),
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.white],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🎯 Encabezado moderno
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade400,
                      Colors.blue.shade400,
                    ], //Fondo de cuadro detalle de ejercicio
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.edit_note,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Evaluar competidor",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comp['nombre'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 📊 Información del competidor
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white,
                    ], //Fondo de cuadro detalle de ejercicio
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Evento: ${comp['evento'] ?? 'General'}",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.group,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Equipo: ${comp['nombre_equipo'] ?? 'Sin equipo'}",
                          style: TextStyle(color: Colors.blue, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 📋 Formulario de ejercicios
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            color: Colors.deepOrange.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Ejercicios del evento (${ejerciciosDelEvento.length})",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ...ejerciciosDelEvento.map(
                        (ej) => Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ej.nombre,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors
                                      .blue
                                      .shade100, //recuadro q dice eliminatoria
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: controllers[ej.nombre],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: "Puntos ",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔘 Botones de acción
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white38),
                          ),
                        ),
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Recopilar puntajes
                          Map<String, double> puntajes = {};
                          List<String> nombresEjercicios = [];

                          controllers.forEach((ejercicio, ctrl) {
                            double puntos = double.tryParse(ctrl.text) ?? 0;
                            puntajes[ejercicio] = puntos;
                            nombresEjercicios.add(ejercicio);
                          });

                          Navigator.pop(context);

                          // Guardar evaluación a través del presentador
                          await _presenter.saveEvaluacion(
                            competidorId: comp['id'],
                            puntajes: puntajes,
                            ejercicios: nombresEjercicios,
                          );

                          // Mostrar ranking
                          await _presenter.showRankingAfterSave(
                            competidorId: comp['id'],
                            nombreCompetidor: comp['nombre'],
                            ejercicios: nombresEjercicios,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade200,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Guardar",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // DIÁLOGO DE RANKING
  void _mostrarRankingDialog(
    int competidorId,
    String nombreCompetidor,
    List<Map<String, dynamic>> posiciones,
  ) {
    final pos = posiciones.isNotEmpty ? posiciones.first : null;
    final posicion = pos != null ? (pos['posicion'] ?? 0) as int : 0;
    final puntaje = pos != null
        ? ((pos['puntaje'] as num?)?.toDouble() ?? 0.0)
        : 0.0;

    Color colorPosicion;
    IconData? iconoMedalla;
    if (posicion == 1) {
      colorPosicion = const Color(0xFFFFD700);
      iconoMedalla = Icons.workspace_premium;
    } else if (posicion == 2) {
      colorPosicion = const Color(0xFFC0C0C0);
      iconoMedalla = Icons.workspace_premium;
    } else if (posicion == 3) {
      colorPosicion = const Color(0xFFCD7F32);
      iconoMedalla = Icons.workspace_premium;
    } else {
      colorPosicion = Colors.orange.shade300;
      iconoMedalla = null;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Encabezado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepOrange.shade400,
                      Colors.deepOrange.shade600,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ranking del competidor",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nombreCompetidor,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido
              Padding(
                padding: const EdgeInsets.all(24),
                child: pos == null
                    ? Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Sin posición disponible",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                    : Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorPosicion.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: colorPosicion.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Círculo posición
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: colorPosicion,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: iconoMedalla != null
                                    ? Icon(
                                        iconoMedalla,
                                        color: Colors.white,
                                        size: 30,
                                      )
                                    : Text(
                                        '$posicion',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Puntaje
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Puntaje total",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${puntaje.toStringAsFixed(1)} pts",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (posicion <= 3)
                              Text(
                                posicion == 1
                                    ? '🥇'
                                    : posicion == 2
                                    ? '🥈'
                                    : '🥉',
                                style: const TextStyle(fontSize: 36),
                              ),
                          ],
                        ),
                      ),
              ),

              // Botón cerrar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "CERRAR",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.assignment_turned_in, color: Colors.deepOrange),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Panel de Jueces",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "UCIFitness",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarDatos,
            tooltip: "Actualizar",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildEquipoSelector(),
            const SizedBox(height: 20),

            // Pendientes SOLO cuando hay equipo seleccionado
            if (_equipoSeleccionado != null &&
                _equipoSeleccionado != 'Todos') ...[
              _buildSeccionTitulo("EVALUACIONES PENDIENTES"),
              const SizedBox(height: 10),
              if (_pendientesFiltrados.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      "No hay evaluaciones pendientes para este equipo",
                      style: TextStyle(
                        color: Colors.white54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              else
                ..._pendientesFiltrados.map(
                  (c) => _buildCardCompetidor(c, true),
                ),
              const SizedBox(height: 30),
            ],

            _buildSeccionTitulo("RECIENTES"),
            const SizedBox(height: 10),
            if (_recientes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    "No hay evaluaciones recientes",
                    style: TextStyle(
                      color: Colors.white54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ..._recientes.map((c) => _buildCardCompetidor(c, false)),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            color: _equipoBloqueado
                ? Colors.orange.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _equipoBloqueado ? Colors.orange.shade300 : Colors.white24,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _equipoBloqueado ? Icons.lock : Icons.filter_list,
                color: _equipoBloqueado ? Colors.orange : Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                "Equipo a evaluar:",
                style: TextStyle(
                  color: _equipoBloqueado ? Colors.orange : Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _equipoSeleccionado,
                    isExpanded: true,
                    dropdownColor: const Color.fromARGB(232, 255, 255, 255),
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 14,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: _equipoBloqueado
                          ? Colors.orange.shade300
                          : Colors.white70,
                    ),
                    hint: const Text(
                      "Selecciona un equipo",
                      style: TextStyle(color: Colors.white70),
                    ),
                    items: _equipos.map((equipo) {
                      return DropdownMenuItem<String>(
                        value: equipo['nombre'].toString(),
                        child: Text(equipo['nombre'].toString()),
                      );
                    }).toList(),
                    onChanged: (value) => _onEquipoChanged(value),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Aviso de bloqueo
        if (_equipoBloqueado)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange.shade300,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Debes evaluar a todos los competidores de este equipo antes de cambiar.",
                    style: TextStyle(
                      color: Colors.orange.shade300,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Instrucción inicial — solo un texto corto sin overflow
        if (_equipoSeleccionado == null)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 4),
            child: Text(
              "↑  Selecciona un equipo",
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildSeccionTitulo(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildCardCompetidor(Map<String, dynamic> c, bool esPendiente) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: esPendiente
                  ? Colors.orange.withValues(alpha: 0.2)
                  : Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              esPendiente ? Icons.pending_actions : Icons.check_circle,
              color: esPendiente ? Colors.orange : Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c['nombre'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A5F7A),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Equipo: ${c['nombre_equipo'] ?? 'Sin equipo'}",
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  esPendiente
                      ? "Evento: ${c['evento'] ?? 'Sin evento'}"
                      : c['evaluacion_ejercicios'] ?? 'Sin detalles',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (esPendiente)
            ElevatedButton.icon(
              onPressed: () => _presenter.openEvaluacion(c),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.edit, size: 18, color: Colors.white),
              label: const Text(
                "Evaluar",
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            Column(
              children: [
                Text(
                  c['evaluacion_gral'] ?? '0',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const Text(
                  "pts",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
