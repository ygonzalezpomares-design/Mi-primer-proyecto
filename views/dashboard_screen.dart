import 'package:flutter/material.dart';
import '../main.dart';
import '../presenters/dashboard_presenter.dart';
import '../contracts/dashboard_contract.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    implements DashboardContract {
  late DashboardPresenter _presenter;

  // Datos del dashboard
  // ignore: unused_field
  int _totalCompetidores = 0;
  // ignore: unused_field
  int _totalEquipos = 0;
  // ignore: unused_field
  int _totalEjercicios = 0;
  // ignore: unused_field
  int _totalEvaluados = 0;

  // Rankings generales
  List<Map<String, dynamic>> _rankingCompetidores = [];
  List<Map<String, dynamic>> _rankingEquipos = [];
  List<Map<String, dynamic>> _eventos = [];
  String? _eventoSeleccionado;
  String _sexoSeleccionado = 'Todos';
  bool _cargando = false;
  bool _mostrandoEquipos = false;

  @override
  void initState() {
    super.initState();
    _presenter = DashboardPresenter(this);
    _presenter.loadData();
  }

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  // Implementación de DashboardContract.View
  @override
  void showLoading() {
    setState(() {
      _cargando = true;
    });
  }

  @override
  void hideLoading() {
    if (mounted) {
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  void updateEstadisticas({
    required int totalCompetidores,
    required int totalEquipos,
    required int totalEjercicios,
    required int totalEvaluados,
  }) {
    if (mounted) {
      setState(() {
        _totalCompetidores = totalCompetidores;
        _totalEquipos = totalEquipos;
        _totalEjercicios = totalEjercicios;
        _totalEvaluados = totalEvaluados;
      });
    }
  }

  @override
  void updateEventos(List<Map<String, dynamic>> eventos) {
    if (mounted) {
      setState(() {
        _eventos = eventos;
        if (eventos.isNotEmpty && _eventoSeleccionado == null) {
          _eventoSeleccionado = eventos.first['nombre'];
        }
      });

      // Cargar rankings después de actualizar eventos
      _cargarRankings();
    }
  }

  @override
  void updateRankingCompetidores(List<Map<String, dynamic>> ranking) {
    if (mounted) {
      setState(() {
        _rankingCompetidores = ranking;
      });
    }
  }

  @override
  void updateRankingEquipos(List<Map<String, dynamic>> ranking) {
    if (mounted) {
      setState(() {
        _rankingEquipos = ranking;
      });
    }
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

  Future<void> _cargarRankings() async {
    await _presenter.loadRankings(
      evento: _eventoSeleccionado,
      sexo: _sexoSeleccionado,
      mostrandoEquipos: _mostrandoEquipos,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(Icons.fitness_center, color: Colors.deepOrange),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rankings y Estadísticas",
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bienvenida
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrange.withValues(alpha: 0.8),
                      Colors.amber.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "¡Bienvenido de nuevo!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Consulta los rankings y el rendimiento de tus competidores",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const SizedBox(height: 30),

              // Título de Rankings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _mostrandoEquipos
                        ? "Ranking de equipos"
                        : "Ranking de competidores",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                ],
              ),
              const SizedBox(height: 15),

              // Selector de evento
              _buildEventoSelector(),
              const SizedBox(height: 10),

              // Selector de sexo (SOLO para competidores)
              if (!_mostrandoEquipos) ...[
                _buildSexoSelector(),
                const SizedBox(height: 10),
              ],

              // Selector de tipo de ranking
              _buildTipoRankingSelector(),
              const SizedBox(height: 20),

              // Ranking General
              if (_cargando)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: Colors.deepOrange),
                  ),
                )
              else if (_eventos.isEmpty)
                _buildEmptyState("No hay eventos registrados")
              else if (_mostrandoEquipos && _rankingEquipos.isEmpty)
                _buildEmptyState("No hay equipos evaluados")
              else if (!_mostrandoEquipos && _rankingCompetidores.isEmpty)
                _buildEmptyState("No hay competidores evaluados")
              else
                _buildRankingCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventoSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _eventoSeleccionado,
          isExpanded: true,
          hint: const Text("Seleccione un evento"),
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: Color(0xFF1A5F7A),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.deepOrange),
          items: _eventos.map((evento) {
            return DropdownMenuItem<String>(
              value: evento['nombre'],
              child: Row(
                children: [
                  const Icon(Icons.event, size: 18, color: Colors.deepOrange),
                  const SizedBox(width: 10),
                  Text(evento['nombre']),
                ],
              ),
            );
          }).toList(),
          onChanged: (valor) {
            setState(() {
              _eventoSeleccionado = valor;
              _cargarRankings();
            });
          },
        ),
      ),
    );
  }

  Widget _buildSexoSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sexoSeleccionado,
          isExpanded: true,
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: Color(0xFF1A5F7A),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.deepOrange),
          items: const [
            DropdownMenuItem<String>(
              value: 'Todos',
              child: Row(
                children: [
                  Icon(Icons.people, size: 18, color: Colors.deepOrange),
                  SizedBox(width: 10),
                  Text('Todos (Hombres + Mujeres)'),
                ],
              ),
            ),
            DropdownMenuItem<String>(
              value: 'Masculino',
              child: Row(
                children: [
                  Icon(Icons.male, size: 18, color: Colors.blue),
                  SizedBox(width: 10),
                  Text('Solo masculino'),
                ],
              ),
            ),
            DropdownMenuItem<String>(
              value: 'Femenino',
              child: Row(
                children: [
                  Icon(Icons.female, size: 18, color: Colors.pink),
                  SizedBox(width: 10),
                  Text('Solo femenino'),
                ],
              ),
            ),
          ],
          onChanged: (valor) {
            setState(() {
              _sexoSeleccionado = valor!;
              _cargarRankings();
            });
          },
        ),
      ),
    );
  }

  Widget _buildTipoRankingSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
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
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _mostrandoEquipos = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_mostrandoEquipos
                      ? Colors.deepOrange
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 18,
                      color: !_mostrandoEquipos ? Colors.white : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Competidores",
                      style: TextStyle(
                        color: !_mostrandoEquipos ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _mostrandoEquipos = true;
                  // Resetear filtro de sexo cuando se cambia a equipos
                  _sexoSeleccionado = 'Todos';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _mostrandoEquipos ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.groups,
                      size: 18,
                      color: _mostrandoEquipos ? Colors.white : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Equipos",
                      style: TextStyle(
                        color: _mostrandoEquipos ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String mensaje) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white.withValues(alpha: 0.5),
            size: 48,
          ),
          const SizedBox(height: 15),
          Text(
            mensaje,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Evalúa competidores para ver los rankings",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard() {
    final ranking = _mostrandoEquipos ? _rankingEquipos : _rankingCompetidores;
    final titulo = _mostrandoEquipos ? "Equipos" : "Competidores";
    final color = _mostrandoEquipos ? Colors.blue : Colors.deepOrange;
    final icono = _mostrandoEquipos ? Icons.groups : Icons.person;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Encabezado
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icono, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ranking general - $titulo",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Mostrar filtro activo SOLO en competidores
                      if (!_mostrandoEquipos && _sexoSeleccionado != 'Todos')
                        Text(
                          'Categoría ${_sexoSeleccionado == 'Masculino' ? '♂ Masculino' : '♀ Femenino'}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _mostrandoEquipos ? Icons.groups : Icons.people,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${ranking.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de items
          if (ranking.isEmpty)
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Icon(
                    Icons.sports,
                    size: 48,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Sin evaluaciones registradas",
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ranking.length > 10 ? 10 : ranking.length,
              itemBuilder: (context, index) {
                return _buildRankingItem(ranking[index], index, color);
              },
            ),

          // Mostrar más si hay más de 10
          if (ranking.length > 10)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "+${ranking.length - 10} ${_mostrandoEquipos ? 'equipos' : 'competidores'} más",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRankingItem(Map<String, dynamic> item, int index, Color color) {
    int posicion = item['posicion_general'] ?? (index + 1);
    double puntaje = item['puntuacion_total'] ?? 0.0;
    String nombre = item['nombre'] ?? 'Sin nombre';

    // Para competidores
    String? equipo = !_mostrandoEquipos
        ? (item['nombre_equipo'] ?? 'Sin equipo')
        : null;

    // Para equipos
    String? curso = _mostrandoEquipos ? (item['curso'] ?? '-') : null;

    // Colores para medallas
    Color? colorMedalla;
    IconData? iconoMedalla;
    String? emoji;

    if (posicion == 1) {
      colorMedalla = const Color(0xFFFFD700);
      iconoMedalla = Icons.workspace_premium;
      emoji = '🥇';
    } else if (posicion == 2) {
      colorMedalla = const Color(0xFFC0C0C0);
      iconoMedalla = Icons.workspace_premium;
      emoji = '🥈';
    } else if (posicion == 3) {
      colorMedalla = const Color(0xFFCD7F32);
      iconoMedalla = Icons.workspace_premium;
      emoji = '🥉';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        color: posicion <= 3
            ? colorMedalla?.withValues(alpha: 0.05)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          // Posición o medalla
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorMedalla ?? Colors.grey.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: iconoMedalla != null
                  ? Icon(iconoMedalla, color: Colors.white, size: 20)
                  : Text(
                      '$posicion',
                      style: TextStyle(
                        color: posicion <= 3 ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 15),

          // Información del item
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: TextStyle(
                    fontWeight: posicion <= 3
                        ? FontWeight.bold
                        : FontWeight.w600,
                    color: const Color(0xFF1A5F7A),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      _mostrandoEquipos ? Icons.school : Icons.groups,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _mostrandoEquipos ? "Curso: $curso" : equipo!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Puntaje
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  puntaje.toStringAsFixed(1),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  'pts',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Emoji de medalla
          if (emoji != null) ...[
            const SizedBox(width: 8),
            Text(emoji, style: const TextStyle(fontSize: 18)),
          ],
        ],
      ),
    );
  }
}
