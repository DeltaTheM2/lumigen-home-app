import 'package:flutter/material.dart';
import 'package:lumigen/detailedUserPage.dart';
import 'package:lumigen/deviceSettingsScreen.dart';
import 'package:lumigen/firebase/authentication.dart';
import 'package:lumigen/loginScreen.dart';

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCard(
              context,
              icon: Icons.info,
              text: 'User Information',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailedUserPage(userId: AuthenticationHelper().uid)),
                );
              },
            ),
            const Divider(),
            _buildCard(
              context,
              icon: Icons.settings,
              text: 'Device Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeviceSettingsPage()),
                );
              },
            ),
            const Divider(),
            _buildCard(
              context,
              icon: Icons.logout,
              text: 'Sign Out',
              onTap: () {
                _showConfirmationDialog(
                  context,
                  title: 'Sign Out',
                  content: 'Are you sure you want to sign out?',
                  onConfirm: () async {
                    await AuthenticationHelper().signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()), // Replace with your login screen
                          (route) => false,
                    );                  },
                );
              },
            ),
            const Divider(),
            _buildCard(
              context,
              icon: Icons.delete,
              text: 'Delete Account',
              onTap: () {
                _showDeleteAccountDialog(context);
              },
            ),
          ],
        ),
    );
  }

  Widget _buildCard(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style: TextStyle(fontSize: 18),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, {required String title, required String content, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: onConfirm,
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Type in your password to confirm the delete.'),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await AuthenticationHelper().deleteAccount(passwordController.text);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()), // Replace with your login screen
                    (route) => false,
              );            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
