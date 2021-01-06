import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase/login.dart';

class Forgitpassword extends StatefulWidget {
  @override
  _ForgetpasswordState createState() => _ForgetpasswordState();
}

class _ForgetpasswordState extends State<Forgitpassword> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String _email;

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
        },
        onSaved: (String value) {
          _email = value;
          print(_email);
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
          _formkey.currentState.save();
          if (_formkey.currentState.validate()) {
            List<String> rr = await FirebaseAuth.instance
                .fetchSignInMethodsForEmail(email: _email);
            print(_email);
            print(rr.length);
            if (rr.length > 0) {
              await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            } else {
              print('email not found.');
              return (null);
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
        title: Text('forget'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _buildemailField(),
                  _buildbutton(),
                ],
              )),
        ),
      ),
    );
  }
}
