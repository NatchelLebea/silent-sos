import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
   const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 100, color: Color(0xFF0EAD69)),
            SizedBox(height: 20),
            Text("Hi There,\nNice to see you.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0E355A))),
            SizedBox(height: 20),
            TextField(controller: emailController, decoration: InputDecoration(hintText: 'Email address')),
            SizedBox(height: 12),
            TextField(controller: passwordController, decoration: InputDecoration(hintText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage())),
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
