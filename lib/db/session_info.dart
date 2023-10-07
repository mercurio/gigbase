/// View of the currently logged in session
part of gig_database;

class Session_Info {
  final String fullName;
  final int userid;
  final String stageName;
  final int bandid;
  final String band;

  const Session_Info({
    required this.fullName,
    required this.userid,
    required this.stageName,
    required this.bandid,
    required this.band,
  });

  // Convert a Session_Info into a Map
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'userid': userid,
      'stageName': stageName,
      'bandid': bandid,
      'band': band,
    };
  }

  @override
  String toString() {
    return 'Session_Info fullName: $fullName, stageName: $stageName, userid: $userid, bandid: $bandid, band: $band}';
  }
}

// Return the SQL to create the view
String createSession_InfoView() {
  return '''
    CREATE VIEW session_info AS SELECT u.fullName AS fullName, u.id AS userid, u.stageName AS stageName, b.id AS bandid, b.name AS band
    FROM session s 
      JOIN user u ON s.user = u.id
      JOIN user_band ub ON u.id = ub.user
      JOIN band b ON ub.band = b.id;
  ''';
}

// Return the view
Future<List<Session_Info>> session_info() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('session_info');

  return List.generate(maps.length, (index) {
    return Session_Info(
      fullName: maps[index]['fullName'],
      userid: maps[index]['userid'],
      stageName: maps[index]['stageName'],
      bandid: maps[index]['bandid'],
      band: maps[index]['band'],
    );
  });
}