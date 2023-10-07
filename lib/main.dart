import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:gigbase/db/database.dart' as DB;
import 'package:gigbase/gigs.dart';
import 'package:gigbase/songs.dart';

void main() async {
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      break;

    default:
      break;
  }

  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();

  // Start the app
  runApp(const MyApp());
}

// Initialize the database, copying it from the assets the first 
// time
// 
// Ref: https://github.com/tekartik/sqflite/blob/master/sqflite/doc/opening_asset_db.md
//
Future<void> initDatabase() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, "gigbase.db");

  // Does it exist?
  var exists = await databaseExists(path);

  if(!exists) {
    debugPrint("Creating new database from asset");

    // Make sure the parent dir exists
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch(_) {}

    // Copy from asset
    ByteData data = await rootBundle.load(url.join("assets","gigbase.db"));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Write and flush the bytes written
    await File(path).writeAsBytes(bytes, flush: true);
  } else {
    debugPrint("Opening existing database");
  }
}

// Export the database to the download folder. Do nothing if not Android.
//
Future<String> exportDatabase() async {
  if(defaultTargetPlatform != TargetPlatform.android) return 'not android';

  var databasesPath = await getDatabasesPath();
  var dbPath = join(databasesPath, "gigbase.db");

  Directory docsDir = Directory('storage/emulated/0/Documents/');
  String docsPath = join('${docsDir.absolute.path}gigbase.sqlite');

  File b = File(dbPath);

  bool storage = await Permission.storage.request().isGranted;
  bool mediaLoc = await Permission.accessMediaLocation.request().isGranted;
  bool external = await Permission.manageExternalStorage.request().isGranted;

  if(storage /*&& mediaLoc && external */) {
    await b.copy(docsPath);
    return 'ok';
  } else {
    return 'storage: $storage mediaLoc: $mediaLoc external: $external';
  }
}

// Import the database from the download folder. Do nothing if not Android.
//
Future<String> importDatabase() async {
  if(defaultTargetPlatform != TargetPlatform.android) return 'not android';

  var databasesPath = await getDatabasesPath();
  var dbPath = join(databasesPath, "gigbase.db");

  Directory docsDir = Directory('storage/emlulated/0/Documents/');
  String docsPath = join('${docsDir.absolute.path}gigbase.sqlite');

  File b = File(docsPath);

  bool storage = await Permission.storage.request().isGranted;
  bool mediaLoc = await Permission.accessMediaLocation.request().isGranted;
  bool external = await Permission.manageExternalStorage.request().isGranted;

  if(storage /*&& mediaLoc && external */) {
    await b.copy(dbPath);
    return 'ok';
  } else {
    return 'storage: $storage mediaLoc: $mediaLoc external: $external';
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GigBase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'GigBase'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _HomeData {
  String stageName = '';
  String bandName = '';
  int nGigs = 0;
  int nSongs = 0;
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<_HomeData> _getData() async {
    _HomeData d = _HomeData();

    // There should be only one session
    List<DB.Session_Info> s = await DB.session_info();
    if(s.isEmpty) throw Exception('Unable to get session info');

    d.stageName = s[0].stageName;
    d.bandName = s[0].band;

    List<Map> r1 = await DB.sql('SELECT count(*) AS count FROM gig');
    if(s.isEmpty) throw Exception('Unable to count gigs');

    d.nGigs = r1[0]['count'];

    List<Map> r2 = await DB.sql('SELECT count(*) AS count FROM song');
    if(s.isEmpty) throw Exception('Unable to count songs');

    d.nSongs = r2[0]['count'];

    return d;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white
          )
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.album_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 30,
              semanticLabel: 'Gigs page',
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return const GigsPage(title: 'Gigs');
                }
              ));
            }
          ),
          IconButton(
            icon: Icon(
              Icons.music_note,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 30,
              semanticLabel: 'Songs page',
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return const SongsPage(title: 'Songs', selectOne: false);
                }
              ));
            }
          ),
        ],
      ),
      body: FutureBuilder<_HomeData>(
        future: _getData(),
        builder: (BuildContext context, AsyncSnapshot<_HomeData> snapshot) {
          Widget kid;
          if(snapshot.hasData) {
            kid = FormBuilder(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.only(left: 40, right: 40, top: 10),
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: 'band',
                      initialValue: snapshot.data!.bandName,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Band',
                        labelStyle: TextStyle(color: Colors.indigoAccent),
                        contentPadding: EdgeInsets.only(top: 10.0, bottom: 0.0),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FormBuilderTextField(
                      name: 'user',
                      initialValue: snapshot.data!.stageName,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'User',
                        labelStyle: TextStyle(color: Colors.indigoAccent),
                        contentPadding: EdgeInsets.only(top: 10.0, bottom: 0.0),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Container(
                          height: 50,
                          width: 90,
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.lightGreen,
                            borderRadius: BorderRadius.all(Radius.circular(28.0)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${snapshot.data!.nGigs}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)
                          ), 
                        ),
                        Text(
                          '   Gigs in database',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ]
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          height: 50,
                          width: 90,
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.lightGreen,
                            borderRadius: BorderRadius.all(Radius.circular(28.0)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${snapshot.data!.nSongs}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)
                          ), 
                        ),
                        Text(
                          '   Songs in database',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ]
                    ),
                    const SizedBox(height: 80),
                    MaterialButton(
                      color: Theme.of(context).colorScheme.primary,
                      textColor: Theme.of(context).colorScheme.onPrimary,
                      onPressed: () async {
                        String ans = await exportDatabase();
                        if(ans == 'ok') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Database exported to documents folder'))
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Unable to export database: $ans'))
                          );
                        }
                      },
                      child: const Text('Export database')
                    ),
                    const SizedBox(height: 20),
                    MaterialButton(
                      color: Theme.of(context).colorScheme.primary,
                      textColor: Theme.of(context).colorScheme.onPrimary,
                      onPressed: () async {
                        String ans = await importDatabase();
                        if(ans == 'ok') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Database imported from documents folder'))
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Unable to import database: $ans'))
                          );
                        }
                      },
                      child: const Text('Import database')
                    ),
                  ],
                )
              )
            );
          } else if(snapshot.hasError) {
            kid = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}')
                  )
                ]
              )
            );
          } else {  // pending
            kid = const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Retrieving session...'),
                  )
                ]
              )
            );
          }

          return kid;
        }
      )
    );
  }
}
