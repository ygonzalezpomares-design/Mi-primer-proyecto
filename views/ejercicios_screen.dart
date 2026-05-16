import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../presenters/ejercicios_presenter.dart';
import '../contracts/ejercicios_contract.dart';
import '../widgets/common_widgets.dart';

class EjerciciosScreen extends StatefulWidget {
  const EjerciciosScreen({super.key});

  @override
  State<EjerciciosScreen> createState() => _EjerciciosScreenState();
}

class _EjerciciosScreenState extends State<EjerciciosScreen>
    implements EjerciciosContract {
  late EjerciciosPresenter _presenter;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Map<String, dynamic>> _listaEjercicios = [];
  List<Map<String, dynamic>> _listaEventos = [];
  List<Map<String, dynamic>> _listaEquipos = [];
  final List<String> _filtros = ["Ejercicios", "Eventos"];

  String filtroActual = "Ejercicios";
  // ignore: unused_field
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _presenter = EjerciciosPresenter(this);
    _presenter.loadData();
  }

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  // Implementación de EjerciciosContract.View
  @override
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void updateEjercicios(List<Map<String, dynamic>> ejercicios) {
    if (mounted) setState(() => _listaEjercicios = ejercicios);
  }

  @override
  void updateEventos(List<Map<String, dynamic>> eventos) {
    if (mounted) setState(() => _listaEventos = eventos);
  }

  @override
  void updateEquipos(List<Map<String, dynamic>> equipos) {
    if (mounted) setState(() => _listaEquipos = equipos);
  }

  @override
  void showEjercicioDetails(Map<String, dynamic> ejercicio) {
    _verDetallesEjercicio(ejercicio);
  }

  @override
  void showEjercicioForm({Map<String, dynamic>? ejercicio}) {
    _mostrarFormulario(ejercicio: ejercicio);
  }

  @override
  void showDeleteConfirmation(Map<String, dynamic> ejercicio) {
    _confirmarYEliminarEjercicio(ejercicio);
  }

  @override
  void showEventoDetails(Map<String, dynamic> evento) {
    _verDetallesEvento(evento);
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

  void _verDetallesEjercicio(Map<String, dynamic> ej) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.white], //Fondo de ver ejercicio
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
              // Encabezado con icono
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepOrange.shade400,
                      Colors.deepOrange.shade400,
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
                        Icons.fitness_center,
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
                            "Detalle del ejercicio",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ej['nombre'],
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

              // 📊 Contenido
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card de Clasificación
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: Colors
                                .deepOrange
                                .shade300, //Fondo del icono en ver ejercicio
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Clasificación",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors
                              .deepOrange
                              .shade100, //recuadro q dice eliminatoria
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ej['clasificacion'],
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botón de cierre
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
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

  // --- FORMULARIO DE EDICIÓN / CREACIÓN - MEJORADO ---
  void _mostrarFormulario({Map<String, dynamic>? ejercicio}) async {
    TextEditingController nombreCtrl = TextEditingController(
      text: ejercicio?['nombre'] ?? "",
    );
    List<Map<String, dynamic>> eventosDisponibles = await _dbHelper
        .getEventos();
    String? clasificacionSeleccionada = ejercicio?['clasificacion'];
    if (clasificacionSeleccionada == null && eventosDisponibles.isNotEmpty) {
      clasificacionSeleccionada = eventosDisponibles.first['nombre'].toString();
    }
    // String nombreAnterior = ejercicio?['nombre'] ?? "";

    List<Map<String, dynamic>> todosLosComps = await _dbHelper
        .getCompetidores();
    List<String> seleccionados =
        ejercicio?['participantes'] != null &&
            ejercicio?['participantes'] != '-'
        ? ejercicio!['participantes'].toString().split(', ').toList()
        : [];

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
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
                // 🎯 Encabezado
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: ejercicio == null
                          ? [Colors.blue.shade400, Colors.blue.shade600]
                          : [Colors.blue.shade400, Colors.blue.shade600],
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
                        child: Icon(
                          ejercicio == null ? Icons.add_circle : Icons.edit,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        ejercicio == null
                            ? "Nuevo ejercicio"
                            : "Editar ejercicio",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // 📝 Formulario
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campo Nombre
                        const Text(
                          "Nombre del ejercicio",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .blue
                                .shade100, //recuadro nombre de ejercicio
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: nombreCtrl,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: "Ingrese el nombre",
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Dropdown Clasificación
                        const Text(
                          "Clasificación (Evento)",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color:
                                Colors.blue.shade100, //recuadro de eliminatoria
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButton<String>(
                            value: clasificacionSeleccionada,
                            isExpanded: true,
                            underline: const SizedBox(),
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                            ),
                            hint: const Text(
                              "Selecciona un evento",
                              style: TextStyle(color: Colors.grey),
                            ),
                            items: eventosDisponibles.map((ev) {
                              return DropdownMenuItem<String>(
                                value: ev['nombre'].toString(),
                                child: Text(ev['nombre'].toString()),
                              );
                            }).toList(),
                            onChanged: (v) => setDialogState(
                              () => clasificacionSeleccionada = v,
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
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            final nombre = nombreCtrl.text.trim();

                            bool validarNombreEjercicio(String n) {
                              if (n.length < 2 || n.length > 50) {
                                return false;
                              }
                              if (!RegExp(r'^[A-ZÁÉÍÓÚÑ]').hasMatch(n)) {
                                return false;
                              }
                              return RegExp(
                                r'^[A-ZÁÉÍÓÚÑ][a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s]*$',
                              ).hasMatch(n);
                            }

                            if (nombre.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: Colors.red.shade50,
                                  title: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_rounded,
                                        color: Colors.red,
                                        size: 26,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Error!",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: const Text(
                                    "El nombre del ejercicio es obligatorio",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text(
                                        "Aceptar",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            if (!validarNombreEjercicio(nombre)) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: Colors.red.shade50,
                                  title: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_rounded,
                                        color: Colors.red,
                                        size: 26,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Error!",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: const Text(
                                    "El nombre debe empezar con mayúscula (solo letras, números y espacios)",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text(
                                        "Aceptar",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            if (clasificacionSeleccionada == null) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: Colors.red.shade50,
                                  title: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_rounded,
                                        color: Colors.red,
                                        size: 26,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Error!",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: const Text(
                                    "Debes seleccionar una clasificación",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text(
                                        "Aceptar",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            Map<String, dynamic> rowEjercicio = {
                              'nombre': nombre,
                              'clasificacion': clasificacionSeleccionada,
                              'participantes': seleccionados.isEmpty
                                  ? '-'
                                  : seleccionados.join(', '),
                            };
                            int ejercicioId;
                            if (ejercicio == null) {
                              ejercicioId = await _dbHelper.insertEjercicio(rowEjercicio);
                            } else {
                              ejercicioId = ejercicio['id'];
                              rowEjercicio['id'] = ejercicioId;
                              await _dbHelper.updateEjercicio(
                                rowEjercicio,
                              );
                              await _dbHelper
                                  .eliminarEjercicioDeTodosLosEventos(
                                    ejercicioId,
                                  );
                            }
                            final listaEventos = await _dbHelper
                                .getEventos();
                            final eventoDestino = listaEventos.firstWhere(
                              (e) => e['nombre'] == clasificacionSeleccionada,
                              orElse: () => {},
                            );
                            if (eventoDestino.isNotEmpty) {
                              // Obtenemos los IDs actuales y los convertimos en lista
                              String actuales =
                                  eventoDestino['ejercicios_ids']?.toString() ??
                                  "";
                              List<String> idsList = actuales
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty && e != '-')
                                  .toList();

                              // Agregamos el ID del ejercicio si no está ya vinculado
                              if (!idsList.contains(ejercicioId.toString())) {
                                idsList.add(ejercicioId.toString());

                                // Creamos el mapa para actualizar el evento
                                Map<String, dynamic> updateData = Map.from(
                                  eventoDestino,
                                );
                                updateData['ejercicios_ids'] = idsList.join(
                                  ',',
                                );

                                await _dbHelper.updateEvento(updateData);
                              }
                            }

                            // Actualizar competidores en una sola transacción
                            final db = await _dbHelper.database;
                            await db.transaction((txn) async {
                              for (var comp in todosLosComps) {
                                List<String> susEjercicios =
                                    (comp['ejercicios_participados'] ?? "")
                                        .toString()
                                        .split(', ')
                                        .where((e) => e.isNotEmpty)
                                        .toList();
                                if (seleccionados.contains(comp['nombre'])) {
                                  if (!susEjercicios.contains(nombreCtrl.text)) {
                                    susEjercicios.add(nombreCtrl.text);
                                  }
                                } else {
                                  susEjercicios.remove(nombreCtrl.text);
                                }

                                await txn.update(
                                  'competidores',
                                  {'ejercicios_participados': susEjercicios.join(', ')},
                                  where: 'id = ?',
                                  whereArgs: [comp['id']],
                                );
                              }
                            });

                            navigator.pop();
                            _cargarDatos();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ejercicio == null
                                ? Colors.blue.shade200
                                : Colors.blue.shade200,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
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
      ),
    );
  }

  // --- FUNCIÓN DE ELIMINACIÓN CON CONFIRMACIÓN ---
  Future<void> _confirmarYEliminarEjercicio(Map<String, dynamic> ej) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.white70],
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
              // Icono de advertencia
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),

              // Título
              const Text(
                "¿Eliminar ejercicio?",
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              // Mensaje
              Text(
                "¿Estás seguro de que deseas eliminar el ejercicio \"${ej['nombre']}\"?",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.blue, fontSize: 15),
              ),
              const SizedBox(height: 10),
              const Text(
                "Esta acción no se puede deshacer.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 25),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
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
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Eliminar",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmar == true) {
      // Primero eliminar el ejercicio de todos los eventos
      await _dbHelper.eliminarEjercicioDeTodosLosEventos(ej['id']);

      // Luego eliminar el ejercicio de la tabla
      await _dbHelper.deleteEjercicio(ej['id']);

      // Actualizar la UI
      _cargarDatos();
    }
  }

  // Widget del filtro segmentado
  Widget _buildSegmentedFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(
        6,
      ), // Espacio interno del contenedor gris oscuro
      decoration: BoxDecoration(
        color:
            Colors.transparent, // Fondo para que se note el área de los botones
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: _filtros.asMap().entries.map((entry) {
          int idx = entry.key;
          String filtro = entry.value;
          final isSelected = filtro == filtroActual;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: idx == 0 ? 0 : 4,
                right: idx == _filtros.length - 1 ? 0 : 4,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    filtroActual = filtro;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFF7043)
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    filtro,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize:
                          13, // Ajuste ligero para que quepan nombres largos
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String traducirIdsANombres(String? ids) {
    if (ids == null || ids.isEmpty || ids == '-') return 'Ninguno';
    List<String> idsList = ids.split(',').map((e) => e.trim()).toList();
    List<String> nombres = [];
    for (var id in idsList) {
      final ej = _listaEjercicios.firstWhere(
        (e) => e['id'].toString() == id,
        orElse: () => {},
      );
      if (ej.isNotEmpty) {
        nombres.add(ej['nombre']);
      }
    }
    return nombres.isEmpty ? 'Ninguno' : nombres.join(', ');
  }

  String traducirEquipos(String? ids) {
    if (ids == null || ids.isEmpty || ids == '-') return 'Ninguno';
    List<String> idsList = ids.split(',').map((e) => e.trim()).toList();
    List<String> nombres = [];
    for (var id in idsList) {
      final eq = _listaEquipos.firstWhere(
        (e) => e['id'].toString() == id,
        orElse: () => {},
      );
      if (eq.isNotEmpty) {
        nombres.add(eq['nombre']);
      }
    }
    return nombres.isEmpty ? 'Ninguno' : nombres.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.fitness_center, color: Colors.deepOrange),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Panel de eventos",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "UCIFitness",
                  style: TextStyle(color: Colors.white70, fontSize: 11),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSegmentedFilter(),
          Expanded(
            child: filtroActual == "Ejercicios"
                ? _buildListaEjercicios()
                : _buildListaEventos(),
          ),
        ],
      ),
      floatingActionButton: filtroActual == "Ejercicios"
          ? FloatingActionButton(
              onPressed: () => _mostrarFormulario(),
              backgroundColor: Colors.deepOrange,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildListaEjercicios() {
    if (_listaEjercicios.isEmpty) {
      return const Center(
        child: Text(
          "No hay ejercicios registrados",
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      itemCount: _listaEjercicios.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final ejercicio = _listaEjercicios[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade50, Colors.blue.shade100],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.deepOrange,
                  size: 28,
                ),
              ),
              title: Text(
                ejercicio['nombre'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                ejercicio['clasificacion'] ?? '',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blue),
                    onPressed: () => _verDetallesEjercicio(ejercicio),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.green),
                    onPressed: () => _mostrarFormulario(ejercicio: ejercicio),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarYEliminarEjercicio(ejercicio),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListaEventos() {
    if (_listaEventos.isEmpty) {
      return const Center(
        child: Text(
          "No hay eventos registrados",
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      itemCount: _listaEventos.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final evento = _listaEventos[index];
        final idsEjercicios = evento['ejercicios_ids']?.toString() ?? "";
        final contarEjercicios = idsEjercicios.isEmpty || idsEjercicios == '-'
            ? 0
            : idsEjercicios.split(',').length;

        final idsEquipos = evento['equipos_ids']?.toString() ?? "";
        final contarEquipos = idsEquipos.isEmpty || idsEquipos == '-'
            ? 0
            : idsEquipos.split(',').length;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade50, Colors.blue.shade100],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.event, color: Colors.blue, size: 28),
              ),
              title: Text(
                evento['nombre'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                "$contarEjercicios ejercicios • $contarEquipos equipos",
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blue),
                    onPressed: () => _verDetallesEvento(evento),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- VER DETALLES EVENTO (Ya existía, manteniendo el código original) ---
  void _verDetallesEvento(Map<String, dynamic> evento) {
    final idsEjercicios = evento['ejercicios_ids']?.toString() ?? "";
    final contarEjercicios = idsEjercicios.isEmpty || idsEjercicios == '-'
        ? 0
        : idsEjercicios.split(',').length;

    final idsEquipos = evento['equipos_ids']?.toString() ?? "";
    final contarEquipos = idsEquipos.isEmpty || idsEquipos == '-'
        ? 0
        : idsEquipos.split(',').length;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue, Color(0xFF0D47A1)],
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
              // 🎯 Encabezado
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.event,
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
                                "Ficha de Evento",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                evento['nombre'] ?? 'Sin nombre',
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
                  ],
                ),
              ),

              // Estadísticas - Estilo Dashboard
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCardEvento(
                        Icons.fitness_center,
                        contarEjercicios.toString(),
                        "Ejercicios",
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildStatCardEvento(
                        Icons.groups,
                        contarEquipos.toString(),
                        "Equipos",
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              // 📝 Contenido expandible
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lista de Ejercicios
                      _buildSeccionEvento(
                        "Ejercicios asignados",
                        Icons.fitness_center,
                        Colors.orange,
                      ),
                      const SizedBox(height: 10),
                      _buildContenidoCard(
                        traducirIdsANombres(evento['ejercicios_ids']),
                        Colors.orange,
                      ),
                      const SizedBox(height: 20),

                      // Lista de Equipos
                      _buildSeccionEvento(
                        "Equipos participantes",
                        Icons.groups,
                        Colors.blue,
                      ),
                      const SizedBox(height: 10),
                      _buildContenidoCard(
                        traducirEquipos(evento['equipos_ids']),
                        Colors.blue,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // 🔘 Botón de cierre
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
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

  // Widget de estadística para la ficha de evento
  Widget _buildStatCardEvento(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 📑 Widget de sección
  Widget _buildSeccionEvento(String titulo, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 📄 Widget de contenido
  Widget _buildContenidoCard(String contenido, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Text(
        contenido,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }
}
