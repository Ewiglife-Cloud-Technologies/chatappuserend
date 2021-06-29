import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashscreen/Model/Button.dart';
import 'package:flashscreen/Utilis/constants.dart';
import 'package:flashscreen/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  bool isLogin = true;

  // LoginScreen({this.isLogin});
  static const String id = 'LoginScreen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final auth = FirebaseAuth.instance;
  bool spinnerShow = false;
  String name;
  String email;
  String phoneNumber;
  // create new collection in User with the name of new clinet
  creatUser(String name, String time) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('User').doc(name);

    // set th name of the client in field
    Map<String, dynamic> users = {
      "Name": name,
      "Email": email,
      "PhoneNumber": phoneNumber,
      "time": time,
    };
    documentReference.set(users).whenComplete(
          () => print('$users  New User'),
        );
  }

  DateTime now = DateTime.now();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  String time;
  String validateName(String value) {
    if (value.length < 3)
      return 'Name must be more than 2 charater';
    else
      return null;
  }

  String validateMobile(String value) {
// Indian Mobile number are of 10 digit only
    if (value.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    final snackBar = SnackBar(content: Text('Yay! A SnackBar!'));
    return Scaffold(
      backgroundColor: Colors.green,
      body: ModalProgressHUD(
        inAsyncCall: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 48.0,
              ),
              TextFormField(
                style: TextStyle(
                  color: Colors.pinkAccent,
                ),
                onChanged: (value) {
                  name = value;

                  //Do something with the user input.
                },
                decoration:
                    ktextFormField.copyWith(hintText: 'Enter Your Name'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextFormField(
                // validator: (value) {
                //   if (value.isEmpty ||
                //       !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                //           .hasMatch(value)) {
                //     return 'Enter a valid email!';
                //   }
                //   return null;
                // },
                style: TextStyle(
                  color: Colors.pinkAccent,
                ),
                onChanged: (value) {
                  email = value;

                  //Do something with the user input.
                },
                decoration: ktextFormField.copyWith(
                  hintText: 'Enter Your Email',
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextFormField(
                // validator: (value) {
                //   if (value.isEmpty ||
                //       !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                //           .hasMatch(value)) {
                //     return 'Enter a valid email!';
                //   }
                //   return null;
                // },
                style: TextStyle(
                  color: Colors.pinkAccent,
                ),
                onChanged: (value) {
                  phoneNumber = value;

                  //Do something with the user input.
                },
                decoration: ktextFormField.copyWith(
                    hintText: 'Enter Your Phone Number'),
              ),
              SizedBox(
                height: 8.0,
              ),
              SizedBox(
                height: 24.0,
              ),
              Button(
                text: 'Login',
                onPressd: () async {
                  setState(() {
                    spinnerShow = true;
                    time = dateFormat.format(DateTime.now());
                  });

                  if (name != null && email != null && phoneNumber != null) {
                    try {
                      final user = await auth.signInAnonymously();

                      print('uid=' + auth.currentUser.uid);

                      if (user != null) {
                        widget.isLogin = false;
                        creatUser(name, time);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              name,
                            ),
                          ),
                        );
                      }
                      setState(() {
                        spinnerShow = false;
                        // widget.isLogin = false;
                      });
                    } catch (e) {
                      print(e);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
