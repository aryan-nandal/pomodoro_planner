import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/pomodoro_session.dart';
import '../../domain/repositories/pomodoro_repository.dart';
import 'pomodoro_event.dart';
import 'pomodoro_state.dart';

class PomodoroBloc extends Bloc<PomodoroEvent, PomodoroState> {
  final PomodoroRepository _repository;
  final AudioService _audioService;
  final HapticService _hapticService;
  final NotificationService _notificationService;

  StreamSubscription<int>? _tickerSubscription;

  PomodoroBloc({
    required PomodoroRepository repository,
    required AudioService audioService,
    required HapticService hapticService,
    required NotificationService notificationService,
  })  : _repository = repository,
        _audioService = audioService,
        _hapticService = hapticService,
        _notificationService = notificationService,
        super(PomodoroState.initial()) {
    on<StartTimer>(_onStartTimer);
    on<PauseTimer>(_onPauseTimer);
    on<ResetTimer>(_onResetTimer);
    on<SkipTimer>(_onSkipTimer);
    on<TimerTicked>(_onTimerTicked);
    on<SelectFocusTask>(_onSelectFocusTask);
    on<SetCustomDurations>(_onSetCustomDurations);
  }

  void _onStartTimer(StartTimer event, Emitter<PomodoroState> emit) {
    if (state.status == PomodoroStatus.running) return;

    _tickerSubscription?.cancel();
    
    emit(state.copyWith(status: PomodoroStatus.running));

    _tickerSubscription = Stream.periodic(const Duration(seconds: 1), (x) => x)
        .listen((_) {
          add(TimerTicked(state.secondsRemaining - 1));
        });

    // Schedule background local notification for session completion
    _notificationService.cancelAll();
    final title = state.type == PomodoroType.focus ? 'Focus Session Completed!' : 'Break Time Over!';
    final body = state.type == PomodoroType.focus ? 'Time for a short break.' : 'Time to get back to work.';
    _notificationService.scheduleNotification(
      id: 99,
      title: title,
      body: body,
      secondsFromNow: state.secondsRemaining,
    );
  }

  void _onPauseTimer(PauseTimer event, Emitter<PomodoroState> emit) {
    _tickerSubscription?.cancel();
    _notificationService.cancelAll();
    emit(state.copyWith(status: PomodoroStatus.paused));
  }

  void _onResetTimer(ResetTimer event, Emitter<PomodoroState> emit) {
    _tickerSubscription?.cancel();
    _notificationService.cancelAll();
    final defaultSeconds = _getDefaultSeconds(state.type);
    emit(state.copyWith(
      status: PomodoroStatus.idle,
      secondsRemaining: defaultSeconds,
      totalSeconds: defaultSeconds,
    ));
  }

  void _onSkipTimer(SkipTimer event, Emitter<PomodoroState> emit) {
    _tickerSubscription?.cancel();
    _notificationService.cancelAll();
    _transitionToNextMode(emit);
  }

  Future<void> _onTimerTicked(TimerTicked event, Emitter<PomodoroState> emit) async {
    if (event.secondsRemaining > 0) {
      emit(state.copyWith(secondsRemaining: event.secondsRemaining));
    } else {
      _tickerSubscription?.cancel();
      
      // Completion Side Effects
      _audioService.playAlarmBell();
      _hapticService.heavyImpact();
      
      final title = state.type == PomodoroType.focus ? 'Session Finished!' : 'Break Finished!';
      final body = state.type == PomodoroType.focus ? 'Take a well-deserved break.' : 'Ready to start focusing?';
      
      await _notificationService.showNotification(
        id: 100,
        title: title,
        body: body,
      );

      // If we just finished a focus session, save it
      if (state.type == PomodoroType.focus) {
        final session = PomodoroSession(
          id: const Uuid().v4(),
          taskId: state.selectedTask?.id,
          durationMinutes: state.focusDurationMinutes,
          timestamp: DateTime.now(),
          type: 'focus',
        );
        try {
          await _repository.logSession(session);
        } catch (_) {}
      }

      _transitionToNextMode(emit);
    }
  }

  void _onSelectFocusTask(SelectFocusTask event, Emitter<PomodoroState> emit) {
    emit(state.copyWith(
      selectedTask: () => event.task,
    ));
  }

  void _onSetCustomDurations(SetCustomDurations event, Emitter<PomodoroState> emit) {
    _tickerSubscription?.cancel();
    _notificationService.cancelAll();

    final currentType = state.type;
    int durationSecs;
    if (currentType == PomodoroType.focus) {
      durationSecs = event.focusMinutes * 60;
    } else if (currentType == PomodoroType.shortBreak) {
      durationSecs = event.shortBreakMinutes * 60;
    } else {
      durationSecs = event.longBreakMinutes * 60;
    }

    emit(state.copyWith(
      focusDurationMinutes: event.focusMinutes,
      shortBreakDurationMinutes: event.shortBreakMinutes,
      longBreakDurationMinutes: event.longBreakMinutes,
      secondsRemaining: durationSecs,
      totalSeconds: durationSecs,
      status: PomodoroStatus.idle,
    ));
  }

  void _transitionToNextMode(Emitter<PomodoroState> emit) {
    PomodoroType nextType;
    int nextCycles = state.completedCycles;

    if (state.type == PomodoroType.focus) {
      nextCycles += 1;
      // After 4 focus cycles, take a long break. Otherwise, take a short break.
      if (nextCycles % 4 == 0) {
        nextType = PomodoroType.longBreak;
      } else {
        nextType = PomodoroType.shortBreak;
      }
    } else {
      nextType = PomodoroType.focus;
    }

    final nextDurationSecs = _getDefaultSeconds(nextType);

    emit(state.copyWith(
      type: nextType,
      secondsRemaining: nextDurationSecs,
      totalSeconds: nextDurationSecs,
      status: PomodoroStatus.completed, // User can click play to start the next state
      completedCycles: nextCycles,
    ));
  }

  int _getDefaultSeconds(PomodoroType type) {
    switch (type) {
      case PomodoroType.focus:
        return state.focusDurationMinutes * 60;
      case PomodoroType.shortBreak:
        return state.shortBreakDurationMinutes * 60;
      case PomodoroType.longBreak:
        return state.longBreakDurationMinutes * 60;
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
