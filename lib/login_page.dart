import 'package:activity_8/auth_service.dart';
import 'package:activity_8/home_page.dart';
import 'package:activity_8/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginPage extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    final TextEditingController emailCtrl = TextEditingController();
    final TextEditingController passwordCtrl = TextEditingController();
  
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  label: Text('Email'),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12,),
              TextField(
                controller: passwordCtrl,
                decoration: InputDecoration(
                  label: Text('Password'),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12,),
              ElevatedButton(
                child: loading ? CircularProgressIndicator(color: Colors.white,) : Text('Login with email'),
                onPressed: () async {
                  setState(() => loading = true);
                  final user = await auth.signInWithEmail(emailCtrl.text, passwordCtrl.text);
                  setState(() => loading = false);

                  if (user != null) {
                    if (!user.emailVerified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please verify your email before logging in.')
                        )
                      );
                    } else {
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (_) => HomePage())
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid email or password'))
                    );
                  }
                },
              ),
              SizedBox(height: 24,),
              Row(
                children: [
                  Expanded(child: Divider(),),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider(),),
                ],
              ),
              SizedBox(height: 24,),
              ElevatedButton.icon(
                icon: Icon(Icons.login),
                label: Text('Sign in with Google'),
                onPressed: () async {
                  setState(() => loading = true);
                  final user = await auth.signInWithGoogle();
                  setState(() => loading = false);
                  if (user != null) {
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (_) => HomePage())
                    );
                  }
                },
              ),
              SizedBox(height: 12,),
              TextButton(
                child: Text('Dont have an account? Register'),
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => RegisterPage())
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}