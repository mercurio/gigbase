import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gigbase/db/database.dart' as DB;
import 'package:intl/intl.dart';

class AddGigPage extends StatefulWidget {
  const AddGigPage({super.key, required this.title});
  final String title;

  @override
  State<AddGigPage> createState() => _AddGigPageState();
}

class _AddGigPageState extends State<AddGigPage> {
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
              FormBuilderDateTimePicker(
                name: 'date',
                format: DateFormat('yyyy-MM-dd'),
                inputType: InputType.date,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  labelStyle: TextStyle(color: Colors.indigoAccent),
                  contentPadding: EdgeInsets.only(top: 10.0, bottom: 0.0),
                  border: InputBorder.none,
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 10),
              FormBuilderTextField(
                name: 'venue',
                initialValue: 'Leadbone Studios',
                decoration: const InputDecoration(
                  labelText: 'Venue',
                  labelStyle: TextStyle(color: Colors.indigoAccent),
                  contentPadding: EdgeInsets.only(top: 10.0, bottom: 0.0),
                  border: InputBorder.none,
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 10),
              FormBuilderSwitch(
                name: 'recorded', 
                initialValue: true,
                title: const Text('Recorded?', style: TextStyle(color: Colors.indigoAccent))
              ),
              const SizedBox(height: 20),
              MaterialButton(
                color: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.onPrimary,
                onPressed: () async {
                  if(_formKey.currentState!.saveAndValidate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Adding new gig'))
                    );

                    var si = (await DB.session_info())[0];
                    var d = _formKey.currentState!.value['date'];
                    var df = DateFormat('yyyy-MM-dd');
                    var ds = df.format(d);

                    await DB.newGig(DB.Gig(
                      id: 0,    // this will be removed, doesn't matter what it is now
                      venue: _formKey.currentState!.value['venue'],
                      date: ds,
                      recorded: _formKey.currentState!.value['recorded'] ? 1 : 0,
                      band: si.bandid
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