import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';

import '../../services/auth/auth_service.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final AuthService _authService = AuthService();

  void logout() {
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_authService.getCurrentUser()!.email!),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 0,
      ),

      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // динамичный текст
                Consumer<ThemeProvider>(
                  builder: (context, provider, child) {
                    return Text(
                      provider.isDarkMode ? "Dark Mode" : "Light Mode",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),

                // switch toggle
                Consumer<ThemeProvider>(
                  builder: (context, provider, child) {
                    return CupertinoSwitch(
                      activeTrackColor: Colors.grey.shade700,
                      value: provider.isDarkMode,
                      onChanged: (_) {
                        provider.toggleTheme();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            padding: EdgeInsets.all(5),
            child: ListTile(
              title: const Text(
                "Logout",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.logout),
              onTap: logout,
            ),
          ),
        ],
      ),
    );
  }
}
