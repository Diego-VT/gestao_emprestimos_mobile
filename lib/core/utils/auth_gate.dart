import 'package:flutter/material.dart';

import '../../repositories/auth_repository.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authRepository = AuthRepository();
  late Future<bool> _sessaoFuture;

  @override
  void initState() {
    super.initState();
    _sessaoFuture = _authRepository.existeSessao();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sessaoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data ?? false) {
          return const DashboardScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
