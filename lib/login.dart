import 'package:firebase/dashboard.dart';
import 'package:firebase/profile_page.dart' as log;
import 'package:firebase/registera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgetpassword.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert' as JSON;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void initState() {
    super.initState();
  }

  final _formkey = GlobalKey<FormState>();

  bool _obscureText = true;
  String _email;
  String _password;
  FacebookLogin _facebookLogin = FacebookLogin();
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  void _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
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

  Map userProfile;

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

  void _tokenfacebook() async {
    final FacebookLoginResult result = await FacebookLogin().logIn(['email']);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    if (result.status == FacebookLoginStatus.loggedIn) {
      FacebookAccessToken token = result.accessToken;
      AuthCredential credential =
          FacebookAuthProvider.getCredential(accessToken: token.token);
      final FirebaseUser user = await _auth.signInWithCredential(credential);
      final graphResponse = await http.get(
          'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token.token}');
      final profile = JSON.jsonDecode(graphResponse.body);
      setState(() {
        userProfile = profile;
        log.Adder.isLoggedIn = true;
      });
    // await Firestore.instance.collection('users').document(user.uid).setData({
    //   'phone_number': null,
    //   'username': userProfile["name"],
    //   'email': userProfile["email"],
    //   'picture': userProfile["picture"]["data"]["url"],
    //   'address': null,
    //   'type-coach': null,
    // });
    }
  }

  void _tokengoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseUser user = (await _auth.signInWithCredential(credential));
    setState(() => log.Adder.isLoggedIn = true);
    await Firestore.instance.collection('users').document(user.uid).setData({
      'phone_number': null,
      'username': googleUser.displayName,
      'email': googleUser.email,
      'picture': googleUser.photoUrl,
      'address': null,
      'type-coach': null,
    });
  }

  Widget _signingoogle() {
    return SignInButton(
      Buttons.Email,
      onPressed: () async {
        await _tokengoogle();
        // if (log.Adder.isLoggedIn)
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => DashboardScreen()));
      },
      mini: true,
    );
  }

  Widget _signinfacebook() {
    return SignInButton(
      Buttons.Facebook,
      onPressed: () async {
        await _tokenfacebook();
        // if (log.Adder.isLoggedIn)
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => DashboardScreen()));
      },
      mini: true,
    );
  }

  Widget _srow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _signinfacebook(),
        _signingoogle(),
      ],
    );
  }

  Widget _forgetpass() {
    return FlatButton(
      child: Text(
        "forget password?",
        style: TextStyle(color: Colors.blue),
      ),
      onPressed: () {
        setState(() {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Forgitpassword()));
        });
      },
    );
  }

  Widget _login() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: RaisedButton(
        color: Colors.blue,
        child: Text(
          'Login',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          _formkey.currentState.save();
          if (_formkey.currentState.validate()) {
            List<String> rr = await FirebaseAuth.instance
                .fetchSignInMethodsForEmail(email: _email);
            if (rr.length > 0) {
              var result = await FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                      email: _email, password: _password);
              if (result != null) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => DashboardScreen()));
              } else {
                return 'password not valide';
              }
            } else {
              print('email not found');
            }
          }
        },
      ),
    );
  }

  Widget _facebook_login() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: RaisedButton(
        color: Colors.blue,
        child: Text(
          'facebook',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {},
      ),
    );
  }

  Widget _register() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: RaisedButton(
        color: Colors.blue,
        child: Text(
          'Register New Account',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Registera()));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login To My Account'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Form(
                key: _formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _buildemailField(),
                    _buildpasswordField(),
                    _login(),
                    _forgetpass(),
                    _srow(),
                    _register(),
                  ],
                )),
          ),
        ));
  }
}
