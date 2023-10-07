/// View of songs and recordings
part of gig_database;

class Song_Recordings {
  final int song_id;
  final String title;
  final String artist;
  final int recordings;

  const Song_Recordings({
    required this.song_id,
    required this.title,
    required this.artist,
    required this.recordings,
  });

  // Convert a Song_Recordings into a Map
  Map<String, dynamic> toMap() {
    return {
      'song_id': song_id,
      'title': title,
      'artist': artist,
      'recordings': recordings,
    };
  }

  @override
  String toString() {
    return 'Song_Recordings{song_id: $song_id, title: $title, artist: $artist, recordings: $recordings}';
  }
}

// Return the SQL to create the view
String createSong_RecordingsView() {
  return '''
    CREATE VIEW song_recordings AS
      SELECT song.id AS song_id,
        song.title,
        song.artist,
        (song.prehistory + count(performance.id)) AS recordings
      FROM (song
        LEFT JOIN performance ON performance.song = song.id)
      GROUP BY song.id
      ORDER BY song.id;
  ''';
}

// Return the view
Future<List<Song_Recordings>> song_recordings() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('song_recordings');

  return List.generate(maps.length, (index) {
    return Song_Recordings(
      song_id: maps[index]['song_id'],
      title: maps[index]['title'],
      artist: maps[index]['artist'],
      recordings: maps[index]['recordings'],
    );
  });
}