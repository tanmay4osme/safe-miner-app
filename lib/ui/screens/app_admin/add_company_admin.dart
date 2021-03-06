import 'dart:async';

import 'package:android_minor/constants/app_constants.dart';
import 'package:android_minor/constants/db_constants.dart';
import 'package:android_minor/constants/route_constants.dart';
import 'package:android_minor/models/user.dart';
import 'package:android_minor/ui/widgets/loading.dart';
import 'package:android_minor/util/alert_dialog.dart';
import 'package:android_minor/util/auth.dart';
import 'package:android_minor/util/validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCompanyAdmin extends StatefulWidget {
  @override
  State createState() => _AddCompanyAdminState();
}

class _AddCompanyAdminState extends State<AddCompanyAdmin> {
  bool _autoValidate = false;
  bool _loadingVisible = false;
  String companyId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  //List<String> _currencises = ControllerService.LoadDataToLocalString();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController fullnameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController nationalIdController = new TextEditingController();
  TextEditingController phonenumberController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  Future _addData({User user, String password}) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _changeLoadingVisible();

        await Auth.signUp(user.email, password).then((uID) {
          user.userId = uID;
          Auth.addAdminSettingsDB(user);
        });
        AlertDiag.showAlertDialog(
            context,
            'Status',
            'Company Admin Successfully Added',
            RouteConstants.APP_ADMIN_VIEW_COMPANY_ADMINS);
      } catch (e) {
        print("Adding admin Error: $e");
        String exception = Auth.getExceptionText(e);
        Flushbar(
                title: "Adding employee Error",
                message: exception,
                duration: Duration(seconds: 5))
            .show(context);
      }
    } else {
      setState(() => _autoValidate = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    //define form fields;
    final header = Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(AppConstants.BACKGROUND_IMAGE),
            fit: BoxFit.cover),
        color: Colors.blue,
      ),
    );

    final fullNameField = TextFormField(
      autofocus: false,
      textCapitalization: TextCapitalization.words,
      controller: fullnameController,
      //validator: Validator.validateName,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.person,
            color: Colors.black,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Full Name',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final emailField = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: emailController,
      validator: Validator.validateEmail,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.email,
            color: Colors.black,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final phonenumberField = TextFormField(
      keyboardType: TextInputType.number,
      autofocus: false,
      controller: phonenumberController,
      //validator: Validator.validateNumber,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.phone,
            color: Colors.black,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Phonenumber',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final companyField = StreamBuilder<QuerySnapshot>(
        stream:
            Firestore.instance.collection(DBConstants.DB_COMPANY).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CupertinoActivityIndicator(),
            );

          return Container(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
                      child: Text(
                        "Company",
                      ),
                    )),
                new Expanded(
                  flex: 4,
                  child: DropdownButton(
                    value: companyId,
                    isDense: true,
                    onChanged: (valueSelectedByUser) {
                      _onShopDropItemSelected(valueSelectedByUser);
                    },
                    hint: Text('Choose company'),
                    items: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return DropdownMenuItem<String>(
                          value: document.data['id'],
                          child: Text(document.data['name']));
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        });

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: passwordController,
      validator: Validator.validatePassword,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.lock,
            color: Colors.black,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final submitButton = Expanded(
      child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Colors.blue,
          textColor: Colors.white,
          child: Text(
            'Save',
            textScaleFactor: 1.5,
          ),
          onPressed: () {
            setState(() {
              debugPrint("Save clicked");
              User user = new User();
              user.name = fullnameController.text;
              user.phonenumber = phonenumberController.text;
              user.email = emailController.text;
              user.role = AppConstants.USER_COMPANY_ADMIN;
              user.companyId = companyId;
              user.isEmployee = false;
              user.employeeNumb = null;
              _addData(
                user: user,
                password: passwordController.text,
              );
            });
          }),
    );

    final cancelButton = Expanded(
      child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Colors.red,
          textColor: Colors.white,
          child: Text(
            'Cancel',
            textScaleFactor: 1.5,
          ),
          onPressed: () {
            setState(() {
              debugPrint("Cancel button clicked");
              Navigator.pop(context);
            });
          }),
    );

    Form form = new Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  header,
                  SizedBox(height: 48.0),
                  fullNameField,
                  SizedBox(height: 24.0),
                  emailField,
                  SizedBox(height: 24.0),
                  phonenumberField,
                  SizedBox(height: 24.0),
                  companyField,
                  SizedBox(height: 24.0),
                  passwordField,
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        submitButton,
                        Container(
                          width: 5.0,
                        ), //for adding space between buttons
                        cancelButton
                      ],
                    ),
                  ),
                ],
              ),
            )));

    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: new AppBar(
            elevation: 0.1,
            backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
            title: Text('Add Company Admin'),
          ),
          body: LoadingScreen(child: form, inAsyncCall: _loadingVisible),
        ));
  }

  void _onShopDropItemSelected(String newValueSelected) {
    setState(() {
      this.companyId = newValueSelected;
    });
  }

  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }
}
