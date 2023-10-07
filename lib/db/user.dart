/// The User table, listing users of this app
part of gig_database;

class User {
  final int id;
  final String email;
  final String password;
  final String fullName;
  final String stageName;
  final String createdAt;
  final String updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.password,
    required this.fullName,
    required this.stageName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert a User into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'fullName': fullName,
      'stageName': stageName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, password: $password, fullName: $fullName, stageName: $stageName, createdAt: $createdAt, updatedAt: $updatedAt';
  }
}

// Return the SQL to create the user table
String createUserTable() {
  return '''
    CREATE TABLE "user" (
      "id"	INTEGER NOT NULL UNIQUE,
      "email"	TEXT NOT NULL,
      "password"	TEXT NOT NULL DEFAULT 'changeme',
      "fullName"	TEXT,
      "stageName"	TEXT,
      "createdAt"	TEXT,
      "updatedAt"	TEXT,
      PRIMARY KEY("id" AUTOINCREMENT)
    );
  ''';
}

// Add a user to the database
Future<void> insertUser(user) async {
  final db = await database;
  await db.insert('user', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}

// Return a list of all the users
Future<List<User>> users() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('user');

  return List.generate(maps.length, (index) {
    return User(
      id: maps[index]['id'],
      email: maps[index]['email'],
      password: maps[index]['password'],
      fullName: maps[index]['fullName'],
      stageName: maps[index]['stageName'],
      createdAt: maps[index]['createdAt'],
      updatedAt: maps[index]['updatedAt'],
    );
  });
}

// Update a user
Future<void> updateUser(User user) async {
  final db = await database;
  await db.update(
    'user',
    user.toMap(),
    where: 'id = ?',
    whereArgs: [user.id],
  );
}

// Delete a user 
Future<void> deleteUser(int id) async {
  final db = await database;
  await db.delete(
    'user',
    where: 'id = ?',
    whereArgs: [id],
  );
}