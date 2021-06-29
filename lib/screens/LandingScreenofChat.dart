import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashscreen/Model/Button.dart';
import 'package:flashscreen/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../Utilis/constants.dart';
import 'NewResponsive.dart';
import 'chat_screen.dart';

final _fireStore = FirebaseFirestore.instance;
User loggedInUser;

final _auth = FirebaseAuth.instance;

class ChatLandingScreen extends StatefulWidget {
  @override
  _ChatLandingScreenState createState() => _ChatLandingScreenState();
}

class _ChatLandingScreenState extends State<ChatLandingScreen> {
  final auth = FirebaseAuth.instance;
  bool spinnerShow = false;
  String name;
  String email;
  String phoneNumber;
  void initState() {
    super.initState();
    getCurrentUser();
  }

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

  void getCurrentUser() async {
    final user = await _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
      print(loggedInUser.uid);
    }
  }

  DateTime now = DateTime.now();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  bool isVisible = false;
  bool isLogin = false;
  bool isChat;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final snackBar = SnackBar(content: Text('Yay! A SnackBar!'));
    String time;
    final messageTextController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    String message;
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('User').doc(name);
    return Scaffold(
        floatingActionButton: NewResponsiveView(
          tab: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Visibility(
                visible: isVisible,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: isLogin
                    ? Container(
                        height: 500,
                        width: 400,
                        child: Scaffold(
                          appBar: AppBar(
                            actions: <Widget>[
                              IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    _auth.signOut();
                                    // Navigator.pop(context);
                                    setState(() {
                                      isLogin = false;
                                      isVisible = false;
                                    });
                                    //TODO :save user Status in FireBase And get in Admin App
                                    //Implement logout functionality
                                  }),
                            ],
                            title: Text(name),
                            backgroundColor: Colors.redAccent,
                          ),
                          body: SafeArea(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                MessagesStream(
                                  name: name,
                                ),
                                Container(
                                  decoration: kMessageContainerDecoration,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: TextField(
                                          style: TextStyle(color: Colors.black),
                                          controller: messageTextController,
                                          onChanged: (value) {
                                            message = value;
                                            //Do something with the user input.
                                          },
                                          decoration:
                                              kMessageTextFieldDecoration,
                                        ),
                                      ),
                                      FlatButton(
                                        onPressed: () {
                                          messageTextController.clear();
                                          setState(() {
                                            time = dateFormat
                                                .format(DateTime.now());
                                          });

                                          documentReference
                                              .collection('messages')
                                              .add({
                                            'text': message,
                                            'sender': name,
                                            'time': time,
                                          });
                                        },
                                        child: Text(
                                          'Send',
                                          style: kSendButtonTextStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 400,
                        height: 500,
                        child: Scaffold(
                          backgroundColor: Colors.blueGrey,
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
                                    controller: nameController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Enter a valid email!';
                                      }
                                      return null;
                                    },
                                    style: TextStyle(
                                      color: Colors.pinkAccent,
                                    ),
                                    onChanged: (value) {
                                      name = value;

                                      //Do something with the user input.
                                    },
                                    decoration: ktextFormField.copyWith(
                                        hintText: 'Enter Your Name'),
                                  ),
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  TextFormField(
                                    controller: nameController,
                                    validator: (value) {
                                      if (value.isEmpty ||
                                          !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                              .hasMatch(value)) {
                                        return 'Enter a valid email!';
                                      }
                                      return null;
                                    },
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
                                    validator: (value) {
                                      if (value.isEmpty ||
                                          !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                              .hasMatch(value)) {
                                        return 'Enter a valid email!';
                                      }
                                      return null;
                                    },
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
                                    text: 'Start chat',
                                    onPressd: () async {
                                      setState(() {
                                        spinnerShow = true;

                                        time =
                                            dateFormat.format(DateTime.now());
                                      });
                                      if (name != null &&
                                          phoneNumber != null &&
                                          email != null) {
                                        try {
                                          final user =
                                              await auth.signInAnonymously();

                                          print('uid=' + auth.currentUser.uid);

                                          if (user != null) {
                                            isLogin = true;
                                            creatUser(name, time);
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (_) => ChatScreen(
                                            //       name,
                                            //     ),
                                            //   ),
                                            // );

                                          }
                                          setState(() {
                                            spinnerShow = false;
                                            // widget.isLogin = false;
                                          });
                                        } catch (e) {
                                          print(e);
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                // mobile: ChatScreenMob(),
              ), // SizedBox(
              //   height: 20.0,
              // ),
              FloatingActionButton(
                child: Icon(Icons.chat),
                onPressed: () {
                  setState(() {
                    isVisible = !isVisible;
                    // isLogin = !isLogin;
                  });
                },
              ),
            ],
          ),
          mobile: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Visibility(
              //   visible: isVisible,
              //   // maintainSize: true,
              //   maintainAnimation: true,
              //   // maintainState: true,
              //   child: ChatScreenMob(),
              // ),
              // // SizedBox(
              // //   height: 20.0,
              // // ),
              FloatingActionButton(
                child: Icon(Icons.chat),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(),
                    ),
                  );
                  // setState(
                  //   () {
                  //     isVisible = !isVisible;
                  //   },
                  // );
                },
              ),
            ],
          ),
          desktop: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: isVisible,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: isLogin
                    // ? Container(child: Text('heelo'))
                    ? Container(
                        height: 400,
                        width: 300,
                        child: Scaffold(
                          appBar: AppBar(
                            actions: <Widget>[
                              IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    _auth.signOut();
                                    // Navigator.pop(context);
                                    setState(() {
                                      isLogin = false;
                                      isVisible = false;
                                    });
                                    // Navigator.
                                    //TODO :save user Status in FireBase And get in Admin App

                                    //Implement logout functionality
                                  }),
                            ],
                            title: Text(name),
                            backgroundColor: Colors.redAccent,
                          ),
                          body: SafeArea(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                MessagesStream(
                                  name: name,
                                ),
                                Container(
                                  decoration: kMessageContainerDecoration,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: TextField(
                                          style: TextStyle(color: Colors.black),
                                          controller: messageTextController,
                                          onChanged: (value) {
                                            message = value;
                                            //Do something with the user input.
                                          },
                                          decoration:
                                              kMessageTextFieldDecoration,
                                        ),
                                      ),
                                      FlatButton(
                                        onPressed: () {
                                          messageTextController.clear();
                                          setState(() {
                                            time = dateFormat
                                                .format(DateTime.now());
                                          });

                                          documentReference
                                              .collection('messages')
                                              .add({
                                            'text': message,
                                            'sender': name,
                                            'time': time,
                                          });
                                        },
                                        child: Text(
                                          'Send',
                                          style: kSendButtonTextStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 300,
                        height: 400,
                        child: Scaffold(
                          backgroundColor: Colors.blueGrey,
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
                                    controller: nameController,
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                    onChanged: (value) {
                                      name = value;

                                      //Do something with the user input.
                                    },
                                    decoration: ktextFormField.copyWith(
                                        hintText: 'Enter Your Name'),
                                  ),
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  TextField(
                                    style: TextStyle(
                                      color: Colors.black,
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
                                  TextField(
                                    style: TextStyle(
                                      color: Colors.black,
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

                                        time =
                                            dateFormat.format(DateTime.now());
                                      });
                                      if (name != null &&
                                          phoneNumber != null &&
                                          email != null) {
                                        try {
                                          final user =
                                              await auth.signInAnonymously();

                                          print('uid=' + auth.currentUser.uid);

                                          if (user != null) {
                                            isLogin = true;
                                            creatUser(name, time);
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (_) => ChatScreen(
                                            //       name,
                                            //     ),
                                            //   ),
                                            // );

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
                        ),
                      ),
              ),
              FloatingActionButton(
                child: Icon(Icons.chat),
                onPressed: () {
                  setState(() {
                    isVisible = !isVisible;
                    // isLogin = !isLogin;
                  });
                },
              ),
            ],
          ),
        ),
        body: (Container(
          child: Text('hello'),
        )));
  }
}
