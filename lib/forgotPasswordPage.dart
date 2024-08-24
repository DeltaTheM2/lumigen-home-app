import 'package:flutter/material.dart';
import 'package:lumigen/firebase/authentication.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthenticationHelper _authHelper = AuthenticationHelper();
  bool _isLoading = false;

  void _resetPassword() async {
    setState(() {
      _isLoading = true;
    });
    String? error = await _authHelper.resetPassword(_emailController.text);
    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent to your email')),
      );
      Navigator.pop(context); // Go back to the login screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
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
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resetPassword,
                  child: Text('Reset Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
