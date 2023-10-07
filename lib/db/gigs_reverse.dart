/// View of aall gigs in reverse chronological order
part of gig_database;

class Gigs_Reverse {
  final int id;
  final String date;
  final String venue;
  final int recorded;
  final int tracks;

  const Gigs_Reverse({
    required this.id,
    required this.date,
    required this.venue,
    required this.recorded,
    required this.tracks
  });

  // Convert a Gigs_Reverse into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'venue': venue,
      'recorded': recorded,
      'tracks': tracks,
    };
  }

  @override
  String toString() {
    return 'Gigs_Reverse{id: $id, date: $date, venue: $venue, recorded: $recorded, tracks: $tracks}';
  }
}

// Return the SQL to create the view
String createGigs_ReverseView() {
  return '''
    CREATE VIEW gigs_reverse AS SELECT g.id AS id, g.date AS date, g.venue AS venue, g.recorded AS recorded, COUNT(p.gig) AS tracks
      FROM gig g
      LEFT JOIN performance p ON g.id = p.gig
      GROUP BY g.date
      ORDER BY g.date DESC;
  ''';
}

// Return the view
Future<List<Gigs_Reverse>> gigs_reverse() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('gigs_reverse');

  return List.generate(maps.length, (index) {
    return Gigs_Reverse(
      id: maps[index]['id'],
      date: maps[index]['date'],
      venue: maps[index]['venue'],
      recorded: maps[index]['recorded'],
      tracks: maps[index]['tracks'],
    );
  });
}