import 'package:flutter/material.dart';
import 'package:gigbase/db/database.dart' as DB;
import 'package:scrollable_list_tab_scroller/scrollable_list_tab_scroller.dart';

import 'package:gigbase/add_song.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key, required this.title, required this.selectOne});
  final String title;
  final bool selectOne;


  @override
  State<SongsPage> createState() => _SongsPageState();
}

// Fetch the data from the database and generate the data structure
// needed below (a map of categories to arrays of Most_Recent_Performances).
//
Future<Map<String, List<DB.Most_Recent_Performance>>> getData() async {
  final List<DB.Most_Recent_Performance> mrps = await DB.most_recent_performance();

  const digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  var data = <String, List<DB.Most_Recent_Performance>>{};
  var cat = '';
  var c = '';

  for(final mrp in mrps) {
    c = mrp.title[0];
    if(digits.contains(c)) c = '#';

    if(c != cat) {
      cat = c;
      data[cat] = [];
    }

    data[cat]!.add(mrp);
  }

  return data;
}

class _SongsPageState extends State<SongsPage> {
  Future<Map<String, List<DB.Most_Recent_Performance>>> _data = getData();
  int _selection = -1;
  String _selectionTitle = '';
  int _selectionRecordings = -1;
  Map result = {};

  // A song has been selected, return the song id
  void _selectSong() {
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          style: const TextStyle(
            //color: Theme.of(context).colorScheme.onPrimary,
            color: Colors.white
          )
        ),
      ),
      body: FutureBuilder<Map<String, List<DB.Most_Recent_Performance>>>(
        future: _data,
        builder: (BuildContext context, AsyncSnapshot<Map<String, List<DB.Most_Recent_Performance>>> snapshot) {
          Widget kid;
          if(snapshot.hasData) {
            kid = ScrollableListTabScroller(
              itemCount: snapshot.data?.length ?? 0,
              animationDuration: const Duration(milliseconds: 5),
              tabBuilder: (BuildContext context, int index, bool active) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  snapshot.data?.keys.elementAt(index) ?? '',
                  style: !active
                    ? null
                    : const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              itemBuilder: (BuildContext context, int index) => Column(
                children: [
                  Text(
                    snapshot.data?.keys.elementAt(index) ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  ...snapshot.data!.values
                    .elementAt(index)
                    .asMap()
                    .map(
                      (index, mrp) => MapEntry(
                        index,
                        ListTile(
                          selected: mrp.song_id == _selection,
                          onTap: () {
                            setState(() {
                              if(mrp.song_id == _selection) { // deselect
                                _selection = -1;
                              } else {
                                _selection = mrp.song_id;
                                _selectionTitle = mrp.title;
                                _selectionRecordings = mrp.recordings;

                                result['song'] = mrp.song_id;
                                result['title'] = mrp.title;
                                result['artist'] = mrp.artist;
                                result['drumkit'] = mrp.drumkit;
                                result['songkey'] = mrp.songkey;
                                result['stars'] = mrp.stars;
                              }
                            });
                          },
                          textColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                            return (states.contains(MaterialState.selected)) ? Colors.green : Colors.black;
                          }),
                          leading: Container(
                            height: 30,
                            width: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.rectangle, 
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.all(Radius.circular(18.0)),
                            ),
                            alignment: Alignment.center,
                            child: Text(mrp.recordings.toString(), style: const TextStyle(color: Colors.white, fontSize: 14)),
                            ),
                          title: Text(mrp.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          subtitle: Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(text: '${mrp.date}     ', style: const TextStyle(fontStyle: FontStyle.italic)),
                                TextSpan(text: mrp.drumkit, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .values
                ]
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
                    child: Text('Searching database...'),
                  )
                ]
              )
            );
          }

          return kid;
        }
      ),
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        children: <Widget>[
          if(_selection != -1 && _selectionRecordings == 0) Container(
            margin: const EdgeInsets.all(10),
            child: FloatingActionButton(
              tooltip: 'Delete song',
              heroTag: null,
              onPressed: () {
                _confirmDelete(context);
              },
              child: const Icon(Icons.delete),
            ),
          ),
          if(widget.selectOne && _selection != -1) Container(
            margin: const EdgeInsets.all(10),
            child: FloatingActionButton(
              heroTag: null,
              onPressed: _selectSong,
              tooltip: 'Select song',
              child: const Icon(Icons.check),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: FloatingActionButton(
              heroTag: null,
              tooltip: 'Add song',
              onPressed: () async {
                final result = await Navigator.push(context, MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const AddSongPage(title: 'New Song');
                  }
                ));

                if(result != null) setState(() {_data = getData(); });
              },
              child: const Icon(Icons.add),
            ),
          ),
        ]
      ),
    );
  }

  // Show alert dialog for deleting a song and delete it if confirmed
  //
  void _confirmDelete(BuildContext context) {
    Widget cancelBtn = MaterialButton(
      child: const Text('Cancel'),
      onPressed: () {
        Navigator.pop(context, 'Cancel');
      }
    );

    Widget okBtn = MaterialButton(
      child: const Text('Delete'),
      onPressed: () {
        Navigator.pop(context, 'OK');
        DB.deleteSong(_selection);
        setState(() {
          _selection = -1;
          _selectionRecordings = -1;
          _data = getData();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted song $_selectionTitle'))
        );
      }
    );

    AlertDialog alert = AlertDialog(
      title: const Text('Confirm deletion'),
      content: Text("Delete song $_selectionTitle (can't be undone, but it's safe because no performances reference it)"),
      actions: [cancelBtn, okBtn]
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      }
    );
  }
}