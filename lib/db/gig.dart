/// The Gig table, listing the gig dates and venues for each band
part of gig_database;

class Gig {
  final int id;
  final String venue;
  final String date;
  final int recorded;
  final int band;

  const Gig({
    required this.id,
    required this.venue,
    required this.date,
    required this.recorded,
    required this.band,
  });

  // Convert a Gig into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'venue': venue,
      'date': date,
      'recorded': recorded,
      'band': band,
    };
  }

  @override
  String toString() {
    return 'Gig{id: $id, venue: $venue, date: $date, recorded: $recorded, band: $band}';
  }
}

// Return the SQL to create the gig table
String createGigTable() {
  return '''
    CREATE TABLE "gig" (
      "id"	INTEGER NOT NULL UNIQUE,
      "venue"	TEXT DEFAULT 'Leadbone Studios',
      "date"	TEXT,
      "recorded"	INTEGER DEFAULT 1,
      "band"	INTEGER,
      PRIMARY KEY("id" AUTOINCREMENT),
      FOREIGN KEY("band") REFERENCES "band"("id")
    );
  ''';
}

// Add a gig to the database
Future<void> insertGig(gig) async {
  final db = await database;
  await db.insert('gig', gig.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}

// Add a new gig to the database with autoincremented id
Future<void> newGig(gig) async {
  final db = await database;
  var map = gig.toMap();

  map.remove('id');

  await db.insert('gig', map, conflictAlgorithm: ConflictAlgorithm.replace);
}

// Return a list of all the gigs
Future<List<Gig>> gigs() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('gig');

  return List.generate(maps.length, (index) {
    return Gig(
      id: maps[index]['id'],
      venue: maps[index]['venue'],
      date: maps[index]['date'],
      recorded: maps[index]['recorded'],
      band: maps[index]['band'],
    );
  });
}

// Update a gig
Future<void> updateGig(Gig gig) async {
  final db = await database;
  await db.update(
    'gig',
    gig.toMap(),
    where: 'id = ?',
    whereArgs: [gig.id],
  );
}

// Delete a gig 
Future<void> deleteGig(int id) async {
  final db = await database;
  await db.delete(
    'gig',
    where: 'id = ?',
    whereArgs: [id],
  );
}