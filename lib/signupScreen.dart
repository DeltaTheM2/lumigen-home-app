import 'package:flutter/material.dart';
import 'package:lumigen/dashboardScreen.dart';
import 'package:lumigen/firebase/authentication.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final AuthenticationHelper _authHelper = AuthenticationHelper();
  bool _isLoading = false;

  void _signUp() async {
    setState(() {
      _isLoading = true;
    });
    String? error = await _authHelper.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
    );
    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) =>  Dashboard()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
