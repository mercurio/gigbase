/// The Band table, listing the names of the bands that have gigs.
part of gig_database;

class Band {
  final int id;
  final String name;
  final int viewableByOthers;
  final int editableByOthers;

  const Band({
    required this.id,
    required this.name,
    required this.viewableByOthers,
    required this.editableByOthers,
  });

  // Convert a Band into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'viewableByOthers': viewableByOthers,
      'editableByOthers': editableByOthers,
    };
  }

  @override
  String toString() {
    return 'Band{id: $id, name: $name, viewableByOthers: $viewableByOthers, editableByOthers: $editableByOthers}';
  }
}

// Return the SQL to create the band table
String createBandTable() {
  return '''
    CREATE TABLE "band" (
      "id"	INTEGER NOT NULL UNIQUE,
      "name"	TEXT,
      "viewableByOthers"	INTEGER DEFAULT 1,
      "editableByOthers"	INTEGER DEFAULT 1,
      PRIMARY KEY("id" AUTOINCREMENT)
    );
    ''';
}

/*
  var lb = const Band(
    id: 0,
    name: 'Leadbone',
    viewableByOthers: 1,
    editableByOthers: 1
  );

  final db = await database;
  await insertBand(db, lb);

  print(await bands(db));
*/

// Add a band to the database
Future<void> insertBand(band) async {
  final db = await database;
  await db.insert('band', band.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}

// Return a list of all the bands
Future<List<Band>> bands() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('band');

  return List.generate(maps.length, (index) {
    return Band(
      id: maps[index]['id'],
      name: maps[index]['name'],
      viewableByOthers: maps[index]['viewableByOthers'],
      editableByOthers: maps[index]['editableByOthers'],
    );
  });
}

// Update a band
Future<void> updateBand(Band band) async {
  final db = await database;
  await db.update(
    'band',
    band.toMap(),
    where: 'id = ?',
    whereArgs: [band.id],
  );
}

// Delete a band 
Future<void> deleteBand(int id) async {
  final db = await database;
  await db.delete(
    'band',
    where: 'id = ?',
    whereArgs: [id],
  );
}