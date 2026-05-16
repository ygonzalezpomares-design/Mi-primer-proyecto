import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/user_model.dart';
import 'models/ejercicio_model.dart';
import 'models/equipo_model.dart';
import 'package:flutter/foundation.dart';
import 'utils/auth_utils.dart';

class DatabaseHelper with ChangeNotifier {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ucifitness.db');
    return await openDatabase(
      path,
      version: 8,
      onConfigure: (db) async {
        // Habilitar foreign keys
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // Tabla usuario
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            email TEXT UNIQUE,
            telefono TEXT,
            password TEXT,
            role TEXT,
            foto TEXT
          )
        ''');
        // Tabla ejercicios
        await db.execute('''
        CREATE TABLE ejercicios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT UNIQUE,
          clasificacion TEXT,
          participantes TEXT -- Guardaremos los nombres separados por comas
        )
      ''');
        // Tabla Competidores
        await db.execute('''CREATE TABLE competidores (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT UNIQUE,
          sexo TEXT,
          equipo_id INTEGER,
          curso TEXT,
          evaluacion_gral TEXT DEFAULT '-',
          evaluacion_ejercicios TEXT DEFAULT '-',
          evento TEXT DEFAULT '-',
          posicion TEXT DEFAULT '-',
          ejercicios_participados TEXT DEFAULT '-'
        )''');
        // Tabla Equipos
        await db.execute('''CREATE TABLE equipos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT UNIQUE,
          curso TEXT,
          evento TEXT DEFAULT '-',
          evaluacion_gral TEXT DEFAULT '-',
          posicion TEXT DEFAULT '-'
        )''');
        await db.execute('''
    CREATE TABLE eventos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT,
      ejercicios_ids TEXT,   -- IDs de ejercicios separados por comas
      equipos_ids TEXT,      -- IDs de equipos separados por comas
      competidores_ids TEXT  -- IDs de competidores separados por comas
    )
  ''');

        // Tabla Equipo_Competidores
        await db.execute('''CREATE TABLE equipo_integrantes (
          equipo_id INTEGER, 
          competidor_id INTEGER UNIQUE,
          FOREIGN KEY (equipo_id) REFERENCES equipos (id) ON DELETE CASCADE,
          FOREIGN KEY (competidor_id) REFERENCES competidores (id) ON DELETE CASCADE
        )''');
        // Tabla Evaluaciones
        await db.execute('''
  CREATE TABLE calificaciones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    competidor_id INTEGER,
    ejercicio_id INTEGER,
    puntaje REAL,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (competidor_id) REFERENCES competidores (id),
    FOREIGN KEY (ejercicio_id) REFERENCES ejercicios (id)
  )
