import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/pomodoro_session.dart';
import '../../domain/repositories/pomodoro_repository.dart';
import '../models/pomodoro_session_model.dart';

class FirestorePomodoroRepository implements PomodoroRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  FirestorePomodoroRepository(this._firestore, this._userId);

  CollectionReference<Map<String, dynamic>> get _sessionsCollection =>
      _firestore.collection('users').doc(_userId).collection('pomodoro_sessions');

  @override
  Future<List<PomodoroSession>> getSessions() async {
    final snapshot = await _sessionsCollection.get();
    return snapshot.docs
        .map((doc) => PomodoroSessionModel.fromMap(doc.data()).toEntity())
        .toList();
  }

  @override
  Future<void> logSession(PomodoroSession session) async {
    final model = PomodoroSessionModel.fromEntity(session);
    await _sessionsCollection.doc(session.id).set(model.toMap());
  }
}
