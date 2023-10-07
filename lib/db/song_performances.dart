/// View of songs and their more recent performance dates
part of gig_database;

class Song_Performances {
  final int song_id;
  final String title;
  final String artist;
  final int performance_id;
  final int serial;
  final int stars;
  final String songkey;
  final String drumkit;
  final int gig_id;
  final String venue;
  final String date;
  final int recorded;
  final int band;

  const Song_Performances({
    required this.song_id,
    required this.title,
    required this.artist,
    required this.performance_id,
    required this.serial,
    required this.stars,
    required this.songkey,
    required this.drumkit,
    required this.gig_id,
    required this.venue,
    required this.date,
    required this.recorded,
    required this.band,
  });

  // Convert a Song_Performances into a Map
  Map<String, dynamic> toMap() {
    return {
      'song_id': song_id,
      'title': title,
      'artist': artist,
      'performance_id': performance_id,
      'serial': serial,
      'stars': stars,
      'songkey': songkey,
      'drumkit': drumkit,
      'gig_id': gig_id,
      'venue': venue,
      'date': date,
      'recorded': recorded,
      'band': band,
    };
  }

  @override
  String toString() {
    return 'Song_Performances{song_id: $song_id, title: $title, artist: $artist, date: $date, drumkit: $drumkit}';
  }
}

// Return the SQL to create the view
String createSong_PerformancesView() {
  return '''
    CREATE VIEW song_performances AS
      SELECT song.id AS song_id,
        song.title,
        song.artist,
        performance.id AS performance_id,
        performance.serial,
        performance.stars,
        performance.songkey,
        performance.drumkit,
        gig.id AS gig_id,
        gig.venue,
        gig.date,
        gig.recorded,
        gig.band
      FROM song,
        performance,
        gig
      WHERE ((performance.song = song.id) AND (performance.gig = gig.id))
      ORDER BY song.title, gig.date DESC;

  ''';
}

// Return the view
Future<List<Song_Performances>> song_performances() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('song_performances');

  return List.generate(maps.length, (index) {
    return Song_Performances(
      song_id: maps[index]['song_id'],
      title: maps[index]['title'],
      artist: maps[index]['artist'],
      performance_id: maps[index]['performance_id'],
      serial: maps[index]['serial'],
      stars: maps[index]['stars'],
      songkey: maps[index]['songkey'],
      drumkit: maps[index]['drumkit'],
      gig_id: maps[index]['gig_id'],
      venue: maps[index]['venue'],
      date: maps[index]['date'],
      recorded: maps[index]['recorded'],
      band: maps[index]['band'],
    );
  });
}