// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../presenters/equipo_presenter.dart';
import '../contracts/equipo_contract.dart';

class EquipoScreen extends StatefulWidget {
  const EquipoScreen({super.key});

  @override
  State<EquipoScreen> createState() => _EquipoScreenState();
}

class _EquipoScreenState extends State<EquipoScreen> implements EquipoContract {
  late EquipoPresenter _presenter;
  final dbHelper = DatabaseHelper();

  bool mostrandoEquipos = true;
  List<Map<String, dynamic>> datos = [];
  List<Map<String, dynamic>> datosFiltrados = [];
  List<Map<String, dynamic>> todosLosCompetidores = [];
  List<Map<String, dynamic>> todosLosEventos = [];
  final TextEditingController _searchController = TextEditingController();
  // ignore: unused_field
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _presenter = EquipoPresenter(this);
    _cargarDatos();
    _searchController.addListener(_filtrarDatos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _presenter.dispose();
    super.dispose();
  }

  // Implementación de EquipoContract.View
  @override
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void updateDatos(List<Map<String, dynamic>> newDatos) {
    if (mounted) setState(() => datos = newDatos);
  }

  @override
  void updateDatosFiltrados(List<Map<String, dynamic>> newDatosFiltrados) {
    if (mounted) setState(() => datosFiltrados = newDatosFiltrados);
  }

  @override
  void updateTodosLosCompetidores(List<Map<String, dynamic>> competidores) {
    if (mounted) setState(() => todosLosCompetidores = competidores);
  }

  @override
  void updateTodosLosEventos(List<Map<String, dynamic>> eventos) {
    if (mounted) setState(() => todosLosEventos = eventos);
  }

  @override
  void showFormDialog({Map<String, dynamic>? item}) {
    _dialogoFormulario(item: item);
  }

  @override
  void showFichaDialog(Map<String, dynamic> item) {
    _verFicha(item);
  }

  @override
  void showDeleteConfirmation(Map<String, dynamic> item) {
    _confirmarEliminar(item['id'] as int);
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
    _cargarDatos();
  }

  @override
  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Métodos auxiliares
  Future<void> _cargarDatos() async {
    await _presenter.loadData(isTeamMode: mostrandoEquipos);
  }

