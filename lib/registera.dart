import 'package:firebase/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Registera extends StatefulWidget {
  @override
  _RegisteraState createState() => _RegisteraState();
}

class _RegisteraState extends State<Registera> {
  String _username;
  String _email;
  String _phoneNumber;
  String _password;
  String _cpassword;
  String _picture = null;
  String _address = null;
  bool _obscureText = true;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  void _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget _buildNameField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: TextFormField(
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.person),
            labelText: 'UserName',
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue))),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Name is required';
          }
        },
        onSaved: (String value) {
          _username = value;
        },
      ),
    );
  }

  Widget _buildemailField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue))),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Email is required';
          }
          if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
            return 'Email not valide';
          }
          return null;
        },
        onSaved: (String value) {
          _email = value;
        },
      ),
    );
  }
//N
  Widget _buildphoneNumberField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: TextFormField(
        decoration: InputDecoration(
            labelText: 'Phone',
            prefixIcon: Icon(Icons.phone),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue))),
        keyboardType: TextInputType.phone,
        validator: (String value) {
          if (value.isEmpty) {
            return 'phone number is required';
          }
        },
        onSaved: (String value) {
          _phoneNumber = value;
        },
      ),
    );
  }

  Widget _buildpasswordField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: Icon(Icons.lock),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: _togglePasswordStatus,
            color: Colors.grey,
          ),
        ),
        obscureText: _obscureText,
        validator: (String value) {
          if (value.isEmpty) {
            return 'password is required';
          }
          if (!RegExp(r"^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$")
              .hasMatch(value)) {
            return 'No more than 8 characters.';
          }
          return null;
        },
        onSaved: (String value) {
          _password = value;
        },
      ),
    );
  }

  Widget _buildCpasswordField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Confirmed Password',
          prefixIcon: Icon(Icons.lock),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: _togglePasswordStatus,
            color: Colors.grey,
          ),
        ),
        obscureText: _obscureText,
        validator: (String value) {
          if (value.isEmpty) {
            return 'confirmed password is required';
          }
          _formkey.currentState.save();
          if (_password != value) {
            return 'password not valide';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildbutton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: RaisedButton(
        color: Colors.blue,
        child: Text(
          'Register',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          if (_formkey.currentState.validate()) {
            var result = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                    email: _email, password: _password);
            if (result != null) {
              await Firestore.instance
                  .collection('users')
                  .document(result.uid)
                  .setData({
                'phone_number': _phoneNumber,
                'username': _username,
                'email': _email,
                'picture': _picture,
                'address': _address,
                'type-coach': null,
              });
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('register'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 80.0,
                  ),
                  CircleAvatar(
                    radius: 50,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: Divider(),
                  ),
                  _buildNameField(),
                  _buildemailField(),
                  _buildphoneNumberField(),
                  _buildpasswordField(),
                  _buildCpasswordField(),
                  Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0)),
                  _buildbutton(),
                  Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 100.0, horizontal: 16.0)),
                ],
              )),
        ),
      ),
    );
  }
}