''');
        // Tabla Evento Eliminatoria
        await db.insert('eventos', {
          'nombre': 'Eliminatoria',
          'ejercicios_ids': '-',
          'equipos_ids': '-',
          'competidores_ids': '-',
        });
        // Tabla Evento Final
        await db.insert('eventos', {
          'nombre': 'Final',
          'ejercicios_ids': '-',
          'equipos_ids': '-',
          'competidores_ids': '-',
        });
        // Tabla Usuario SuperAdmin inicial
        await db.insert('users', {
          'nombre': 'Joel',
          'email': 'joekenpo@uci.cu',
          'telefono': 'xxxxxxxx',
          'password': AuthUtils.hashPassword('admin123'),
          'role': 'admin',
        });
        // Tabla Usuario Admin inicial
        await db.insert('users', {
          'nombre': 'Yoslenys',
          'email': 'yrhdez@uci.cu',
          'telefono': 'xxxxxxxx',
          'password': AuthUtils.hashPassword('arbitro123'),
          'role': 'arbitro',
        });
        // Tabla Usuario Admin inicial
        await db.insert('users', {
          'nombre': 'Manuel',
          'email': 'mfornes@uci.cu',
          'telefono': 'xxxxxxxx',
          'password': AuthUtils.hashPassword('arbitro123'),
          'role': 'arbitro',
        });
        // Tabla Usuario Admin inicial
        await db.insert('users', {
          'nombre': 'Andy',
          'email': 'andydec@uci.cu',
          'telefono': '54832144',
          'password': AuthUtils.hashPassword('capitan123'),
          'role': 'capitan',
        });
        // Tabla Usuario Admin inicial
        await db.insert('users', {
          'nombre': 'Yasira',
          'email': 'yasirag@uci.cu',
          'telefono': '53325313',
          'password': AuthUtils.hashPassword('admin123'),
          'role': 'superadmin',
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 6) {
          await db.execute(
            '''CREATE TABLE IF NOT EXISTS equipo_integrantes (equipo_id INTEGER, competidor_id INTEGER)''',
          );
        }
        if (oldVersion < 8) {
          // Agregar índices únicos en nombre para evitar duplicados
          await db.execute(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_ejercicios_nombre ON ejercicios(nombre)',
          );
          await db.execute(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_competidores_nombre ON competidores(nombre)',
          );
          await db.execute(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_equipos_nombre ON equipos(nombre)',
          );
        }
      },
      onOpen: (db) async {
        await _ensureDefaultUsers(db);
      },
    );
  }

  Future<void> _ensureDefaultUsers(Database db) async {
    final existingUsers = await db.query(
      'users',
      where: "email = ?",
      whereArgs: ['joekenpo@uci.cu'],
    );

    if (existingUsers.isEmpty) {
      await db.insert('users', {
        'nombre': 'Joel',
        'email': 'joekenpo@uci.cu',
        'telefono': 'xxxxxxxx',
        'password': AuthUtils.hashPassword('admin123'),
        'role': 'superadmin',
      });
      await db.insert('users', {
        'nombre': 'Yoslenys',
        'email': 'yrhdez@uci.cu',
        'telefono': 'xxxxxxxx',
        'password': AuthUtils.hashPassword('admin123'),
        'role': 'admin',
      });
      await db.insert('users', {
        'nombre': 'Manuel',
        'email': 'mfornes@uci.cu',
        'telefono': 'xxxxxxxx',
        'password': AuthUtils.hashPassword('admin123'),
        'role': 'admin',
      });
    }
  }

  Future<bool> login(String email, String password) async {
    final db = await database;
    List<Map<String, dynamic>> res = await db.query(
      'users',
      where: "email = ?",
      whereArgs: [email],
    );

    if (res.isEmpty) return false;

    final storedHash = res.first['password'] as String;
    return AuthUtils.verifyPassword(password, storedHash);
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // Borrar Usuario
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> registerUser(User user) async {
    final db = await database;
    try {
      return await db.insert('users', user.toMap());
    } catch (e) {
      return -1;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    List<Map<String, dynamic>> res = await db.query(
      'users',
      where: "email = ?",
      whereArgs: [email],
    );

    if (res.isNotEmpty) {
      return User.fromMap(res.first);
    }
    return null;
  }

  // --- VALIDACIONES DE NOMBRE ÚNICO ---

  Future<bool> nombreEjercicioExiste(String nombre, {int? excludeId}) async {
    final db = await database;
    String where = 'LOWER(nombre) = LOWER(?)';
    List<dynamic> args = [nombre.trim()];
    if (excludeId != null) {
      where += ' AND id != ?';
      args.add(excludeId);
    }
    final res = await db.rawQuery(
      'SELECT id FROM ejercicios WHERE $where',
      args,
    );
    return res.isNotEmpty;
  }

  Future<bool> nombreCompetidorExiste(String nombre, {int? excludeId}) async {
    final db = await database;
    String where = 'LOWER(nombre) = LOWER(?)';
    List<dynamic> args = [nombre.trim()];
    if (excludeId != null) {
      where += ' AND id != ?';
      args.add(excludeId);
    }
    final res = await db.rawQuery(
      'SELECT id FROM competidores WHERE $where',
      args,
    );
    return res.isNotEmpty;
  }

  Future<bool> nombreEquipoExiste(String nombre, {int? excludeId}) async {
    final db = await database;
    String where = 'LOWER(nombre) = LOWER(?)';
    List<dynamic> args = [nombre.trim()];
    if (excludeId != null) {
      where += ' AND id != ?';
      args.add(excludeId);
    }
    final res = await db.rawQuery('SELECT id FROM equipos WHERE $where', args);
    return res.isNotEmpty;
  }

  Future<int> insertEjercicio(Map<String, dynamic> row) async {
    final nombre = row['nombre']?.toString().trim() ?? '';
    if (await nombreEjercicioExiste(nombre)) {
      throw Exception('Ya existe un ejercicio con el nombre "$nombre".');
    }
    final db = await database;
    return await db.insert('ejercicios', {...row, 'nombre': nombre});
  }

  Future<List<Map<String, dynamic>>> getEjercicios() async {
    final db = await database;
    return await db.query('ejercicios');
  }

  Future<int> deleteEjercicio(int id) async {
    final db = await database;
    return await db.delete('ejercicios', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateEjercicio(Map<String, dynamic> row) async {
    final nombre = row['nombre']?.toString().trim() ?? '';
    if (await nombreEjercicioExiste(nombre, excludeId: row['id'] as int?)) {
      throw Exception('Ya existe un ejercicio con el nombre "$nombre".');
    }
    final db = await database;
    return await db.update(
      'ejercicios',
      {...row, 'nombre': nombre},
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  // --- CRUD COMPETIDORES MODIFICADO ---
  Future<int> insertCompetidor(Map<String, dynamic> row) async {
    final nombre = row['nombre']?.toString().trim() ?? '';
    if (await nombreCompetidorExiste(nombre)) {
      throw Exception('Ya existe un competidor con el nombre "$nombre".');
    }
    return (await database).insert('competidores', {...row, 'nombre': nombre});
  }

  // Se agrega un JOIN para traer el nombre del equipo
  Future<List<Map<String, dynamic>>> getCompetidores() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.*, e.nombre AS nombre_equipo 
      FROM competidores c
      LEFT JOIN equipo_integrantes ei ON c.id = ei.competidor_id
      LEFT JOIN equipos e ON ei.equipo_id = e.id
    ''');
  }

  Future<int> updateCompetidor(Map<String, dynamic> row) async {
    final db = await database;

    // Solo validar y actualizar el nombre si se incluye en el mapa
    if (row.containsKey('nombre')) {
      final nombre = row['nombre'].toString().trim();
      if (await nombreCompetidorExiste(nombre, excludeId: row['id'] as int?)) {
        throw Exception('Ya existe un competidor con el nombre "$nombre".');
      }
      return await db.update(
        'competidores',
        row,
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }

    // Si no se incluye nombre, actualizar solo los campos proporcionados
    return await db.update(
      'competidores',
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  Future<int> deleteCompetidor(int id) async =>
      (await database).delete('competidores', where: 'id = ?', whereArgs: [id]);

  // --- CRUD EQUIPOS E INTEGRANTES ---
  Future<int> insertEquipo(
    Map<String, dynamic> row,
    List<int> competidoresIds,
  ) async {
    // Validar nombre único
    final nombre = row['nombre']?.toString().trim() ?? '';
    if (await nombreEquipoExiste(nombre)) {
      throw Exception('Ya existe un equipo con el nombre "$nombre".');
    }

    // Validar composición del equipo antes de insertar
    final validacion = await validarComposicionEquipo(competidoresIds);

    if (validacion['valido'] != true) {
      throw Exception(validacion['mensaje']);
    }

    final db = await database;
    return await db.transaction((txn) async {
      int id = await txn.insert('equipos', {...row, 'nombre': nombre});
      for (var compId in competidoresIds) {
        await txn.insert('equipo_integrantes', {
          'equipo_id': id,
          'competidor_id': compId,
        });
      }
      notifyListeners();
      return id;
    });
  }

  Future<List<Map<String, dynamic>>> getEquipos() async =>
      (await database).query('equipos');

  Future<List<Map<String, dynamic>>> getIntegrantesEquipo(int equipoId) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT c.* FROM competidores c 
      JOIN equipo_integrantes ei ON c.id = ei.competidor_id 
      WHERE ei.equipo_id = ?''',
      [equipoId],
    );
  }

  // En database_helper.dart
  Future<void> vincularEquipoAEvento(int equipoId, String nombreEvento) async {
    final db = await database;

    // 1. Primero desvinculamos de eventos previos para evitar duplicados en diferentes eventos
    await eliminarEquipoDeTodosLosEventos(equipoId);

    // 2. Buscamos el evento destino
    List<Map<String, dynamic>> eventos = await db.query(
      'eventos',
      where: 'nombre = ?',
      whereArgs: [nombreEvento],
    );

    if (eventos.isNotEmpty) {
      var evento = eventos.first;
      String actuales = evento['equipos_ids']?.toString() ?? "";

      List<String> idsList = actuales
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e != '-')
          .toList();

      if (!idsList.contains(equipoId.toString())) {
        idsList.add(equipoId.toString());
        await db.update(
          'eventos',
          {'equipos_ids': idsList.join(',')},
          where: 'id = ?',
          whereArgs: [evento['id']],
        );
        await db.rawUpdate(
          '''
        UPDATE competidores 
        SET evento = ? 
        WHERE id IN (
          SELECT competidor_id FROM equipo_integrantes WHERE equipo_id = ?
        )
        ''',
          [nombreEvento, equipoId],
        );
        notifyListeners();
      }
    }
  }

  /// Limpia el ID de un equipo de todos los eventos registrados
  Future<void> eliminarEquipoDeTodosLosEventos(int equipoId) async {
    final db = await database;
    List<Map<String, dynamic>> eventos = await db.query('eventos');

    for (var ev in eventos) {
      String idsActuales = ev['equipos_ids']?.toString() ?? "";
      if (idsActuales.contains(equipoId.toString())) {
        List<String> nuevaLista = idsActuales
            .split(',')
            .map((e) => e.trim())
            .where(
              (id) => id.isNotEmpty && id != '-' && id != equipoId.toString(),
            )
            .toList();

        await db.update(
          'eventos',
          {'equipos_ids': nuevaLista.isEmpty ? '-' : nuevaLista.join(',')},
          where: 'id = ?',
          whereArgs: [ev['id']],
        );
      }
    }
    // --- NUEVA LÓGICA: Limpiar evento en los integrantes ---
    await db.rawUpdate(
      '''
    UPDATE competidores 
    SET evento = '-' 
    WHERE id IN (
      SELECT competidor_id FROM equipo_integrantes WHERE equipo_id = ?
    )
  ''',
      [equipoId],
    );
    notifyListeners();
  }
  // En database_helper.dart

  Future<void> desvincularAtletasDeEquipo(String nombreEquipo) async {
    try {
      final db = await database; // Asegúrate de esperar la base de datos

      // Actualizamos los competidores cuyo nombre_equipo coincida
      await db.update(
        'competidores',
        {'nombre_equipo': null}, // Ponemos null para que queden libres
        where: 'nombre_equipo = ?',
        whereArgs: [nombreEquipo.trim()],
      );

      debugPrint("Atletas desvinculados del equipo: $nombreEquipo");
      notifyListeners();
    } catch (e) {
      debugPrint("Error en desvincularAtletasDeEquipo: $e");
    }
  }

  /// Obtiene una lista de ejercicios basándose en sus IDs
  Future<List<Ejercicio>> getEjerciciosByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final db = await database;

    final placeholders = ids.map((e) => '?').join(',');
    final results = await db.rawQuery(
      'SELECT * FROM ejercicios WHERE id IN ($placeholders)',
      ids,
    );

    return results.map((map) => Ejercicio.fromMap(map)).toList();
  }

  /// Obtiene un equipo con sus ejercicios poblados desde el evento
  Future<Equipo?> getEquipoConEjercicios(int equipoId) async {
    final db = await database;

    final equipoMaps = await db.query(
      'equipos',
      where: 'id = ?',
      whereArgs: [equipoId],
    );

    if (equipoMaps.isEmpty) return null;

    final equipoMap = equipoMaps.first;
    final equipo = Equipo.fromMap(equipoMap);

    final nombreEvento = equipo.evento;

    if (nombreEvento == '-' || nombreEvento.isEmpty) {
      return equipo;
    }

    final eventoMaps = await db.query(
      'eventos',
      where: 'nombre = ?',
      whereArgs: [nombreEvento],
    );

    if (eventoMaps.isEmpty) {
      return equipo;
    }

    final ejerciciosIdsString = eventoMaps.first['ejercicios_ids'] as String?;

    if (ejerciciosIdsString == null ||
        ejerciciosIdsString == '-' ||
        ejerciciosIdsString.isEmpty) {
      return equipo;
    }

    final ejerciciosIds = ejerciciosIdsString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => int.parse(e))
        .toList();

    final ejercicios = await getEjerciciosByIds(ejerciciosIds);

    return equipo.copyWith(ejercicios: ejercicios);
  }

  /// Obtiene todos los equipos con sus ejercicios poblados
  Future<List<Equipo>> getEquiposConEjercicios() async {
    final db = await database;

    final equiposMaps = await db.query('equipos');

    final equiposConEjercicios = <Equipo>[];

    for (final equipoMap in equiposMaps) {
      final equipoId = equipoMap['id'] as int;
      final equipo = await getEquipoConEjercicios(equipoId);

      if (equipo != null) {
        equiposConEjercicios.add(equipo);
      }
    }

    return equiposConEjercicios;
  }

  /// Vincula un equipo a un evento específico por su nombre

  Future<void> updateEquipo(
    Map<String, dynamic> row,
    List<int> competidoresIds,
  ) async {
    // Validar nombre único (excluir el propio equipo)
    final nombre = row['nombre']?.toString().trim() ?? '';
    if (await nombreEquipoExiste(nombre, excludeId: row['id'] as int?)) {
      throw Exception('Ya existe un equipo con el nombre "$nombre".');
    }

    // Validar composición del equipo antes de actualizar
    final validacion = await validarComposicionEquipo(competidoresIds);

    if (validacion['valido'] != true) {
      throw Exception(validacion['mensaje']);
    }

    final db = await database;
    await db.transaction((txn) async {
      await txn.rawUpdate(
        '''
        UPDATE competidores SET evento = '-' 
        WHERE id IN (SELECT competidor_id FROM equipo_integrantes WHERE equipo_id = ?)
      ''',
        [row['id']],
      );
      await txn.update(
        'equipos',
        {...row, 'nombre': nombre},
        where: 'id = ?',
        whereArgs: [row['id']],
      );
      await txn.delete(
        'equipo_integrantes',
        where: 'equipo_id = ?',
        whereArgs: [row['id']],
      );
      for (var compId in competidoresIds) {
        await txn.insert('equipo_integrantes', {
          'equipo_id': row['id'],
          'competidor_id': compId,
        });
      }
      final equipoData = await txn.query(
        'equipos',
        columns: ['evento'],
        where: 'id = ?',
        whereArgs: [row['id']],
      );

      String eventoActual = '-';
      if (equipoData.isNotEmpty) {
        eventoActual = (equipoData.first['evento'] as String?) ?? '-';
      }
      await txn.rawUpdate(
        '''
        UPDATE competidores SET evento = ? 
        WHERE id IN (SELECT competidor_id FROM equipo_integrantes WHERE equipo_id = ?)
      ''',
        [eventoActual, row['id']],
      );
    });
    notifyListeners();
  }

  Future<int> deleteEquipo(int id) async {
    final db = await database;

    return await db.transaction((txn) async {
      try {
        // 1. Limpiar el evento de los competidores
        await txn.rawUpdate(
          '''UPDATE competidores SET evento = '-' 
             WHERE id IN (
               SELECT competidor_id FROM equipo_integrantes WHERE equipo_id = ?
             )''',
          [id],
        );

        // 2. Eliminar las relaciones en equipo_integrantes
        await txn.delete(
          'equipo_integrantes',
          where: 'equipo_id = ?',
          whereArgs: [id],
        );

        // 3. Eliminar el equipo
        int resultado = await txn.delete(
          'equipos',
          where: 'id = ?',
          whereArgs: [id],
        );

        notifyListeners();
        return resultado;
      } catch (e) {
        debugPrint('Error en deleteEquipo: $e');
        rethrow;
      }
    });
  }

  Future<List<Map<String, dynamic>>> getEvaluacionesPendientes() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.*, e.nombre AS nombre_equipo 
      FROM competidores c
      LEFT JOIN equipo_integrantes ei ON c.id = ei.competidor_id
      LEFT JOIN equipos e ON ei.equipo_id = e.id
      WHERE c.evaluacion_ejercicios = '-' OR c.evaluacion_ejercicios IS NULL OR c.evaluacion_ejercicios = ''
    ''');
  }

  Future<List<Map<String, dynamic>>> getCompetidoresSinEquipo(
    int? equipoActualId,
  ) async {
    final db = await database;

    List<Map<String, dynamic>> todosLosCompetidores = await db.query(
      'competidores',
      orderBy: 'nombre ASC',
    );

    if (equipoActualId == null) {
      List<Map<String, dynamic>> competidoresEnEquipo = await db.query(
        'equipo_integrantes',
        columns: ['competidor_id'],
      );
      // print('DEBUG: Competidores en otros equipos: ${competidoresEnOtrosEquipos.length}');
      Set<int> idsEnEquipo = competidoresEnEquipo
          .map((e) => e['competidor_id'] as int)
          .toSet();

      return todosLosCompetidores
          .where((c) => !idsEnEquipo.contains(c['id'] as int))
          .toList();
    } else {
      List<Map<String, dynamic>> competidoresEnOtrosEquipos = await db.query(
        'equipo_integrantes',
        columns: ['competidor_id'],
        where: 'equipo_id != ?',
        whereArgs: [equipoActualId],
      );
      Set<int> idsEnOtrosEquipos = competidoresEnOtrosEquipos
          .map((e) => e['competidor_id'] as int)
          .toSet();

      return todosLosCompetidores
          .where((c) => !idsEnOtrosEquipos.contains(c['id'] as int))
          .toList();
    }
  }

  Future<List<Map<String, dynamic>>> getEvaluacionesRecientes() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.*, e.nombre AS nombre_equipo 
      FROM competidores c
      LEFT JOIN equipo_integrantes ei ON c.id = ei.competidor_id
      LEFT JOIN equipos e ON ei.equipo_id = e.id
      WHERE c.evaluacion_ejercicios != '-' AND c.evaluacion_ejercicios IS NOT NULL AND c.evaluacion_ejercicios != ''
      ORDER BY c.id DESC LIMIT 5
    ''');
  }

  Future<List<Ejercicio>> getEjerciciosDeCompetidor(int competidorId) async {
    final db = await database;

    // 1. Buscar el equipo del competidor
    final equipoMaps = await db.rawQuery(
      '''
      SELECT e.* FROM equipos e
      JOIN equipo_integrantes ei ON e.id = ei.equipo_id
      WHERE ei.competidor_id = ?
    ''',
      [competidorId],
    );

    // Si no tiene equipo, retornar lista vacía
    if (equipoMaps.isEmpty) return [];

    final equipoMap = equipoMaps.first;
    final nombreEvento = equipoMap['evento'] as String?;

    // Si el equipo no tiene evento asignado
    if (nombreEvento == null || nombreEvento == '-' || nombreEvento.isEmpty) {
      return [];
    }

    // 2. Buscar el evento
    final eventoMaps = await db.query(
      'eventos',
      where: 'nombre = ?',
      whereArgs: [nombreEvento],
    );

    if (eventoMaps.isEmpty) return [];

    // 3. Obtener los IDs de ejercicios del evento
    final ejerciciosIdsString = eventoMaps.first['ejercicios_ids'] as String?;

    if (ejerciciosIdsString == null ||
        ejerciciosIdsString == '-' ||
        ejerciciosIdsString.isEmpty) {
      return [];
    }

    // 4. Parsear los IDs y obtener los ejercicios
    final ejerciciosIds = ejerciciosIdsString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => int.parse(e))
        .toList();

    // 5. Retornar los ejercicios completos
    return await getEjerciciosByIds(ejerciciosIds);
  }

  //Panel ejercicios
  Future<void> actualizarEjerciciosCompletos(
    int competidorId,
    List<String> listaNuevosEjercicios,
  ) async {
    final db = await database;
    await db.update(
      'competidores',
      {'ejercicios_participados': listaNuevosEjercicios.join(', ')},
      where: 'id = ?',
      whereArgs: [competidorId],
    );
  }

  Future<void> agregarEjercicioACompetidor(
    int competidorId,
    String nombreEjercicio,
  ) async {
    final db = await database;
    List<Map<String, dynamic>> res = await db.query(
      'competidores',
      columns: ['ejercicios_participados'],
      where: 'id = ?',
      whereArgs: [competidorId],
    );

    if (res.isEmpty) return;

    String actuales = res.first['ejercicios_participados'] ?? "";
    List<String> lista = actuales
        .split(', ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e != '-')
        .toList();

    if (!lista.contains(nombreEjercicio)) {
      lista.add(nombreEjercicio);
      await db.update(
        'competidores',
        {'ejercicios_participados': lista.join(', ')},
        where: 'id = ?',
        whereArgs: [competidorId],
      );
    }
  }

  //Evento
  Future<List<Map<String, dynamic>>> getEventos() async {
    final db = await database;
    return await db.query('eventos');
  }

  Future<int> updateEvento(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      'eventos',
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }
  // En database_helper.dart

  Future<void> eliminarEjercicioDeTodosLosEventos(int ejercicioId) async {
    final db = await database;
    // Obtenemos todos los eventos
    List<Map<String, dynamic>> eventos = await db.query('eventos');

    for (var ev in eventos) {
      String idsActuales = ev['ejercicios_ids']?.toString() ?? "";

      if (idsActuales.contains(ejercicioId.toString())) {
        // Filtramos la lista para quitar el ID
        List<String> nuevaLista = idsActuales
            .split(',')
            .map((e) => e.trim())
            .where((id) => id.isNotEmpty && id != ejercicioId.toString())
            .toList();

        // Actualizamos con la lista limpia o '-' si quedó vacía
        await db.update(
          'eventos',
          {'ejercicios_ids': nuevaLista.isEmpty ? '-' : nuevaLista.join(',')},
          where: 'id = ?',
          whereArgs: [ev['id']],
        );
      }
    }
  }

  // Vinculaciones
  Future<void> vincularEjercicioACompetidor(
    int competidorId,
    String nombreEjercicio,
  ) async {
    final db = await database;

    // 1. Obtener los ejercicios actuales del competidor
    List<Map<String, dynamic>> res = await db.query(
      'competidores',
      columns: ['ejercicios_participados'],
      where: 'id = ?',
      whereArgs: [competidorId],
    );

    if (res.isEmpty) return;

    String actuales = res.first['ejercicios_participados'] ?? "";

    // 2. Si el ejercicio no está en la lista, lo agregamos (Evita duplicados como pediste)
    List<String> lista = actuales
        .split(', ')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (!lista.contains(nombreEjercicio)) {
      lista.add(nombreEjercicio);
      String nuevoListado = lista.join(', ');

      // 3. Actualizar la tabla competidores
      await db.update(
        'competidores',
        {'ejercicios_participados': nuevoListado},
        where: 'id = ?',
        whereArgs: [competidorId],
      );
    }
  }

  Future<double> getPuntajeEnEjercicio(
    int competidorId,
    String nombreEjercicio,
  ) async {
    final db = await database;

    // Obtener la evaluación del competidor
    final result = await db.query(
      'competidores',
      columns: ['evaluacion_ejercicios'],
      where: 'id = ?',
      whereArgs: [competidorId],
    );

    if (result.isEmpty) return 0.0;

    String evaluacion =
        result.first['evaluacion_ejercicios']?.toString() ?? '-';
    if (evaluacion == '-' || evaluacion.isEmpty) return 0.0;

    // Parsear la evaluación (formato: "Ejercicio1: 85 | Ejercicio2: 90")
    List<String> ejercicios = evaluacion.split(' | ');
    for (var item in ejercicios) {
      List<String> partes = item.split(':');
      if (partes.length == 2) {
        String nombre = partes[0].trim();
        if (nombre == nombreEjercicio) {
          return double.tryParse(partes[1].trim()) ?? 0.0;
        }
      }
    }

    return 0.0;
  }

  /// Obtiene el ranking de todos los competidores en un ejercicio específico
  /// Retorna lista ordenada de mayor a menor puntaje
  Future<List<Map<String, dynamic>>> getRankingPorEjercicio(
    String nombreEjercicio,
  ) async {
    final db = await database;

    // Obtener todos los competidores con evaluaciones
    final competidores = await db.rawQuery('''
      SELECT c.*, e.nombre AS nombre_equipo 
      FROM competidores c
      LEFT JOIN equipo_integrantes ei ON c.id = ei.competidor_id
      LEFT JOIN equipos e ON ei.equipo_id = e.id
      WHERE c.evaluacion_ejercicios != '-' 
        AND c.evaluacion_ejercicios IS NOT NULL 
        AND c.evaluacion_ejercicios != ''
    ''');

    // Lista para almacenar competidores con sus puntajes en este ejercicio
    List<Map<String, dynamic>> competidoresConPuntaje = [];

    for (var comp in competidores) {
      double puntaje = await getPuntajeEnEjercicio(
        comp['id'] as int,
        nombreEjercicio,
      );

      // Solo incluir competidores que participaron en este ejercicio
      if (puntaje > 0) {
        Map<String, dynamic> competidorConPuntaje = Map<String, dynamic>.from(
          comp,
        );
        competidorConPuntaje['puntaje_ejercicio'] = puntaje;
        competidoresConPuntaje.add(competidorConPuntaje);
      }
    }

    // Ordenar por puntaje descendente
    competidoresConPuntaje.sort(
      (a, b) => (b['puntaje_ejercicio'] as double).compareTo(
        a['puntaje_ejercicio'] as double,
      ),
    );

    // Agregar posición
    for (int i = 0; i < competidoresConPuntaje.length; i++) {
      competidoresConPuntaje[i]['posicion_ejercicio'] = i + 1;
    }

    return competidoresConPuntaje;
  }

  /// Obtiene la posición de un competidor específico en un ejercicio
  /// Retorna 0 si no participó en ese ejercicio
  Future<int> getPosicionEnEjercicio(
    int competidorId,
    String nombreEjercicio,
  ) async {
    final ranking = await getRankingPorEjercicio(nombreEjercicio);

    for (var comp in ranking) {
      if (comp['id'] == competidorId) {
        return comp['posicion_ejercicio'] as int;
      }
    }

    return 0; // No participó en este ejercicio
  }

  /// Obtiene todos los rankings (uno por cada ejercicio) para un evento específico
  Future<Map<String, List<Map<String, dynamic>>>> getRankingsPorEvento(
    String nombreEvento,
  ) async {
    final db = await database;

    // Obtener los ejercicios del evento
    final eventoMaps = await db.query(
      'eventos',
      where: 'nombre = ?',
      whereArgs: [nombreEvento],
    );

    if (eventoMaps.isEmpty) return {};

    final ejerciciosIdsString = eventoMaps.first['ejercicios_ids'] as String?;
    if (ejerciciosIdsString == null ||
        ejerciciosIdsString == '-' ||
        ejerciciosIdsString.isEmpty) {
      return {};
    }

    final ejerciciosIds = ejerciciosIdsString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => int.parse(e))
        .toList();

    final ejercicios = await getEjerciciosByIds(ejerciciosIds);

    // Crear mapa de rankings (nombreEjercicio -> lista de competidores ordenados)
    Map<String, List<Map<String, dynamic>>> rankings = {};

    for (var ejercicio in ejercicios) {
      rankings[ejercicio.nombre] = await getRankingPorEjercicio(
        ejercicio.nombre,
      );
    }

    return rankings;
  }

  /// Obtiene un resumen del desempeño de un competidor en todos sus ejercicios
  Future<Map<String, dynamic>> getResumenCompetidor(int competidorId) async {
    final db = await database;

    // Obtener datos del competidor
    final compResult = await db.rawQuery(
      '''
      SELECT c.*, e.nombre AS nombre_equipo, eq.evento AS evento_equipo
      FROM competidores c
      LEFT JOIN equipo_integrantes ei ON c.id = ei.competidor_id
      LEFT JOIN equipos eq ON ei.equipo_id = eq.id
      LEFT JOIN equipos e ON ei.equipo_id = e.id
      WHERE c.id = ?
    ''',
      [competidorId],
    );

    if (compResult.isEmpty) return {};

    final competidor = compResult.first;

    // Obtener ejercicios del competidor
    final ejercicios = await getEjerciciosDeCompetidor(competidorId);

    // Obtener puntajes y posiciones en cada ejercicio
    List<Map<String, dynamic>> detallesEjercicios = [];
    double sumaTotal = 0;
    int ejerciciosParticipados = 0;

    for (var ejercicio in ejercicios) {
      double puntaje = await getPuntajeEnEjercicio(
        competidorId,
        ejercicio.nombre,
      );
      if (puntaje > 0) {
        int posicion = await getPosicionEnEjercicio(
          competidorId,
          ejercicio.nombre,
        );
        detallesEjercicios.add({
          'nombre_ejercicio': ejercicio.nombre,
          'puntaje': puntaje,
          'posicion': posicion,
        });
        sumaTotal += puntaje;
        ejerciciosParticipados++;
      }
    }

    double promedio = ejerciciosParticipados > 0
        ? sumaTotal / ejerciciosParticipados
        : 0;

    return {
      'competidor': competidor,
      'ejercicios_detalle': detallesEjercicios,
      'total_puntos': sumaTotal,
      'promedio': promedio,
      'ejercicios_participados': ejerciciosParticipados,
    };
  }

  /// Obtiene ranking general de todos los competidores por puntuación total

  /// Obtiene la puntuación total de un equipo (suma de puntuaciones de todos sus integrantes)
  Future<double> getPuntuacionTotalEquipo(int equipoId) async {
    final integrantes = await getIntegrantesEquipo(equipoId);
    double sumaTotal = 0;

    for (var integrante in integrantes) {
      double puntuacion = await getPuntuacionTotalCompetidor(integrante['id']);
      sumaTotal += puntuacion;
    }

    return sumaTotal;
  }

  /// Obtiene un resumen del desempeño de un equipo
  Future<Map<String, dynamic>> getResumenEquipo(int equipoId) async {
    final db = await database;

    // Obtener datos del equipo
    final equipoResult = await db.query(
      'equipos',
      where: 'id = ?',
      whereArgs: [equipoId],
    );

    if (equipoResult.isEmpty) return {};

    final equipo = equipoResult.first;

    // Obtener integrantes con sus puntuaciones
    final integrantes = await getIntegrantesEquipo(equipoId);
    List<Map<String, dynamic>> integrantesDetalle = [];
    double sumaTotal = 0;

    for (var integrante in integrantes) {
      double puntuacion = await getPuntuacionTotalCompetidor(integrante['id']);
      integrantesDetalle.add({
        'nombre': integrante['nombre'],
        'id': integrante['id'],
        'puntuacion': puntuacion,
      });
      sumaTotal += puntuacion;
    }

    // Ordenar integrantes por puntuación
    integrantesDetalle.sort(
      (a, b) =>
          (b['puntuacion'] as double).compareTo(a['puntuacion'] as double),
    );

    double promedio = integrantes.isNotEmpty
        ? sumaTotal / integrantes.length
        : 0;

    return {
      'equipo': equipo,
      'integrantes_detalle': integrantesDetalle,
      'total_puntos': sumaTotal,
      'promedio': promedio,
      'total_integrantes': integrantes.length,
    };
  }

  Future<double> getPuntuacionTotalCompetidor(int competidorId) async {
    final db = await database;

    final result = await db.query(
      'competidores',
      columns: ['evaluacion_gral'],
      where: 'id = ?',
      whereArgs: [competidorId],
    );

    if (result.isEmpty) return 0.0;

    String evaluacion = result.first['evaluacion_gral']?.toString() ?? '0';
    return double.tryParse(evaluacion) ?? 0.0;
  }

  /// Obtiene ranking general de todos los competidores por puntuación total
  /// Filtrado por evento y sexo
  Future<List<Map<String, dynamic>>> getRankingGeneralCompetidores({
    String? evento,
    String? sexo,
  }) async {
    final db = await database;

    String query = '''
      SELECT c.*, e.nombre AS nombre_equipo 
      FROM competidores c
      LEFT JOIN equipo_integrantes ei ON c.id = ei.competidor_id
      LEFT JOIN equipos e ON ei.equipo_id = e.id
      WHERE c.evaluacion_gral IS NOT NULL 
        AND c.evaluacion_gral != '-' 
        AND c.evaluacion_gral != ''
    ''';

    List<String> queryArgs = [];

    // Filtrar por evento si se especifica
    if (evento != null && evento != '-') {
      query += " AND c.evento = ?";
      queryArgs.add(evento);
    }

    // Filtrar por sexo si se especifica
    if (sexo != null && sexo != '-' && sexo.isNotEmpty) {
      query += " AND c.sexo = ?";
      queryArgs.add(sexo);
    }

    final competidores = await db.rawQuery(query, queryArgs);

    // Convertir y agregar puntuación total
    List<Map<String, dynamic>> competidoresConPuntuacion = [];

    for (var comp in competidores) {
      Map<String, dynamic> competidorConPuntuacion = Map<String, dynamic>.from(
        comp,
      );
      double puntuacion =
          double.tryParse(comp['evaluacion_gral']?.toString() ?? '0') ?? 0.0;
      competidorConPuntuacion['puntuacion_total'] = puntuacion;

      if (puntuacion > 0) {
        competidoresConPuntuacion.add(competidorConPuntuacion);
      }
    }

    // Ordenar alfabéticamente por nombre
    competidoresConPuntuacion.sort((a, b) {
      String nombreA = (a['nombre'] ?? '').toString().toLowerCase();
      String nombreB = (b['nombre'] ?? '').toString().toLowerCase();
      return nombreA.compareTo(nombreB);
    });

    // Luego ordenar por puntuación descendente (esto mantiene el orden alfabético para empates)
    competidoresConPuntuacion.sort(
      (a, b) => (b['puntuacion_total'] as double).compareTo(
        a['puntuacion_total'] as double,
      ),
    );

    // Agregar posición
    for (int i = 0; i < competidoresConPuntuacion.length; i++) {
      competidoresConPuntuacion[i]['posicion_general'] = i + 1;
    }

    return competidoresConPuntuacion;
  }

  /// Obtiene ranking general de todos los equipos por puntuación total
  /// Filtrado por evento
  Future<List<Map<String, dynamic>>> getRankingGeneralEquipos({
    String? evento,
  }) async {
    final db = await database;

    String query = 'SELECT * FROM equipos';
    List<String> queryArgs = [];

    // Filtrar por evento si se especifica
    if (evento != null && evento != '-') {
      query += " WHERE evento = ?";
      queryArgs.add(evento);
    }

    final equipos = await db.rawQuery(query, queryArgs);

    List<Map<String, dynamic>> equiposConPuntuacion = [];

    for (var equipo in equipos) {
      double puntuacion = await getPuntuacionTotalEquipo(equipo['id'] as int);

      if (puntuacion > 0) {
        Map<String, dynamic> equipoConPuntuacion = Map<String, dynamic>.from(
          equipo,
        );
        equipoConPuntuacion['puntuacion_total'] = puntuacion;
        equiposConPuntuacion.add(equipoConPuntuacion);
      }
    }

    // Ordenar alfabéticamente por nombre
    equiposConPuntuacion.sort((a, b) {
      String nombreA = (a['nombre'] ?? '').toString().toLowerCase();
      String nombreB = (b['nombre'] ?? '').toString().toLowerCase();
      return nombreA.compareTo(nombreB);
    });

    // Luego ordenar por puntuación descendente
    equiposConPuntuacion.sort(
      (a, b) => (b['puntuacion_total'] as double).compareTo(
        a['puntuacion_total'] as double,
      ),
    );

    // Agregar posición
    for (int i = 0; i < equiposConPuntuacion.length; i++) {
      equiposConPuntuacion[i]['posicion_general'] = i + 1;
    }

    return equiposConPuntuacion;
  }

  /// Valida la composición de un equipo según las reglas:
  /// - Mínimo 4 integrantes, máximo 6
  /// - Debe tener al menos 2 mujeres y 2 hombres (titulares)
  /// - Puede tener hasta 3 mujeres y 3 hombres (con suplentes)
  Future<Map<String, dynamic>> validarComposicionEquipo(
    List<int> competidoresIds,
  ) async {
    if (competidoresIds.length < 4) {
      return {
        'valido': false,
        'mensaje': 'El equipo debe tener mínimo 4 integrantes',
      };
    }

    if (competidoresIds.length > 6) {
      return {
        'valido': false,
        'mensaje': 'El equipo puede tener máximo 6 integrantes',
      };
    }

    final db = await database;

    // Obtener información de los competidores
    final placeholders = competidoresIds.map((e) => '?').join(',');
    final competidores = await db.rawQuery(
      'SELECT sexo FROM competidores WHERE id IN ($placeholders)',
      competidoresIds,
    );

    int mujeres = 0;
    int hombres = 0;

    for (var comp in competidores) {
      String sexo = (comp['sexo'] ?? '').toString().toUpperCase();
      if (sexo == 'F' || sexo == 'FEMENINO') {
        mujeres++;
      } else if (sexo == 'M' || sexo == 'MASCULINO') {
        hombres++;
      }
    }

    // Validar que haya al menos 2 de cada sexo
    if (mujeres < 2) {
      return {
        'valido': false,
        'mensaje': 'El equipo debe tener al menos 2 mujeres',
        'mujeres': mujeres,
        'hombres': hombres,
      };
    }

    if (hombres < 2) {
      return {
        'valido': false,
        'mensaje': 'El equipo debe tener al menos 2 hombres',
        'mujeres': mujeres,
        'hombres': hombres,
      };
    }

    // Validar que no haya más de 3 de cada sexo
    if (mujeres > 3) {
      return {
        'valido': false,
        'mensaje': 'El equipo puede tener máximo 3 mujeres',
        'mujeres': mujeres,
        'hombres': hombres,
      };
    }

    if (hombres > 3) {
      return {
        'valido': false,
        'mensaje': 'El equipo puede tener máximo 3 hombres',
        'mujeres': mujeres,
        'hombres': hombres,
      };
    }

    return {
      'valido': true,
      'mensaje': 'Equipo válido: $mujeres mujeres y $hombres hombres',
      'mujeres': mujeres,
      'hombres': hombres,
    };
  }

  /// Obtiene ranking de equipos filtrado por sexo (cuenta solo mujeres o solo hombres)
  Future<List<Map<String, dynamic>>> getRankingGeneralEquiposPorSexo({
    String? evento,
    String? sexo,
  }) async {
    if (sexo == null || sexo == '-' || sexo.isEmpty) {
      // Si no hay filtro de sexo, retornar ranking normal
      return getRankingGeneralEquipos(evento: evento);
    }

    final db = await database;

    String query = 'SELECT * FROM equipos';
    List<String> queryArgs = [];

    // Filtrar por evento si se especifica
    if (evento != null && evento != '-') {
      query += " WHERE evento = ?";
      queryArgs.add(evento);
    }

    final equipos = await db.rawQuery(query, queryArgs);

    List<Map<String, dynamic>> equiposConPuntuacion = [];

    for (var equipo in equipos) {
      // Obtener integrantes del equipo
      final integrantes = await getIntegrantesEquipo(equipo['id'] as int);

      double puntuacionTotal = 0;

      // Sumar solo los puntajes de competidores del sexo especificado
      for (var integrante in integrantes) {
        String sexoIntegrante = (integrante['sexo'] ?? '')
            .toString()
            .toUpperCase();
        bool esSexoBuscado = false;

        if ((sexo.toUpperCase() == 'F' || sexo.toUpperCase() == 'FEMENINO') &&
            (sexoIntegrante == 'F' || sexoIntegrante == 'FEMENINO')) {
          esSexoBuscado = true;
        } else if ((sexo.toUpperCase() == 'M' ||
                sexo.toUpperCase() == 'MASCULINO') &&
            (sexoIntegrante == 'M' || sexoIntegrante == 'MASCULINO')) {
          esSexoBuscado = true;
        }

        if (esSexoBuscado) {
          double puntuacion = await getPuntuacionTotalCompetidor(
            integrante['id'],
          );
          puntuacionTotal += puntuacion;
        }
      }

      if (puntuacionTotal > 0) {
        Map<String, dynamic> equipoConPuntuacion = Map<String, dynamic>.from(
          equipo,
        );
        equipoConPuntuacion['puntuacion_total'] = puntuacionTotal;
        equiposConPuntuacion.add(equipoConPuntuacion);
      }
    }

    // Ordenar alfabéticamente por nombre
    equiposConPuntuacion.sort((a, b) {
      String nombreA = (a['nombre'] ?? '').toString().toLowerCase();
      String nombreB = (b['nombre'] ?? '').toString().toLowerCase();
      return nombreA.compareTo(nombreB);
    });

    // Luego ordenar por puntuación descendente
    equiposConPuntuacion.sort(
      (a, b) => (b['puntuacion_total'] as double).compareTo(
        a['puntuacion_total'] as double,
      ),
    );

    // Agregar posición
    for (int i = 0; i < equiposConPuntuacion.length; i++) {
      equiposConPuntuacion[i]['posicion_general'] = i + 1;
    }

    return equiposConPuntuacion;
  }

  /// Libera a los competidores de un equipo para que puedan ser asignados a otros
  /// NOTA: Este método ya no es necesario, deleteEquipo hace todo el trabajo
  Future<void> liberarIntegrantesDeEquipo(int equipoId) async {
    // Mantenido por compatibilidad pero ya no hace nada
    // deleteEquipo ahora maneja todo dentro de una transacción
    debugPrint('liberarIntegrantesDeEquipo llamado pero no necesario');
  }
}
