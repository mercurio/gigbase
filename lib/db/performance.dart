/// The Performance table, listing the performance dates and venues for each band
part of gig_database;

class Performance {
  final int id;
  final int serial;
  final int stars;
  final int gig;
  final int song;
  final String drumkit;
  final String songkey;

  const Performance({
    required this.id,
    required this.serial,
    required this.stars,
    required this.gig,
    required this.song,
    required this.drumkit,
    required this.songkey,
  });

  // Convert a Performance into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serial': serial,
      'stars': stars,
      'gig': gig,
      'song': song,
      'drumkit': drumkit,
      'songkey': songkey,
    };
  }

  @override
  String toString() {
    return 'Performance{id: $id, serial: $serial, stars: $stars, gig: $gig, song: $song, drumkit: $drumkit, songkey: $songkey';
  }
}

// Return the SQL to create the performance table
String createPerformanceTable() {
  return '''
    CREATE TABLE "performance" (
      "id"	INTEGER NOT NULL UNIQUE,
      "serial"	INTEGER NOT NULL DEFAULT 1,
      "stars"	INTEGER,
      "gig"	INTEGER NOT NULL,
      "song"	INTEGER,
      "drumkit"	TEXT,
      "songkey"	TEXT,
      FOREIGN KEY("gig") REFERENCES "gig"("id"),
      FOREIGN KEY("song") REFERENCES "song"("id"),
      PRIMARY KEY("id" AUTOINCREMENT)
    );
  ''';
}

// Add a performance to the database
Future<int> insertPerformance(performance) async {
  final db = await database;
  return await db.insert('performance', performance.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}

// Add a new performance to the database with autoincremented id
Future<int> newPerformance(perf) async {
  final db = await database;
  var map = perf.toMap();

  map.remove('id');

  return await db.insert('performance', map, conflictAlgorithm: ConflictAlgorithm.replace);
}

// Return a list of all the performances
Future<List<Performance>> performances() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('performance');

  return List.generate(maps.length, (index) {
    return Performance(
      id: maps[index]['id'],
      serial: maps[index]['serial'],
      stars: maps[index]['stars'],
      gig: maps[index]['gig'],
      song: maps[index]['song'],
      drumkit: maps[index]['drumkit'],
      songkey: maps[index]['songkey'],
    );
  });
}

// Update a performance
Future<void> updatePerformance(Performance performance) async {
  final db = await database;
  await db.update(
    'performance',
    performance.toMap(),
    where: 'id = ?',
    whereArgs: [performance.id],
  );
}

// Update a performance from the edit gig form fields, 
// leaving the rest as is.
Future<void> updatePerformanceFromForm({
  required int id, required int song, required String drumkit, required String songkey, required int stars}) async {

  final db = await database;
  await db.update(
    'performance',
    {
      'song': song, 
      'drumkit': drumkit,
      'songkey': songkey,
      'stars': stars
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

// Delete a performance 
Future<void> deletePerformance(int id) async {
  final db = await database;
  await db.delete(
    'performance',
    where: 'id = ?',
    whereArgs: [id],
  );
}