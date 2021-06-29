import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashscreen/Utilis/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _fireStore = FirebaseFirestore.instance;
User loggedInUser;

final _auth = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {
  // bool isLogin;
  String name;

  ChatScreen(
    @required this.name,
    // this.isLogin,
  );
  static const String id = 'ChatScreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  String message;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
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

  @override
  Widget build(BuildContext context) {
    String time;
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('User').doc(widget.name);
    return Container(
      height: 400,
      width: 300,
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  _auth.signOut();
                  Navigator.pop(context);
                  // Navigator.
                  //TODO :save user Status in FireBase And get in Admin App

                  //Implement logout functionality
                }),
          ],
          title: Text(widget.name),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessagesStream(
                name: widget.name,
              ),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: messageTextController,
                        onChanged: (value) {
                          message = value;
                          //Do something with the user input.
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        messageTextController.clear();
                        setState(() {
                          time = dateFormat.format(DateTime.now());
                        });

                        documentReference.collection('messages').add({
                          'text': message,
                          'sender': widget.name,
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
    );
  }
}

class MessagesStream extends StatelessWidget {
  String name;

  MessagesStream({this.name});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore
          .collection('User')
          .doc(name)
          .collection("messages")
          .orderBy(
            "time",
            descending: false,
          )
          // .orderBy("time", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.docs.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.get('text');
          final messageSender = message.get('sender');
          final messageTime = message.get('time');

          final currentUser = name;

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
            time: messageTime,
          );

          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe, this.time});
  final String sender;
  final String text;
  final bool isMe;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              sender,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black45,
              ),
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30),
                  )
                : BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.pinkAccent,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.black45 : Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 10.0,
                color: Colors.black45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
