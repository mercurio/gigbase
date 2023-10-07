/// The Song table, listing song titles and artists
part of gig_database;

class Song {
  final int id;
  final String title;
  final String artist;
  final int prehistory;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.prehistory,
  });

  // Convert a Song into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'prehistory': prehistory,
    };
  }

  @override
  String toString() {
    return 'Song{id: $id, title: $title, artist: $artist, prehistory: $prehistory';
  }
}

// Return the SQL to create the song table
String createSongTable() {
  return '''
    CREATE TABLE "song" (
      "id"	INTEGER NOT NULL UNIQUE,
      "title"	TEXT NOT NULL,
      "artist"	TEXT,
      "prehistory"	INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("id" AUTOINCREMENT)
    );
  ''';
}

// Add a song to the database
Future<void> insertSong(song) async {
  final db = await database;
  await db.insert('song', song.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}

// Add a new song to the database with autoincremented id
Future<void> newSong(song) async {
  final db = await database;
  var map = song.toMap();

  map.remove('id');

  await db.insert('song', map, conflictAlgorithm: ConflictAlgorithm.replace);
}

// Return a list of all the songs
Future<List<Song>> songs() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('song');

  return List.generate(maps.length, (index) {
    return Song(
      id: maps[index]['id'],
      title: maps[index]['title'],
      artist: maps[index]['artist'],
      prehistory: maps[index]['prehistory'],
    );
  });
}

// Update a song
Future<void> updateSong(Song song) async {
  final db = await database;
  await db.update(
    'song',
    song.toMap(),
    where: 'id = ?',
    whereArgs: [song.id],
  );
}

// Delete a song 
Future<void> deleteSong(int id) async {
  final db = await database;
  await db.delete(
    'song',
    where: 'id = ?',
    whereArgs: [id],
  );
}