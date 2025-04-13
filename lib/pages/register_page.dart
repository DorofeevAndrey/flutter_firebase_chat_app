import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/auth/auth_service.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key, required this.onTap});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  // tap to go to login page
  final void Function() onTap;

  //register method
  void register(BuildContext context) {
    // get auth service
    final auth = AuthService();
    // passwords match -> create user
    if (_pwController.text == _confirmPwController.text) {
      try {
        auth.signUpWithEmailPassword(_emailController.text, _pwController.text);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(e.toString())),
        );
      }
    }
    // passwords dont match -> tell user to fix
    else {
      showDialog(
        context: context,
        builder:
            (context) =>
                const AlertDialog(title: Text("Password don't match!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            Icon(Icons.message, size: 60, color: theme.colorScheme.primary),
            const SizedBox(height: 50),

            // welcome back message
            Text(
              "Let's create an account for you",
              style: TextStyle(color: theme.colorScheme.primary, fontSize: 16),
            ),
            const SizedBox(height: 25),

            // email textfield
            MyTextfield(
              hintText: "Email",
              obscureText: false,
              controller: _emailController,
            ),
            const SizedBox(height: 10),

            // pw textfield
            MyTextfield(
              hintText: "Password",
              obscureText: true,
              controller: _pwController,
            ),
            const SizedBox(height: 10),

            // confirm pw textfield
            MyTextfield(
              hintText: "Confirm password",
              obscureText: true,
              controller: _confirmPwController,
            ),
            const SizedBox(height: 25),

            // login button
            MyButton(
              title: "Register",
              onTap: () {
                register(context);
              },
            ),
            const SizedBox(height: 25),

            // regiter now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Login now",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
