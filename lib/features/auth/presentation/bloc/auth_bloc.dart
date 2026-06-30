import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);

    // Subscribe to FirebaseAuth state changes to automatically transition state
    _userSubscription = _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        add(AppStarted()); // Re-evaluate auth state when user login changes
      }
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      emit(Authenticated(currentUser));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (credential.user != null) {
        emit(Authenticated(credential.user!));
      } else {
        emit(Unauthenticated());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Authentication failed'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (credential.user != null) {
        emit(Authenticated(credential.user!));
      } else {
        emit(Unauthenticated());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Registration failed'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
