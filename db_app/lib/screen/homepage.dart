import 'package:db_app/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/contact.dart';

class HomePg extends StatefulWidget {
  @override
  _HomePgState createState() => _HomePgState();
}

class _HomePgState extends State<HomePg> {
  final List<Color> colors = <Color>[Colors.red, Colors.blue, Colors.amber];
  Contact _contact = Contact();
  List<Contact> _contactlst = [];
  DatabaseHelper _dbhelper;
  List<bool> _selected = List.generate(20, (i) => false);
  final _ctrlName = TextEditingController();
  final _ctrlNumber = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      _dbhelper = DatabaseHelper.instance;
    });
    _refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Database Demo App")),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Column(
                children: <Widget>[
                  _form(),
                  _list(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _form() => Container(
        color: Colors.red[50],
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
        child: Form(
          key: _formkey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _ctrlName,
                  decoration: InputDecoration(
                    helperText: "Enter your name in above field",
                    icon: Icon(Icons.people),
                    labelText: "Full Name",
                  ),
                  onSaved: (val) => setState(() => _contact.name = val),
                  validator: (val) =>
                      (val.length == 0 ? "This field is reuired" : null),
                ),
                TextFormField(
                  controller: _ctrlNumber,
                  decoration: InputDecoration(
                    icon: Icon(Icons.contact_phone),
                    helperText: "Enter the Number in above field",
                    labelText: "Contact Number",
                  ),
                  onSaved: (val) => setState(() => _contact.number = val),
                  validator: (val) => (((val.length < 10) || (val.length > 10))
                      ? "Phone Number Must Contain atleast 10 numbers"
                      : null),
                ),
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: () {
                      _onSubmit();
                    },
                    child: Text("Submit"),
                    color: Colors.blue[300],
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  _refreshList() async {
    List<Contact> x = await _dbhelper.fetchContact();
    setState(() {
      _contactlst = x;
    });
  }

  _onSubmit() async {
    var form = _formkey.currentState;
    if (form.validate()) {
      form.save();
      if (_contact.id == null)
        await _dbhelper.insertContact(_contact);
      else
        await _dbhelper.updateContact(_contact);
      _refreshList();
      _formReset();
    }
  }

  _formReset() {
    setState(() {
      _formkey.currentState.reset();
      _ctrlName.clear();
      _ctrlNumber.clear();
      _contact.id = null;
    });
  }

  _list() => Container(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Card(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                return Card(
                    child: ListTile(
                  onTap: () {
                    setState(() {
                      _contact = _contactlst[index];

                      _ctrlName.text = _contactlst[index].name;
                      _ctrlNumber.text = _contactlst[index].number;
                    });
                  },
                  trailing: IconButton(
                      icon: Icon(Icons.delete_sweep),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // return object of type Dialog
                            return AlertDialog(
                              title: new Text("Remove Contact"),
                              content:
                                  new Text("Are you sure you want to Delete"),
                              actions: <Widget>[
                                // usually buttons at the bottom of the dialog
                                new FlatButton(
                                  child: new Text("Ok"),
                                  onPressed: () async {
                                    await _dbhelper
                                        .deleteContact(_contactlst[index].id);
                                    Navigator.of(context).pop();
                                    _refreshList();
                                    _formReset();
                                  },
                                ),
                                new FlatButton(
                                  child: new Text("Close"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }),
                  leading: Icon(Icons.account_circle, size: 40.0),
                  title: Text(_contactlst[index].name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  subtitle: Text(_contactlst[index].number,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                ));
              },
              itemCount: _contactlst.length,
            ),
          ),
        ),
      );
}
