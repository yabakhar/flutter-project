import 'package:firebase/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/search.dart';
import 'package:firebase/profile_page.dart';
import 'package:firebase/home.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
    int _currentindex = 0;
    final List<Widget> _children = [
      Profile_page(),
      Home(),
      Search(),
    ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentindex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabapped,
        currentIndex: _currentindex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person),title: Text("Profile")),
          BottomNavigationBarItem(icon: Icon(Icons.home),title: Text("Home")),
          BottomNavigationBarItem(icon: Icon(Icons.search),title: Text("Search")),
        ],
        ),
    );
  }
  void onTabapped (int index)
  {
    setState(() {
      _currentindex = index;
    });
  }
}
