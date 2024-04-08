import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_job_portal/theme/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class LoginRegisterPage extends StatefulWidget {
  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool _isLoginForm = true;

  // Form kontrolcüsü
  final _formKey = GlobalKey<FormState>();

  // Text alanı kontrolcüleri
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _login() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text)
          .then((value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (num) {
            return AlertDialog(
              title: Text(e.code),
            );
          });
    }
  }

  void _register() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      )
          .then((value) {
        showDialog(
            context: context,
            builder: (num) {
              return AlertDialog(
                title: Text("Register is Succesfull"),
              );
            });
      });
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (num) {
            return AlertDialog(
              title: Text(e.code),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('lib/images/back.png'),
          fit: BoxFit.cover,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Welcome to Jobify",
              style: TextStyle(color: Colors.white, fontSize: 40),
            ),
            Text(
              "Jobs and More",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontStyle: FontStyle.italic),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(45, 90, 104, 160),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _isLoginForm ? 'Login' : 'Register',
                          style:
                              TextStyle(fontSize: 30, color: KColors.lightGrey),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          width: 400,
                          height: 100,
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              labelStyle: TextStyle(
                                  color: Colors.black38, fontSize: 20),
                              labelText: 'Email',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          width: 400,
                          height: 100,
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              labelStyle: TextStyle(
                                  color: Colors.black38, fontSize: 20),
                              labelText: 'Password',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _isLoginForm ? _login() : _register();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xff3E61ED),
                          ),
                          child: Text(_isLoginForm ? 'Login' : 'Register'),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            //backgroundColor: Color(0xff3E61ED),
                          ),
                          onPressed: () {
                            setState(() {
                              _isLoginForm = !_isLoginForm;
                            });
                          },
                          child: Text(
                            _isLoginForm
                                ? 'Don\'t have an account? Register here'
                                : 'Already have an account? Login here',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
