import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tasks/presentation/screens/home_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const HomeScreen();
        } else if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}
