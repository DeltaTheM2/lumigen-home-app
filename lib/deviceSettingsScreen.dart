import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeviceSettingsPage extends StatefulWidget {
  @override
  _DeviceSettingsPageState createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  final String serverUrl = 'http://your-flask-server-ip:5000';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool devicePaired = false;
  bool isLoading = false;
  String? deviceId;
  Color goodColor = Colors.green;
  Color moderateColor = Colors.yellow;
  Color unhealthySensitiveColor = Colors.orange;
  Color unhealthyColor = Colors.red;
  Color veryUnhealthyColor = Colors.purple;
  Color hazardousColor = Colors.red;

  final _deviceIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadColors();
    _loadDeviceIdFromPrefs();
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

    // Attempt to sync with the server
    await _syncWithServer();
  }

  Future<void> _loadDeviceIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedDeviceId = prefs.getString('deviceID');

    if (cachedDeviceId != null && cachedDeviceId.isNotEmpty) {
      setState(() {
        deviceId = cachedDeviceId;
        devicePaired = true;
      });
    } else {
      // If no cached ID, check Firestore
      await _checkDevicePairing();
    }
  }

  Future<void> _checkDevicePairing() async {
    User? user = _auth.currentUser;
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();

    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      if (data.containsKey('deviceID')) {
        setState(() {
          deviceId = data['deviceID'];
          devicePaired = deviceId!.isNotEmpty;
        });
        // Cache the device ID locally
        _saveDeviceIdToPrefs(deviceId!);
      }
    }
  }

  Future<void> _saveDeviceIdToPrefs(String deviceId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceID', deviceId);
  }

  Future<void> _syncWithServer() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/get_colors'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          goodColor = Color(data['goodColor']);
          moderateColor = Color(data['moderateColor']);
          unhealthySensitiveColor = Color(data['unhealthySensitiveColor']);
          unhealthyColor = Color(data['unhealthyColor']);
          veryUnhealthyColor = Color(data['veryUnhealthyColor']);
          hazardousColor = Color(data['hazardousColor']);
        });

        // Save the colors locally
        _saveColor('goodColor', goodColor);
        _saveColor('moderateColor', moderateColor);
        _saveColor('unhealthySensitiveColor', unhealthySensitiveColor);
        _saveColor('unhealthyColor', unhealthyColor);
        _saveColor('veryUnhealthyColor', veryUnhealthyColor);
        _saveColor('hazardousColor', hazardousColor);
      }
    } catch (e) {
      print('Failed to sync with server: $e');
    }
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
    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      await _firestore.collection('users').doc(user!.uid).update({
        'deviceID': _deviceIdController.text,
      });

      // Cache the device ID locally
      await _saveDeviceIdToPrefs(_deviceIdController.text);

      setState(() {
        devicePaired = true;
        deviceId = _deviceIdController.text;
      });
    } catch (e) {
      print('Failed to update device ID: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> setLightColor(String category, Color color) async {
    // Update locally first
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

    // Attempt to update the server
    try {
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

      if (response.statusCode != 200) {
        throw Exception('Failed to update server');
      }
    } catch (e) {
      print('Failed to update server: $e');
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
            Text('Device ID: $deviceId'),
            buildColorPickerRow('Good', goodColor, (color) => setLightColor('good', color)),
            buildColorPickerRow('Moderate', moderateColor, (color) => setLightColor('moderate', color)),
            buildColorPickerRow('Unhealthy for Sensitive Groups', unhealthySensitiveColor, (color) => setLightColor('unhealthySensitive', color)),
            buildColorPickerRow('Unhealthy', unhealthyColor, (color) => setLightColor('unhealthy', color)),
            buildColorPickerRow('Very Unhealthy', veryUnhealthyColor, (color) => setLightColor('veryUnhealthy', color)),
            buildColorPickerRow('Hazardous', hazardousColor, (color) => setLightColor('hazardous', color)),
          ],
        )
            : Column(
          children: [
            TextField(
              controller: _deviceIdController,
              decoration: InputDecoration(labelText: 'Enter Device ID'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : pairDevice,
              child: isLoading
                  ? CircularProgressIndicator(
                color: Colors.white,
              )
                  : Text('Confirm Device ID'),
            ),
          ],
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
            style: ElevatedButton.styleFrom(
              backgroundColor: currentColor,
            ),
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
  late Color selectedColor;

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
