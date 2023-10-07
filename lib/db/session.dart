/// The Session table, listing who's using the app (vestigial from the online version)
part of gig_database;

class Session {
  final int id;
  final int user;
  final int gig;

  const Session({
    required this.id,
    required this.user,
    required this.gig,
  });

  // Convert a Session into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user': user,
      'gig': gig,
    };
  }

  @override
  String toString() {
    return 'Session{id: $id, user: $user, gig: $gig';
  }
}

// Return the SQL to create the session table
String createSessionTable() {
  return '''
    CREATE TABLE "session" (
      "id"	INTEGER NOT NULL UNIQUE,
      "user"	INTEGER,
      "gig"	INTEGER,
      PRIMARY KEY("id" AUTOINCREMENT),
      FOREIGN KEY("user") REFERENCES "user"("id"),
      FOREIGN KEY("gig") REFERENCES "gig"("id")
    );
  ''';
}

// Add a session to the database
Future<void> insertSession(session) async {
  final db = await database;
  await db.insert('session', session.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}

// Return a list of all the sessions
Future<List<Session>> sessions() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('session');

  return List.generate(maps.length, (index) {
    return Session(
      id: maps[index]['id'],
      user: maps[index]['user'],
      gig: maps[index]['gig'],
    );
  });
}

// Update a session
Future<void> updateSession(Session session) async {
  final db = await database;
  await db.update(
    'session',
    session.toMap(),
    where: 'id = ?',
    whereArgs: [session.id],
  );
}

// Delete a session 
Future<void> deleteSession(int id) async {
  final db = await database;
  await db.delete(
    'session',
    where: 'id = ?',
    whereArgs: [id],
  );
}