class Contact {
  static const tblContact = 'contacts';
  static const tblId = 'id';
  static const tblName = 'name';
  static const tblNumber = 'number';
  int id;
  String name;
  String number;

  Contact.fromMap(Map<String, dynamic> map) {
    id = map[tblId];
    name = map[tblName];
    number = map[tblNumber];
  }

  Contact({this.id, this.name, this.number});
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{tblName: name, tblNumber: number};
    if (id != null) map[tblId] = id;
    return map;
  }
}
