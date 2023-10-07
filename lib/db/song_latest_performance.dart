/// View of songs and their more recent performance dates
part of gig_database;

class Song_Latest_Performance {
  final int song_id;
  final String title;
  final String artist;
  final int serial;
  final String songkey;
  final int stars;
  final String drumkit;
  final String venue;
  final int recorded;
  final int performance_id;
  final String latest;

  const Song_Latest_Performance({
    required this.song_id,
    required this.title,
    required this.artist,
    required this.serial,
    required this.songkey,
    required this.stars,
    required this.drumkit,
    required this.venue,
    required this.recorded,
    required this.performance_id,
    required this.latest,
  });

  // Convert a Song_Latest_Performance into a Map
  Map<String, dynamic> toMap() {
    return {
      'song_id': song_id,
      'title': title,
      'artist': artist,
      'serial': serial,
      'songkey': songkey,
      'stars': stars,
      'drumkit': drumkit,
      'venue': venue,
      'recorded': recorded,
      'performance_id': performance_id,
      'latest': latest,
    };
  }

  @override
  String toString() {
    return 'Song_Latest_Performance{song_id: $song_id, title: $title, artist: $artist, latest: $latest, drumkit: $drumkit}';
  }
}

// Return the SQL to create the view
String createSong_Latest_PerformanceView() {
  return '''
    CREATE VIEW song_latest_performance AS
      SELECT y.song_id,
        y.title AS title,
        y.artist AS artist,
        y.serial AS serial,
        y.songkey AS songkey,
        y.stars AS stars,
        y.drumkit AS drumkit,
        y.venue AS venue,
        y.recorded AS recorded,
        y.performance_id AS performance_id,
        y.date AS latest
      FROM (
          SELECT song_id, max(date) as latest
          FROM song_performances GROUP BY song_id
      ) AS x inner join song_performances AS y ON y.song_id = x.song_id AND y.date = x.latest;
  ''';
}

// Return the view
Future<List<Song_Latest_Performance>> song_latest_performance() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('song_latest_performance');

  return List.generate(maps.length, (index) {
    return Song_Latest_Performance(
      song_id: maps[index]['song_id'],
      title: maps[index]['title'],
      artist: maps[index]['artist'],
      serial: maps[index]['serial'],
      songkey: maps[index]['songkey'],
      stars: maps[index]['stars'],
      drumkit: maps[index]['drumkit'],
      venue: maps[index]['venue'],
      recorded: maps[index]['recorded'],
      performance_id: maps[index]['performance_id'],
      latest: maps[index]['latest'],
    );
  });
}