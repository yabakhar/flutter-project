import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/login.dart';

class Profile_page extends StatefulWidget {
  @override
  _Profile_pageState createState() => _Profile_pageState();
}

class Adder {
  static bool isLoggedIn = false;
}

class _Profile_pageState extends State<Profile_page> {
  @override
  Widget build(BuildContext context) {
    Widget _buildNameField(DocumentSnapshot userDocument) {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
              backgroundImage: NetworkImage(userDocument["picture"])),
              Text(userDocument["username"]),
              Text(userDocument["email"]),
            ],
          ));
    }

    Future<DocumentSnapshot> getUserInfo() async {
      var firebaseUser = await FirebaseAuth.instance.currentUser();
      return await Firestore.instance
          .collection("users")
          .document(firebaseUser.uid)
          .get();
    }

    Widget _profile_page() {
      return FutureBuilder(
          future: getUserInfo(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Text("Loading");
            }
            var userDocument = snapshot.data;
            return _buildNameField(userDocument);
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: <Widget>[
          RaisedButton(
              child: Text(
                'log Out',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              color: Colors.blue,
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                setState(() {
                  Adder.isLoggedIn = false;
                });
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              }),
        ],
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _profile_page(),
        ],
      )),
    );
  }
}
