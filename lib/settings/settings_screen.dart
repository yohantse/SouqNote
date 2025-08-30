import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../inventory/lock_manager.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  LockType? _selectedLockType;
  String? _pinInput;

  @override
  void initState() {
    super.initState();
    final lockManager = Provider.of<LockManager>(context, listen: false);
    _selectedLockType = lockManager.lockType;
  }

  void _updateLock(LockType type) {
    final lockManager = Provider.of<LockManager>(context, listen: false);
    if (type == LockType.pin) {
      _showPinDialog(lockManager);
    } else {
      lockManager.setLockType(type);
      setState(() => _selectedLockType = type);
    }
  }

  void _showPinDialog(LockManager lockManager) {
    _pinInput = '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Set a 4-digit PIN'),
        content: TextField(
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          onChanged: (val) => _pinInput = val,
          decoration: const InputDecoration(hintText: 'Enter PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_pinInput != null && _pinInput!.length == 4) {
                lockManager.setLockType(LockType.pin, pin: _pinInput);
                setState(() => _selectedLockType = LockType.pin);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Settings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dark Mode',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Switch(
                value: themeProvider.isDarkMode,
                onChanged: (val) {
                  themeProvider.toggleDarkMode(val);
                },
              ),
            ],
          ),
          const Divider(height: 32),

          // Lock Settings
          const Text('App Lock', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RadioListTile<LockType>(
            title: const Text('No Lock'),
            value: LockType.none,
            groupValue: _selectedLockType,
            onChanged: (val) => _updateLock(val!),
          ),
          RadioListTile<LockType>(
            title: const Text('PIN'),
            value: LockType.pin,
            groupValue: _selectedLockType,
            onChanged: (val) => _updateLock(val!),
          ),
          RadioListTile<LockType>(
            title: const Text('Biometrics'),
            value: LockType.biometrics,
            groupValue: _selectedLockType,
            onChanged: (val) => _updateLock(val!),
          ),
          const Divider(height: 32),

          // About Section
          const Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
