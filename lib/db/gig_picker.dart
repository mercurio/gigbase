/// View of a gig as text
part of gig_database;

class Gig_Picker {
  final String text;

  const Gig_Picker({
    required this.text
  });

  // Convert a Gig_Picker into a Map
  Map<String, dynamic> toMap() {
    return {
      'text': text,
    };
  }

  @override
  String toString() {
    return 'Gig_Picker{text: $text}';
  }
}

// Return the SQL to create the view
String createGig_PickerView() {
  return '''
    CREATE VIEW gig_picker AS SELECT date || ' ' || venue || ' |' || id as text FROM gig ORDER BY date DESC;
  ''';
}

// Return the view
Future<List<Gig_Picker>> gig_picker() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('gig_picker');

  return List.generate(maps.length, (index) {
    return Gig_Picker(
      text: maps[index]['text'],
    );
  });
}