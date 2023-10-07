/// Contents of the whole database, combining all of the tables and views.
/// Also contains the global 'database' variable.
library gig_database;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

part 'band.dart';
part 'gig.dart';
part 'performance.dart';
part 'session.dart';
part 'song.dart';
part 'user.dart';
part 'user_band.dart';

part 'gig_picker.dart';
part 'gigs_reverse.dart';
part 'song_latest_performance.dart';
part 'most_recent_performance.dart';
part 'song_performances.dart';
part 'song_recordings.dart';
part 'session_info.dart';

Future<Database> database = openDB();

Future<Database> openDB() async {
  return openDatabase(
    join(await getDatabasesPath(), 'gigbase.db'),
    onCreate: (db, version) => db.execute(createDatabase()),
    version: 1,
  );
}

// Raw SQL query
//
Future<List<Map>> sql(String s) async {
  final db = await database;
  return await db.rawQuery(s);
}

// Return the SQL to generate all of the tables
String createDatabase() {
  List<String> sql = [
    createBandTable(),
    createGigTable(),
    createPerformanceTable(),
    createSessionTable(),
    createSongTable(),
    createUserTable(),
    createUser_BandTable(),
    createGig_PickerView(),
    createGigs_ReverseView(),
    createSong_Latest_PerformanceView(),
    createMost_Recent_PerformanceView(),
    createSong_PerformancesView(),
    createSong_RecordingsView(),
    createSession_InfoView(),
  ];

  return sql.join('\n');
}