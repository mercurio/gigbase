/// The User_Band table, listing who's using the app (vestigial from the online version)
part of gig_database;

class User_Band {
  final int id;
  final int user;
  final int band;

  const User_Band({
    required this.id,
    required this.user,
    required this.band,
  });

  // Convert a User_Band into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user': user,
      'band': band,
    };
  }

  @override
  String toString() {
    return 'User_Band{id: $id, user: $user, band: $band';
  }
}

// Return the SQL to create the user_band table
String createUser_BandTable() {
  return '''
    CREATE TABLE "user_band" (
      "id"	INTEGER NOT NULL UNIQUE,
      "user"	INTEGER,
      "band"	INTEGER,
      FOREIGN KEY("band") REFERENCES "band"("id"),
      FOREIGN KEY("user") REFERENCES "song",
      PRIMARY KEY("id" AUTOINCREMENT)
    );
  ''';
}

// Add a user_band to the database
Future<void> insertUser_Band(user_band) async {
  final db = await database;
  await db.insert('user_band', user_band.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}

// Return a list of all the user_bands
Future<List<User_Band>> user_bands() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('user_band');

  return List.generate(maps.length, (index) {
    return User_Band(
      id: maps[index]['id'],
      user: maps[index]['user'],
      band: maps[index]['band'],
    );
  });
}

// Update a user_band
Future<void> updateUser_Band(User_Band user_band) async {
  final db = await database;
  await db.update(
    'user_band',
    user_band.toMap(),
    where: 'id = ?',
    whereArgs: [user_band.id],
  );
}

// Delete a user_band 
Future<void> deleteUser_Band(int id) async {
  final db = await database;
  await db.delete(
    'user_band',
    where: 'id = ?',
    whereArgs: [id],
  );
}