  void _filtrarDatos() {
    _presenter.filterData(_searchController.text, datos);
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
                  "Panel de control",
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
          _buildTabs(),
          const SizedBox(height: 15),
          _buildSearchInput(
            mostrandoEquipos ? "Buscar equipos..." : "Buscar competidores...",
          ),
          const SizedBox(height: 15),
          Expanded(
            child: datosFiltrados.isEmpty
                ? Center(
                    child: Text(
                      mostrandoEquipos
                          ? "No hay equipos registrados"
                          : "No hay competidores registrados",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: datosFiltrados.length,
                    itemBuilder: (context, index) =>
                        _itemCard(datosFiltrados[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _dialogoFormulario(),
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _dialogoFormulario({Map<String, dynamic>? item}) async {
    final nombreCtrl = TextEditingController(text: item?['nombre'] ?? '');
    final cursoCtrl = TextEditingController(text: item?['curso'] ?? '');
    List<Map<String, dynamic>> competidoresDisponibles = await dbHelper
        .getCompetidoresSinEquipo(item?['id']);
    String sexo = item?['sexo'] ?? 'M';
    String? eventoSeleccionado = item?['evento'] == '-'
        ? null
        : item?['evento'];

    List<int> seleccionados = [];

    if (mostrandoEquipos && item != null) {
      final actual = await dbHelper.getIntegrantesEquipo(item['id']);
      seleccionados = actual.map((e) => e['id'] as int).toList();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
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
                      colors: item == null
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
                          item == null ? Icons.add_circle : Icons.edit,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        item == null
                            ? (mostrandoEquipos
                                  ? "Nuevo equipo"
                                  : "Nuevo competidor")
                            : (mostrandoEquipos
                                  ? "Editar equipo"
                                  : "Editar competidor"),
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
                          "Nombre",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
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

                        // Campo Curso
                        const Text(
                          "Curso",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
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
                            controller: cursoCtrl,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: "Ingrese el curso",
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

                        // Sexo (solo para competidores)
                        if (!mostrandoEquipos) ...[
                          const Text(
                            "Sexo",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setDialogState(() => sexo = "M"),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: sexo == "M"
                                          ? Colors.blue.shade200
                                          : Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "Masculino",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: sexo == "M"
                                            ? Colors.blue
                                            : Colors.black87,
                                        fontWeight: sexo == "M"
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setDialogState(() => sexo = "F"),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: sexo == "F"
                                          ? Colors.blue.shade200
                                          : Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "Femenino",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: sexo == "F"
                                            ? Colors.blue
                                            : Colors.black87,
                                        fontWeight: sexo == "F"
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Dropdown Evento
                        const Text(
                          "Evento",
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
                            color: Colors.blue.shade100,
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
                            value: eventoSeleccionado,
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
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text("Sin asignar"),
                              ),
                              ...todosLosEventos.map(
                                (ev) => DropdownMenuItem<String>(
                                  value: ev['nombre'],
                                  child: Text(ev['nombre']),
                                ),
                              ),
                            ],
                            onChanged: (val) =>
                                setDialogState(() => eventoSeleccionado = val),
                          ),
                        ),

                        // Integrantes (solo para equipos)
                        if (mostrandoEquipos) ...[
                          const SizedBox(height: 20),
                          const Text(
                            "Integrantes (4-6, al menos 2 de cada sexo)",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 250,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.shade200,
                                  width: 1,
                                ),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: competidoresDisponibles.length,
                                itemBuilder: (context, index) {
                                  final comp = competidoresDisponibles[index];
                                  final isSelected = seleccionados.contains(
                                    comp['id'],
                                  );
                                  return CheckboxListTile(
                                    value: isSelected,
                                    title: Text(
                                      "${comp['nombre']} (${comp['sexo']})",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    activeColor: Colors.blue,
                                    onChanged: (val) {
                                      setDialogState(() {
                                        if (val == true) {
                                          seleccionados.add(comp['id']);
                                        } else {
                                          seleccionados.remove(comp['id']);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
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
                            final scaffoldMessenger = ScaffoldMessenger.of(
                              context,
                            );

                            final nombre = nombreCtrl.text.trim();
                            final curso = cursoCtrl.text.trim();

                            bool validarNombre(String n) {
                              if (n.length < 2 || n.length > 50) return false;
                              if (!RegExp(r'^[A-ZÁÉÍÓÚÑ]').hasMatch(n))
                                return false;
                              return RegExp(
                                r'^[A-ZÁÉÍÓÚÑ][a-zA-ZáéíóúÁÉÍÓÚñÑ\s]*$',
                              ).hasMatch(n);
                            }

                            bool validarCurso(String c) {
                              return RegExp(
                                r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\-]{2,20}$',
                              ).hasMatch(c);
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
                                    "El nombre es obligatorio",
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

                            if (!validarNombre(nombre)) {
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
                                    "El nombre debe empezar con mayúscula y solo contener letras y espacios",
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

                            if (curso.isEmpty) {
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
                                    "El curso es obligatorio.",
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

                            if (!validarCurso(curso)) {
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
                                    "El curso solo puede contener letras, números y guiones (2-20 caracteres)",
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

                            try {
                              int idRegistro;
                              if (mostrandoEquipos) {
                                Map<String, dynamic> equipoData = {
                                  'nombre': nombreCtrl.text,
                                  'curso': cursoCtrl.text,
                                  'evento': eventoSeleccionado ?? '-',
                                };

                                if (item == null) {
                                  idRegistro = await dbHelper.insertEquipo(
                                    equipoData,
                                    seleccionados,
                                  );
                                } else {
                                  equipoData['id'] = item['id'];
                                  idRegistro = item['id'];
                                  await dbHelper.updateEquipo(
                                    equipoData,
                                    seleccionados,
                                  );
                                }

                                if (eventoSeleccionado != null &&
                                    eventoSeleccionado != '-') {
                                  await dbHelper.vincularEquipoAEvento(
                                    idRegistro,
                                    eventoSeleccionado!,
                                  );
                                } else {
                                  await dbHelper
                                      .eliminarEquipoDeTodosLosEventos(
                                        idRegistro,
                                      );
                                }
                              } else {
                                Map<String, dynamic> compData = {
                                  'nombre': nombreCtrl.text,
                                  'curso': cursoCtrl.text,
                                  'sexo': sexo,
                                  'evento': eventoSeleccionado ?? '-',
                                };
                                if (item == null) {
                                  await dbHelper.insertCompetidor(compData);
                                } else {
                                  compData['id'] = item['id'];
                                  await dbHelper.updateCompetidor(compData);
                                }
                              }

                              _cargarDatos();
                              navigator.pop();
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        mostrandoEquipos
                                            ? "Equipo guardado exitosamente"
                                            : "Competidor guardado exitosamente",
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } catch (e) {
                              String mensajeError = e.toString();
                              if (mensajeError.startsWith('Exception: ')) {
                                mensajeError = mensajeError.substring(11);
                              }

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
                                      Text(
                                        mostrandoEquipos
                                            ? "Error al guardar equipo!"
                                            : "Error al guardar competidor!",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Text(mensajeError),
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
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item == null
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

  Widget _buildTabs() {
    final filtros = ["Equipos", "Competidores"];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: filtros.asMap().entries.map((entry) {
          int idx = entry.key;
          String filtro = entry.value;
          final isSelected =
              (filtro == "Equipos" && mostrandoEquipos) ||
              (filtro == "Competidores" && !mostrandoEquipos);

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: idx == 0 ? 0 : 4,
                right: idx == filtros.length - 1 ? 0 : 4,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    mostrandoEquipos = filtro == "Equipos";
                    _cargarDatos();
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
                      fontSize: 13,
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

  Widget _buildSearchInput(String h) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      controller: _searchController,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: h,
        icon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
      ),
    ),
  );

  Widget _itemCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              color: (mostrandoEquipos ? Colors.blue : Colors.deepOrange)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              mostrandoEquipos ? Icons.groups : Icons.person,
              color: mostrandoEquipos ? Colors.blue : Colors.deepOrange,
              size: 28,
            ),
          ),
          title: Text(
            item['nombre'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            mostrandoEquipos ? item['curso'] ?? '' : "Sexo: ${item['sexo']}",
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                onPressed: () => _verFicha(item),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.green),
                onPressed: () => _dialogoFormulario(item: item),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmarEliminar(item['id']),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarEliminar(int id) async {
    final item = datos.firstWhere((e) => e['id'] == id);
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
              Text(
                mostrandoEquipos
                    ? "¿Eliminar Equipo?"
                    : "¿Eliminar Competidor?",
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              // Mensaje
              Text(
                mostrandoEquipos
                    ? "¿Estás seguro de que deseas eliminar el equipo \"${item['nombre']}\"?"
                    : "¿Estás seguro de que deseas eliminar al competidor \"${item['nombre']}\"?",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.blue, fontSize: 15),
              ),
              const SizedBox(height: 10),
              Text(
                mostrandoEquipos
                    ? "Los competidores quedarán disponibles para otros equipos."
                    : "Esta acción no se puede deshacer.",
                textAlign: TextAlign.center,
                style: const TextStyle(
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
      try {
        if (mostrandoEquipos) {
          await dbHelper.liberarIntegrantesDeEquipo(id);
          final equipoABorrar = datos.firstWhere((e) => e['id'] == id);
          String nombreEq = equipoABorrar['nombre'] ?? "";

          if (nombreEq.isNotEmpty) {
            await dbHelper.desvincularAtletasDeEquipo(nombreEq);
            await dbHelper.eliminarEquipoDeTodosLosEventos(id);
          }

          await dbHelper.deleteEquipo(id);
        } else {
          await dbHelper.deleteCompetidor(id);
        }

        _cargarDatos();
      } catch (e) {
        debugPrint("Error al eliminar: $e");
      }
    }
  }

  void _verFicha(Map<String, dynamic> item) async {
    if (mostrandoEquipos) {
      // ===== VISTA DE EQUIPO =====
      // ignore: unused_local_variable
      List<Map<String, dynamic>> integrantes = await dbHelper
          .getIntegrantesEquipo(item['id']);

      final resumenEquipo = await dbHelper.getResumenEquipo(item['id']);

      if (!mounted) return;

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
                // 🎯 Encabezado con icono
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.deepOrange.shade400,
                        Colors.deepOrange.shade400,
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
                          Icons.groups,
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
                              "Detalle de Equipo",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['nombre'],
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
                        // Curso
                        Row(
                          children: [
                            Icon(
                              Icons.school,
                              color: Colors.deepOrange.shade300,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Curso",
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
                            color: Colors.deepOrange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item['curso'] ?? '-',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Integrantes
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: Colors.deepOrange.shade300,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Integrantes",
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
                            color: Colors.deepOrange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                resumenEquipo['integrantes_detalle'] != null &&
                                    (resumenEquipo['integrantes_detalle']
                                            as List)
                                        .isNotEmpty
                                ? (resumenEquipo['integrantes_detalle'] as List)
                                      .map(
                                        (integrante) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            "• ${integrante['nombre']} - ${integrante['puntuacion']?.toStringAsFixed(1) ?? '0.0'} pts",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList()
                                : [
                                    const Text(
                                      "Sin integrantes",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Puntuación
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.deepOrange.shade300,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Puntuación total",

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
                            color: Colors.deepOrange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${resumenEquipo['total_puntos']?.toStringAsFixed(1) ?? '0.0'} pts",
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

                // 🔘 Botón de cierre
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
    } else {
      // ===== VISTA DE COMPETIDOR =====
      final resumen = await dbHelper.getResumenCompetidor(item['id']);

      if (!mounted) return;

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
                // 🎯 Encabezado con icono
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.deepOrange.shade400,
                        Colors.deepOrange.shade400,
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
                          Icons.person,
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
                              "Detalle de competidor",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              resumen['nombre'] ?? item['nombre'],
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
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Curso y Sexo
                        Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.deepOrange.shade300,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Información",
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
                            color: Colors.deepOrange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${resumen['curso'] ?? item['curso']} • ${resumen['sexo'] ?? item['sexo']}",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Ejercicios participados
                        Row(
                          children: [
                            Icon(
                              Icons.fitness_center,
                              color: Colors.deepOrange.shade300,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Ejercicios participados",
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
                            color: Colors.deepOrange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            resumen['ejercicios_participados']?.toString() ??
                                '0',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Puntuación
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.deepOrange.shade300,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Puntuación total",
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
                            color: Colors.deepOrange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${resumen['total_puntos']?.toStringAsFixed(1) ?? '0.0'} pts",
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
  }
}
