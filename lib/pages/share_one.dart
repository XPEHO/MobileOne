import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/share_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/share_service.dart';
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
  var _analytics = GetIt.I.get<AnalyticsService>();
  var uuid = Uuid();
  var newUuid;
  final _myController = TextEditingController();
  var shareProvider = GetIt.I.get<ShareProvider>();
  var shareService = GetIt.I.get<ShareService>();
  var _colorsApp = GetIt.I.get<ColorService>();
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
    _analytics.setCurrentPage("isOnShareOnePage");
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
    setState(() {
      contactsFilter =
          shareService.filterContacts(contacts, _myController.text);
    });
  }

  Widget build(BuildContext context) {
    ShareArguments _argsShare = ModalRoute.of(context).settings.arguments;
    bool isSearching = _myController.text.isNotEmpty;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: _colorsApp.colorTheme,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            header(context),
            (_argsShare.isOnlyOneStep == false)
                ? headerSteps(context)
                : Container(height: MediaQuery.of(context).size.height * 0.1),
            searchContact(context),
            searchNewContact(context, _argsShare.previousList),
            loader == false
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.64,
                    child: buildListView(isSearching, _argsShare.previousList)),
          ],
        ),
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
                icon: Icon(Icons.arrow_back, color: WHITE),
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
                    color: WHITE,
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
            backgroundColor: _colorsApp.buttonColor,
          ),
          Expanded(
              child: Divider(
            color: WHITE,
            height: 80,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          )),
          CircleAvatar(
            child: Text(
              getString(context, "step_two"),
              style: TextStyle(
                color: BLACK,
                fontSize: 10,
              ),
            ),
            radius: 12,
            backgroundColor: WHITE,
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
            shareList(searchTermEmail, previousList);
            openSharePage();
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Visibility(
          visible: isVisible,
          child: (_myController.text.length > 2)
              ? WidgetShareContact(
                  name: _myController.text, email: _myController.text)
              : Container(),
        ),
      ),
    );
  }

  Container searchContact(BuildContext context) {
    return Container(
      color: WHITE,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: TextFormField(
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: getString(context, "share_email"),
            suffixIcon: Icon(
              Icons.search,
              color: BLACK,
            ),
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
              shareList(
                  contactSelected.emails.elementAt(0).value, previousList);
              openSharePage();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: WidgetShareContact(
                name: contact.displayName,
                avatar: contact.avatar,
                email: contact.emails.elementAt(0).value),
          ),
        );
      },
    );
  }

  Future<void> shareList(String email, String listUuid) async {
    shareProvider.shareAList(email, listUuid, context);
  }

  void openSharePage() {
    Navigator.popUntil(context, ModalRoute.withName('/mainPage'));
  }

  void openShareTwoPage() {
    Navigator.of(context).pushNamed('/shareTwo');
  }
}
