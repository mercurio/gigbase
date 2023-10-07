import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gigbase/db/database.dart' as DB;

class AddSongPage extends StatefulWidget {
  const AddSongPage({super.key, required this.title});
  final String title;

  @override
  State<AddSongPage> createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage> {
  final _formKey = GlobalKey<FormBuilderState>();

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
      body: FormBuilder(
        key: _formKey,
        child: Container(
          margin: const EdgeInsets.only(left: 40, right: 40),
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'title',
                initialValue: '',
                decoration: const InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.indigoAccent),
                  contentPadding: EdgeInsets.only(top: 10.0, bottom: 0.0),
                  border: InputBorder.none,
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 10),
              FormBuilderTextField(
                name: 'artist',
                initialValue: '',
                decoration: const InputDecoration(
                  labelText: 'Artist',
                  labelStyle: TextStyle(color: Colors.indigoAccent),
                  contentPadding: EdgeInsets.only(top: 10.0, bottom: 0.0),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 10),
              FormBuilderTextField(
                name: 'prehistory',
                initialValue: '0',
                decoration: const InputDecoration(
                  labelText: 'Prehistory',
                  labelStyle: TextStyle(color: Colors.indigoAccent),
                  contentPadding: EdgeInsets.only(top: 10.0, bottom: 0.0),
                  border: InputBorder.none,
                ),
                validator: FormBuilderValidators.integer()
              ),
              const SizedBox(height: 20),
              MaterialButton(
                color: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.onPrimary,
                onPressed: () async {
                  if(_formKey.currentState!.saveAndValidate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Adding new song'),
                        showCloseIcon: true,
                      )
                    );

                    await DB.newSong(DB.Song(
                      id: 0,    // this will be removed, doesn't matter what it is now
                      title: _formKey.currentState!.value['title'],
                      artist: _formKey.currentState!.value['artist'],
                      prehistory: int.parse(_formKey.currentState!.value['prehistory']),
                    ));

                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Save')
              ),
            ],
          ),
        )
      )
    );
  }
}