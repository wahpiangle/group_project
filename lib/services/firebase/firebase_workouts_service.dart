import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_project/main.dart';
import 'package:group_project/models/firebase/firebase_workout_session.dart';
import 'package:group_project/models/workout_session.dart';

class FirebaseWorkoutsService {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final CollectionReference workoutsCollectionRef =
      db.collection('workouts');

  static void createWorkoutSession(WorkoutSession workoutSession) async {
    final User user = auth.currentUser!;
    final uid = user.uid;
    await workoutsCollectionRef
        .doc(uid)
        .collection('workoutSessions')
        .doc(workoutSession.id.toString())
        .set(
      {
        'date': DateTime.now(),
        'title': workoutSession.title,
        'note': workoutSession.note,
        'duration': workoutSession.duration,
        'postId': workoutSession.postId,
        'exercisesSetsInfo': workoutSession.exercisesSetsInfo
            .map((exercisesSetsInfo) => {
                  'exercise': exercisesSetsInfo.exercise.targetId,
                  'exerciseName': exercisesSetsInfo.exercise.target!.name,
                  'exerciseSets': exercisesSetsInfo.exerciseSets
                      .map((exerciseSet) => {
                            'reps': exerciseSet.reps,
                            'weight': exerciseSet.weight,
                            'time': exerciseSet.time,
                            'isPersonalRecord': exerciseSet.isPersonalRecord,
                          })
                      .toList(),
                })
            .toList(),
      },
    );
  }

  static Future<void> deleteWorkoutSession(int workoutSessionId) async {
    final User user = auth.currentUser!;
    if (user.isAnonymous) {
      return;
    }
    final uid = user.uid;
    await workoutsCollectionRef
        .doc(uid)
        .collection('workoutSessions')
        .doc(workoutSessionId.toString())
        .delete();
  }

  static Future<List<dynamic>> getWorkoutSessionsOfUser() async {
    final User user = auth.currentUser!;
    if (user.isAnonymous || !user.emailVerified) {
      return [];
    }
    final uid = user.uid;
    final List<dynamic> workoutSessions = await workoutsCollectionRef
        .doc(uid)
        .collection('workoutSessions')
        .get()
        .then((snapshot) => snapshot.docs.map((document) {
              final data = document.data();
              data['id'] = document.id;
              return data;
            }).toList());
    return workoutSessions;
  }

  static void updateWorkoutSession(int workoutSessionId) async {
    final User user = auth.currentUser!;
    if (user.isAnonymous) {
      return;
    }
    final uid = user.uid;
    final updatedWorkoutSession =
        objectBox.workoutSessionService.getWorkoutSession(workoutSessionId);
    await workoutsCollectionRef
        .doc(uid)
        .collection('workoutSessions')
        .doc(workoutSessionId.toString())
        .update({
      'date': updatedWorkoutSession!.date,
      'title': updatedWorkoutSession.title,
      'note': updatedWorkoutSession.note,
      'duration': updatedWorkoutSession.duration,
      'postId': updatedWorkoutSession.postId,
      'exercisesSetsInfo': updatedWorkoutSession.exercisesSetsInfo
          .map((exercisesSetsInfo) => {
                'exercise': exercisesSetsInfo.exercise.targetId,
                'exerciseSets': exercisesSetsInfo.exerciseSets
                    .map((exerciseSet) => {
                          'reps': exerciseSet.reps,
                          'weight': exerciseSet.weight,
                          'time': exerciseSet.time,
                        })
                    .toList(),
              })
          .toList(),
    });
  }

  static Future<FirebaseWorkoutSession> getWorkoutSessionByUser(
      int workoutSessionId, String userId) async {
    try {
      final workoutSessionDocument = await workoutsCollectionRef
          .doc(userId)
          .collection('workoutSessions')
          .doc(workoutSessionId.toString())
          .get();

      final data = workoutSessionDocument.data();
      FirebaseWorkoutSession workoutSession =
          FirebaseWorkoutSession.fromJson(data!);
      return workoutSession;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<void> attachPostIdToWorkoutSession(
      int workoutSessionId, String userId, String postId) async {
    await workoutsCollectionRef
        .doc(userId)
        .collection('workoutSessions')
        .doc(workoutSessionId.toString())
        .update({'postId': postId});
  }


  static Future<List<FirebaseWorkoutSession>> getWorkoutSessionsByUserId(String userId) async {
    try {
      final querySnapshot = await workoutsCollectionRef
          .doc(userId)
          .collection('workoutSessions')
          .get();

      List<FirebaseWorkoutSession> sessions = [];
      for (var doc in querySnapshot.docs) {
        var session = FirebaseWorkoutSession.fromJson(doc.data());
        sessions.add(session);
      }
      return sessions;
    } catch (e) {
      rethrow;
    }
  }
}
