import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../inventory/lock_manager.dart';
import 'package:local_auth/local_auth.dart';

class LockCheckWrapper extends StatefulWidget {
  final Widget child;
  const LockCheckWrapper({super.key, required this.child});

  @override
  State<LockCheckWrapper> createState() => _LockCheckWrapperState();
}

class _LockCheckWrapperState extends State<LockCheckWrapper> {
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLock());
  }

  Future<void> _checkLock() async {
    final lockManager = Provider.of<LockManager>(context, listen: false);

    if (lockManager.lockType == LockType.none) {
      setState(() => _unlocked = true);
      return;
    }

    if (lockManager.lockType == LockType.biometrics) {
      final auth = LocalAuthentication();
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Unlock SouqNote',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuthenticate) setState(() => _unlocked = true);
    }

    if (lockManager.lockType == LockType.pin) {
      _showPinDialog(lockManager);
    }
  }

  void _showPinDialog(LockManager lockManager) {
    String input = '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Enter PIN'),
        content: TextField(
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          onChanged: (val) => input = val,
          decoration: const InputDecoration(hintText: 'PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (lockManager.verifyPin(input)) {
                setState(() => _unlocked = true);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return widget.child;

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
