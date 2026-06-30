import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import 'package:sentry_flutter/sentry_flutter.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    developer.log(
      'onChange -- ${bloc.runtimeType}: '
      'Current State: ${change.currentState.runtimeType} | '
      'Next State: ${change.nextState.runtimeType}',
      name: 'BLOC',
    );
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    developer.log(
      'onTransition -- ${bloc.runtimeType}: '
      'Event: ${transition.event.runtimeType} | '
      'Current State: ${transition.currentState.runtimeType} | '
      'Next State: ${transition.nextState.runtimeType}',
      name: 'BLOC',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    developer.log(
      'onError -- ${bloc.runtimeType}: Error: $error',
      name: 'BLOC_ERROR',
      error: error,
      stackTrace: stackTrace,
    );
    // Send critical state errors to Sentry
    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('source', 'bloc');
        scope.setTag('bloc_type', bloc.runtimeType.toString());
      },
    );
    super.onError(bloc, error, stackTrace);
  }
}
