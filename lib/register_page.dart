import 'package:activity_8/auth_service.dart';
import 'package:activity_8/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RegisterPage extends StatefulWidget {
  const new({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService auth = AuthService();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register'),),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder()
                ),
              ),
              SizedBox(height: 12,),
              TextField(
                controller: passwordCtrl,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder()
                ),
              ),
              SizedBox(height: 12,),
              ElevatedButton(
                child: loading
                  ? CircularProgressIndicator(color: Colors.white,)
                  : Text('Register'), 

                onPressed: () async {
                  if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter email and password')),
                    );
                    return;
                  }

                  setState(() => loading = true);

                  final user = await auth.registerWithEmail(
                    emailCtrl.text.trim(),
                    passwordCtrl.text,
                  );

                  setState(() => loading = false);

                  if (user != null) {
                    if (!user.emailVerified) {
                      await user.sendEmailVerification();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Email verification sent. Please check your inbox',
                          ),
                        ),
                      );
                    }

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Registration failed')),
                    );
                  }
                },
              ),
              SizedBox(height: 12,),
              TextButton(
                child: Text('Already have an account? Login.'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage())
                  );
                },
              ),
            ],
          )
        ),
      ),
    );
  }
}