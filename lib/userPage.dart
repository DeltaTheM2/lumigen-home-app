import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Page'),
      ),
      body: Padding(
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
                  MaterialPageRoute(builder: (context) => UserDetailsPage()),
                );
              },
            ),
            Divider(),
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
            Divider(),
            _buildCard(
              context,
              icon: Icons.logout,
              text: 'Sign Out',
              onTap: () {
                _showConfirmationDialog(
                  context,
                  title: 'Sign Out',
                  content: 'Are you sure you want to sign out?',
                  onConfirm: () {
                    // Add sign out logic here
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
            Divider(),
            _buildCard(
              context,
              icon: Icons.delete,
              text: 'Delete Account',
              onTap: () {
                _showConfirmationDialog(
                  context,
                  title: 'Delete Account',
                  content: 'Are you sure you want to delete your account? This action cannot be undone.',
                  onConfirm: () {
                    // Add delete account logic here
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ],
        ),
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
}

class UserDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Center(
        child: Text('User details will be shown here.'),
      ),
    );
  }
}

class DeviceSettingsPage extends StatefulWidget {
  @override
  _DeviceSettingsPageState createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  final String serverUrl = 'http://flask-server-ip:5000';
  bool devicePaired = false;
  Color goodColor = Colors.green;
  Color moderateColor = Colors.yellow;
  Color unhealthySensitiveColor = Colors.orange;
  Color unhealthyColor = Colors.red;
  Color veryUnhealthyColor = Colors.purple;
  Color hazardousColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _loadColors();
  }

  Future<void> _loadColors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      goodColor = _getColorFromPrefs(prefs, 'goodColor') ?? Colors.green;
      moderateColor = _getColorFromPrefs(prefs, 'moderateColor') ?? Colors.yellow;
      unhealthySensitiveColor = _getColorFromPrefs(prefs, 'unhealthySensitiveColor') ?? Colors.orange;
      unhealthyColor = _getColorFromPrefs(prefs, 'unhealthyColor') ?? Colors.red;
      veryUnhealthyColor = _getColorFromPrefs(prefs, 'veryUnhealthyColor') ?? Colors.purple;
      hazardousColor = _getColorFromPrefs(prefs, 'hazardousColor') ?? Colors.red;
    });
  }

  Future<void> _saveColor(String key, Color color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, color.value);
  }

  Color? _getColorFromPrefs(SharedPreferences prefs, String key) {
    int? colorValue = prefs.getInt(key);
    if (colorValue != null) {
      return Color(colorValue);
    }
    return null;
  }

  Future<void> pairDevice() async {
    // Logic to pair device
    setState(() {
      devicePaired = true;
    });
  }

  Future<void> updateAirQuality() async {
    final response = await http.get(Uri.parse('$serverUrl/update_air_quality'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Update UI with air quality data if needed
    } else {
      // Handle error
    }
  }

  Future<void> setLightColor(String category, Color color) async {
    final response = await http.post(
      Uri.parse('$serverUrl/set_light_color'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'category': category,
        'red': color.red / 255,
        'green': color.green / 255,
        'blue': color.blue / 255,
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        switch (category) {
          case 'good':
            goodColor = color;
            _saveColor('goodColor', color);
            break;
          case 'moderate':
            moderateColor = color;
            _saveColor('moderateColor', color);
            break;
          case 'unhealthySensitive':
            unhealthySensitiveColor = color;
            _saveColor('unhealthySensitiveColor', color);
            break;
          case 'unhealthy':
            unhealthyColor = color;
            _saveColor('unhealthyColor', color);
            break;
          case 'veryUnhealthy':
            veryUnhealthyColor = color;
            _saveColor('veryUnhealthyColor', color);
            break;
          case 'hazardous':
            hazardousColor = color;
            _saveColor('hazardousColor', color);
            break;
        }
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: devicePaired
            ? ListView(
          children: [
            buildColorPickerRow('Good (Green)', goodColor, (color) => setLightColor('good', color)),
            buildColorPickerRow('Moderate (Yellow)', moderateColor, (color) => setLightColor('moderate', color)),
            buildColorPickerRow('Unhealthy for Sensitive Groups (Orange)', unhealthySensitiveColor, (color) => setLightColor('unhealthySensitive', color)),
            buildColorPickerRow('Unhealthy (Red)', unhealthyColor, (color) => setLightColor('unhealthy', color)),
            buildColorPickerRow('Very Unhealthy (Purple)', veryUnhealthyColor, (color) => setLightColor('veryUnhealthy', color)),
            buildColorPickerRow('Hazardous (Flashing Red)', hazardousColor, (color) => setLightColor('hazardous', color)),
          ],
        )
            : ElevatedButton(
          onPressed: pairDevice,
          child: Text('Pair a Device'),
        ),
      ),
    );
  }

  Widget buildColorPickerRow(String label, Color currentColor, ValueChanged<Color> onColorChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          ElevatedButton(
            onPressed: () async {
              final pickedColor = await showDialog<Color>(
                context: context,
                builder: (context) => ColorPickerDialog(initialColor: currentColor),
              );
              if (pickedColor != null) {
                onColorChanged(pickedColor);
              }
            },
            child: Text('Change Color'),
            style: ElevatedButton.styleFrom(backgroundColor: currentColor),
          ),
        ],
      ),
    );
  }
}

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  ColorPickerDialog({required this.initialColor});

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color selectedColor;

  _ColorPickerDialogState() : selectedColor = Colors.white;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pick a color'),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: selectedColor,
          onColorChanged: (color) {
            setState(() {
              selectedColor = color;
            });
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(selectedColor);
          },
          child: Text('Select'),
        ),
      ],
    );
  }
}
