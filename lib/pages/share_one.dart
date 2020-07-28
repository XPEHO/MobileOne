import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/share_provider.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:MobileOne/widgets/widget_share_contact.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:MobileOne/utility/colors.dart';

Contact contactSelected;
String searchTermEmail;

class ShareOne extends StatefulWidget {
  ShareStateOneState createState() => ShareStateOneState();
}

class ShareStateOneState extends State<ShareOne> {
  var uuid = Uuid();
  var newUuid;
  final _myController = TextEditingController();
  var shareProvider = GetIt.I.get<ShareProvider>();
  String emailRegexp =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  Contact contact;
  List<Contact> contacts = [];
  List<Contact> contactsFilter;
  List<Contact> contactsWithoutEmails = [];
  List<Contact> contactsWithEmails = [];

  bool loader = false;
  bool isVisible = false;

  void initState() {
    super.initState();
    newUuid = uuid.v4();
    getContacts();
    contactsFilter = [];
    _myController.addListener(() {
      filterContact();
    });
  }

  getContacts() async {
    Iterable<Contact> _contacts = (await ContactsService.getContacts());
    for (int i = 0; i < _contacts.length; i++) {
      if (_contacts.elementAt(i).emails.isNotEmpty) {
        contactsWithEmails.add(_contacts.elementAt(i));
      } else {
        contactsWithoutEmails.add(_contacts.elementAt(i));
      }
    }

    setState(() {
      contacts = contactsWithEmails.toList();
      loader = true;
    });
  }

  filterContact() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (_myController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = _myController.text.toLowerCase();
        String contactName = contact.displayName.toLowerCase();
        return contactName.contains(searchTerm);
      });
      setState(() {
        contactsFilter = _contacts;
      });
    }
  }

  Widget build(BuildContext context) {
    ShareArguments _argsShare = ModalRoute.of(context).settings.arguments;
    bool isSearching = _myController.text.isNotEmpty;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          header(context),
          (_argsShare.isOnlyOneStep == false)
              ? headerSteps(context)
              : Container(height: MediaQuery.of(context).size.height * 0.1),
          searchContact(context),
          searchNewContact(context, _argsShare.previousList),
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Container(
              width: MediaQuery.of(context).size.width - 10,
              height: MediaQuery.of(context).size.height - 300,
              child: loader == false
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : buildListView(isSearching, _argsShare.previousList),
            ),
          )
        ],
      ),
    );
  }

  Padding header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  openSharePage();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 7),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  getString(context, "with_who"),
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding headerSteps(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 100, right: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CircleAvatar(
            child: Text(
              getString(context, "step_one"),
              style: TextStyle(
                color: WHITE,
                fontSize: 10,
              ),
            ),
            radius: 12,
            backgroundColor: BLUE,
          ),
          Expanded(
              child: Divider(
            color: Colors.black,
            height: 80,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          )),
          CircleAvatar(
            child: Text(
              getString(context, "step_two"),
              style: TextStyle(
                color: WHITE,
                fontSize: 10,
              ),
            ),
            radius: 12,
            backgroundColor: GREY,
          ),
        ],
      ),
    );
  }

  GestureDetector searchNewContact(BuildContext context, previousList) {
    return GestureDetector(
      onTap: () {
        searchTermEmail = _myController.text;
        if (RegExp(emailRegexp).hasMatch(searchTermEmail)) {
          if (previousList == null || uuid == null) {
            openShareTwoPage();
          } else {
            shareProvider.addSharedToDataBase(searchTermEmail, previousList);
            shareProvider.addGuestToDataBase(searchTermEmail, previousList);
            openSharePage();
          }
        }
      },
      child: Visibility(
        visible: isVisible,
        child: Container(
          margin: const EdgeInsets.all(10.0),
          color: Colors.amber[600],
          width: MediaQuery.of(context).size.width - 50,
          height: 20.0,
          child: Text("${_myController.text}"),
        ),
      ),
    );
  }

  Container searchContact(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 50,
      child: TextFormField(
        decoration: InputDecoration(
          hintText: getString(context, "share_email"),
          labelText: getString(context, 'search'),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: BLUE),
          ),
          suffixIcon: Icon(Icons.search),
        ),
        controller: _myController,
        onChanged: (string) {
          setState(
            () {
              if (contactsFilter.isEmpty) {
                isVisible = true;
              } else {
                isVisible = false;
              }
              contactsFilter = contacts
                  .where((conta) => (conta.displayName
                          .toLowerCase()
                          .contains(string.toLowerCase()) ||
                      conta.emails
                          .elementAt(0)
                          .value
                          .toLowerCase()
                          .contains(string.toLowerCase())))
                  .toList();
            },
          );
        },
      ),
    );
  }

  ListView buildListView(bool isSearching, Object previousList) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: isSearching == true ? contactsFilter.length : contacts.length,
      itemBuilder: (BuildContext ctxt, int index) {
        contact = isSearching == true ? contactsFilter[index] : contacts[index];
        return GestureDetector(
          onTap: () {
            if (isSearching == true) {
              contactSelected = contactsFilter[index];
            } else if (isSearching == false) {
              contactSelected = contacts[index];
            }
            if (previousList == null) {
              openShareTwoPage();
            } else {
              shareProvider.addSharedToDataBase(
                  contactSelected.emails.elementAt(0).value, previousList);
              shareProvider.addGuestToDataBase(
                  contactSelected.emails.elementAt(0).value, previousList);

              openSharePage();
            }
          },
          child: WidgetShareContact(contact.displayName, contact.avatar,
              contact.emails.elementAt(0).value),
        );
      },
    );
  }

  void openSharePage() {
    Navigator.popUntil(context, ModalRoute.withName('/mainpage'));
  }

  void openShareTwoPage() {
    Navigator.of(context).pushNamed('/shareTwo');
  }
}
