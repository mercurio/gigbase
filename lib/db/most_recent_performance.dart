/// View of songs and their more recent performance dates
part of gig_database;

class Most_Recent_Performance {
  final int song_id;
  final String artist;
  final String title;
  final int recordings;
  final int serial;
  final int stars;
  final String drumkit;
  final String songkey;
  final String date;
  final int performance_id;

  const Most_Recent_Performance({
    required this.song_id,
    required this.artist,
    required this.title,
    required this.recordings,
    required this.serial,
    required this.stars,
    required this.drumkit,
    required this.songkey,
    required this.date,
    required this.performance_id,
  });

  // Convert a Most_Recent_Performance into a Map
  Map<String, dynamic> toMap() {
    return {
      'song_id': song_id,
      'artist': artist,
      'title': title,
      'recordings': recordings,
      'serial': serial,
      'stars': stars,
      'drumkit': drumkit,
      'songkey': songkey,
      'date': date,
      'performance_id': performance_id,
    };
  }

  @override
  String toString() {
    return 'Most_Recent_Performance{song_id: $song_id, title: $title, artist: $artist, date: $date, drumkit: $drumkit}';
  }
}

// Return the SQL to create the view
String createMost_Recent_PerformanceView() {
  return '''
    CREATE VIEW most_recent_performance AS
      SELECT song_recordings.song_id,
        song_recordings.artist,
        song_recordings.title,
        song_recordings.recordings,
        ifnull(song_latest_performance.serial, 0) AS serial,
        ifnull(song_latest_performance.stars, 0) AS stars,
        ifnull(song_latest_performance.drumkit, "") AS drumkit,
        ifnull(song_latest_performance.songkey, "") AS songkey,
        ifnull(song_latest_performance.latest, "1970-01-01") AS date,
        ifnull(song_latest_performance.performance_id, 0) AS performance_id
      FROM (song_recordings
        LEFT JOIN song_latest_performance ON ((song_latest_performance.song_id = song_recordings.song_id)))
      ORDER BY song_recordings.title COLLATE NOCASE ASC;
  ''';
}

// Return the view
Future<List<Most_Recent_Performance>> most_recent_performance() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('most_recent_performance');

  return List.generate(maps.length, (index) {
    return Most_Recent_Performance(
      song_id: maps[index]['song_id'],
      artist: maps[index]['artist'],
      title: maps[index]['title'],
      recordings: maps[index]['recordings'],
      serial: maps[index]['serial'],
      stars: maps[index]['stars'],
      drumkit: maps[index]['drumkit'],
      songkey: maps[index]['songkey'],
      date: maps[index]['date'],
      performance_id: maps[index]['performance_id'],
    );
  });
}