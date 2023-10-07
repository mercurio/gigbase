import 'package:flutter/material.dart';
import 'package:gigbase/db/database.dart' as DB;
import 'package:scrollable_list_tab_scroller/scrollable_list_tab_scroller.dart';

import 'package:gigbase/add_gig.dart';
import 'package:gigbase/edit_gig.dart';

class GigsPage extends StatefulWidget {
  const GigsPage({super.key, required this.title});
  final String title;

  @override
  State<GigsPage> createState() => _GigsPageState();
}

// Fetch the data from the database and generate the data structure
// needed below (a map of categories to arrays of Gigs_Reverses).
//
Future<Map<String, List<DB.Gigs_Reverse>>> getData() async {
  final List<DB.Gigs_Reverse> gigs = await DB.gigs_reverse();

  var data = <String, List<DB.Gigs_Reverse>>{};
  var cat = '';
  var yr = '';

  for(final gig in gigs) {
    yr = gig.date.substring(0,4);

    if(yr != cat) {
      cat = yr;
      data[cat] = [];
    }

    data[cat]!.add(gig);
  }

  return data;
}

class _GigsPageState extends State<GigsPage> {
  Future<Map<String, List<DB.Gigs_Reverse>>> _data = getData();
  int _selection = -1;
  String _selectionDate = '';
  String _selectionVenue = '';
  int _selectionTracks = -1;

  // Open a gig for editing
  void openGig() async {
    await Navigator.push(context, MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return EditGigPage(gigId: _selection, date: _selectionDate, venue: _selectionVenue, tracks: _selectionTracks);
      }
    ));

    setState(() {_data = getData(); });
  }

  // Open the add gig page
  void addGig() async {
    final result = await Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) {
        return const AddGigPage(title: 'New Gig');
      }
    ));

    if(result != null) setState(() {_data = getData(); });
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
      ),
      body: FutureBuilder<Map<String, List<DB.Gigs_Reverse>>>(
        future: _data,
        builder: (BuildContext context, AsyncSnapshot<Map<String, List<DB.Gigs_Reverse>>> snapshot) {
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
                      (index, gig) => MapEntry(
                        index,
                        ListTile(
                          selected: gig.id == _selection,
                          onTap: () {
                            setState(() {
                              if(gig.id == _selection) {  // deselect
                                _selection = -1;
                              } else {
                                _selection = gig.id;
                                _selectionDate = gig.date;
                                _selectionVenue = gig.venue;
                                _selectionTracks = gig.tracks;
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
                            child: Text(gig.tracks.toString(), style: const TextStyle(color: Colors.white, fontSize: 14)),
                            ),
                          title: Text(gig.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          subtitle: Text(gig.venue, style: const TextStyle(fontStyle: FontStyle.italic)),
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
          if(_selection != -1) Container(
            margin: const EdgeInsets.all(10),
            child: FloatingActionButton(
              tooltip: 'Delete gig',
              heroTag: null,
              onPressed: () => _confirmDelete(context),
              child: const Icon(Icons.delete),
            ),
          ),
          if(_selection != -1) Container(
            margin: const EdgeInsets.all(10),
            child: FloatingActionButton(
              tooltip: 'Open gig',
              heroTag: null,
              onPressed: openGig,
              child: const Icon(Icons.open_in_new),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: FloatingActionButton(
              tooltip: 'Add gig',
              heroTag: null,
              onPressed: addGig,
              child: const Icon(Icons.add),
            ),
          ),
        ]
      ),
    );
  }

  // Show alert dialog for deleting a gig and delete it if confirmed
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
        DB.deleteGig(_selection);
        setState(() {
          _selection = -1;
          _data = getData();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted gig $_selectionDate'))
        );
      }
    );

    AlertDialog alert = AlertDialog(
      title: const Text('Confirm deletion'),
      content: Text("Delete gig $_selectionDate containing $_selectionTracks tracks? (can't be undone)"),
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