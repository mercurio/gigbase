import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
//import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
//import 'package:intl/intl.dart';
import 'package:gigbase/db/database.dart' as DB;
import 'package:gigbase/songs.dart';

class EditGigPage extends StatefulWidget {
  const EditGigPage({super.key, required this.gigId, required this.date, required this.venue, required this.tracks});
  final int gigId;
  final String date;
  final String venue;
  final int tracks;

  @override
  State<EditGigPage> createState() => _EditGigPageState();
}

class _PerfData {
  int track = 1;
  int id = 0;
  int song = 0;
  String title = '';
  String artist = '';
  String drumkit = '';
  String songkey = '';
  int stars = 0;
}

class _EditGigPageState extends State<EditGigPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  int _track = 1;
  int _tracks = 0;
  int _perf = -1;
  Map update = {};      // Updated info from song selection

  // Fill in the data, either from an update returned from
  // invoking the song selection page, or from the database
  //
  Future<_PerfData> _getData(int t) async {
    _PerfData d = _PerfData();

    d.track = t;

    if(update.isNotEmpty) {
      d.id = _perf;
      d.song = update['song'];
      d.title = update['title'];
      d.artist = update['artist'];
      d.drumkit = update['drumkit'];
      d.songkey = update['songkey'];
      d.stars = update['stars'];
    } else {
      List<Map> r1 = await DB.sql('SELECT * FROM performance WHERE serial=${d.track} AND gig=${widget.gigId}');
      if(r1.isEmpty) {
        d.title = 'Select Song';
        d.id = 0;
        d.song = 0;
        d.artist = '';
        d.drumkit = '';
        d.songkey = '';
        d.stars = 0;
      } else {
        _perf = d.id = r1[0]['id'];
        d.song = r1[0]['song'];
        d.drumkit = r1[0]['drumkit'];
        d.songkey = r1[0]['songkey'];
        d.stars = r1[0]['stars'];

        List<Map> r2 = await DB.sql('SELECT title, artist FROM song WHERE id=${d.song}');
        if(r2.isEmpty) throw Exception('Invalid song id ${d.song}');

        d.title = r2[0]['title'];
        d.artist = r2[0]['artist'];

        List<Map> r3 = await DB.sql('SELECT COUNT(p.gig) AS tracks FROM performance p WHERE p.gig = ${widget.gigId}');
        if(r3.isEmpty) throw Exception('Invalid gig id ${widget.gigId}');

        _tracks = r3[0]['tracks'];
      }
    }

    if(_formKey.currentState != null) {
      _formKey.currentState!.fields['artist']!.didChange(d.artist);
      _formKey.currentState!.fields['drumkit']!.didChange(d.drumkit);
      _formKey.currentState!.fields['songkey']!.didChange(d.songkey);
      _formKey.currentState!.fields['stars']!.didChange(d.stars);
    }
    return d;
  }

  // Called when the save button is pressed
  void doSave(data) async {
    if(_formKey.currentState!.saveAndValidate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saving performance'))
      );

      if(data.id > -1) {
        await DB.updatePerformanceFromForm(
          id: data.id,
          song: data.song,
          drumkit: _formKey.currentState!.fields['drumkit']!.value,
          songkey: _formKey.currentState!.fields['songkey']!.value,
          stars: _formKey.currentState!.fields['stars']!.value ?? 0
        );
      } else {
        _perf = await DB.newPerformance(DB.Performance(
          id: 0,
          serial: _track,
          gig: widget.gigId,
          song: data.song,
          drumkit: _formKey.currentState!.fields['drumkit']!.value,
          songkey: _formKey.currentState!.fields['songkey']!.value,
          stars: _formKey.currentState!.fields['stars']!.value ?? 0
          )
        );
      }

      setState(() => update = {});
    }
  }

  // Go to previous song
  void goPrev() async {
    setState(() {
      _track--;
      update = {};
    });
  }

  // Go to next song
  void goNext() async {
    setState(() {
      _track++;
      update = {};
    });
  }

  // Go to a new blank song
  void goBlank() async {
    setState(() {
      _track++;
      _perf = -1;
      update = {};
    });
  }

  // Build this widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('Editing: ${widget.date} @ ${widget.venue}',
          style: const TextStyle(
            color: Colors.white
          )
        ),
      ),
      body: FutureBuilder<_PerfData>(
        future: _getData(_track),
        builder: (BuildContext context, AsyncSnapshot<_PerfData> snapshot) {
          Widget kid; 
          if(snapshot.hasData) {
            kid = FormBuilder(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 50,
                          width: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle, 
                            color: (_track <= _tracks) ? Colors.lightGreen : Colors.redAccent,
                            borderRadius: const BorderRadius.all(Radius.circular(28.0)),
                          ),
                          alignment: Alignment.center,
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(text: '$_track', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), 
                                const TextSpan(text: ' of  ', style: TextStyle(fontStyle: FontStyle.italic)),
                                TextSpan(text: '$_tracks', style: const TextStyle(fontStyle: FontStyle.normal)),
                              ]
                            )
                          )
                        ),
                        Container(
                          height: 40,
                          width: 300,
                          margin: const EdgeInsets.only(left: 30),
                          child: MaterialButton(
                            color: Theme.of(context).colorScheme.primary,
                            textColor: Theme.of(context).colorScheme.onPrimary,
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (BuildContext context) => const SongsPage(title: 'Songs', selectOne: true)),
                                );

                                if(!mounted) return;

                                if(result != null) setState(() => update = result);
                              },
                              child: Text(snapshot.data!.title)
                          ),  
                        )   
                      ] 
                    ),
                    const SizedBox(height: 10),
                    FormBuilderTextField(
                      name: 'artist',
                      initialValue: snapshot.data!.artist, 
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Artist',
                        labelStyle: TextStyle(color: Colors.indigoAccent),
                        contentPadding: EdgeInsets.only(top: 10.0, bottom: 0.0),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FormBuilderTextField(
                      name: 'drumkit',
                      initialValue: snapshot.data!.drumkit, 
                      decoration: const InputDecoration(
                        labelText: 'Drum Kit',
                        labelStyle: TextStyle(color: Colors.indigoAccent),
                        contentPadding: EdgeInsets.only(top: 10.0, bottom: 0.0),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FormBuilderTextField(
                      name: 'songkey',
                      initialValue: snapshot.data!.songkey, 
                      decoration: const InputDecoration(
                        labelText: 'Song Key',
                        labelStyle: TextStyle(color: Colors.indigoAccent),
                        contentPadding: EdgeInsets.only(top: 10.0, bottom: 0.0),
                        border: InputBorder.none,
                      ),
                    ),
                    FormBuilderField<int>(
                      name: 'stars', 
                      builder: (FormFieldState field) {
                        return RatingBar.builder(
                          initialRating: snapshot.data!.stars * 1.0,
                          allowHalfRating: false,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber
                          ),
                          itemCount: 5,
                          itemSize: 50.0,
                          unratedColor: Colors.amber.withAlpha(50),
                          direction: Axis.horizontal,
                          onRatingUpdate: (value) => field.didChange(value.round())
                        );
                      }
                    ),
                    const SizedBox(height: 20),
                    MaterialButton(
                      color: Theme.of(context).colorScheme.primary,
                      textColor: Theme.of(context).colorScheme.onPrimary,
                      onPressed: () => doSave(snapshot.data!),
                      child: const Text('Save')
                    ),
                  ],
                ),
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
                    child: Text('Retrieving song...'),
                  )
                ]
              )
            );
          }

          return kid;
        }
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.fromLTRB(30.0,0,0,0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Visibility(
              visible: (_track > 1),
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: FloatingActionButton(
                tooltip: 'Previous',
                heroTag: null,
                onPressed: (_track <= 1) ? null : goPrev,
                child: const Icon(Icons.arrow_back),
              ),
            ),
            if(_track < _tracks) FloatingActionButton(
              tooltip: 'Next',
              heroTag: null,
              onPressed: goNext,
              child: const Icon(Icons.arrow_forward),
            )
            else FloatingActionButton(
              tooltip: 'Add performance',
              heroTag: null,
              onPressed: goBlank,
              child: const Icon(Icons.add),
            ),
          ]
        )
      )
    );
  }
}