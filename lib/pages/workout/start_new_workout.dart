import 'dart:async';
import 'package:flutter/material.dart';
import 'package:group_project/main.dart';
import 'package:group_project/models/exercise.dart';
import 'package:group_project/models/current_workout_session.dart';
import 'package:group_project/pages/history/congratulation_screen.dart';
import 'package:group_project/models/workout_session.dart';
import 'package:group_project/pages/workout/components/tiles/exercise_tile.dart';
import 'package:provider/provider.dart';
import 'package:group_project/pages/workout/components/tiles/components/timer_provider.dart';
import 'package:group_project/pages/workout/components/tiles/components/rest_timer_provider.dart';
import 'package:group_project/pages/workout/components/tiles/components/rest_time_picker.dart';

import 'components/tiles/components/resttimer_add_minus.dart';


import 'package:group_project/services/firebase/workoutSession/firebase_workouts_service.dart';

class StartNewWorkout extends StatefulWidget {

  final List<Exercise> exerciseData;

  const StartNewWorkout({super.key, required this.exerciseData});

  @override
  State<StartNewWorkout> createState() => _StartNewWorkoutState();
}

class _StartNewWorkoutState extends State<StartNewWorkout>
    with TickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isTimerRunning = false;
  late List<Exercise> exerciseData;
  TextEditingController weightsController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  bool _isSetTimeVisible = true;



  List<Widget> setBorders = [];

  @override
  void initState() {
    super.initState();
    exerciseData = widget.exerciseData;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 1, end: 0).animate(_controller);

    _animation.addListener(() {
      setState(() {});
    });
  }


  void selectExercise(Exercise selectedExercise) {
    objectBox.currentWorkoutSessionService
        .addExerciseToCurrentWorkoutSession(selectedExercise);
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    // final restTimerProvider = Provider.of<RestTimerProvider>(context, listen: false);

    if (!_isTimerRunning) {
      timerProvider.startTimer();
      // timerProvider.startExerciseTimer(selectedExercise.id);
      setState(() {
        _isTimerRunning = true;
      });
    }

  }


  Widget createSetBorder(int weight, int reps) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Text("Weight: $weight"),
          const SizedBox(width: 10),
          Text("Reps: $reps"),
        ],
      ),
    );
  }

  Widget buildSetBordersList() {
    return ListView(
      children: setBorders,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    weightsController.dispose();
    repsController.dispose();
    super.dispose();

  }



  void _delete(BuildContext context) {
    final restTimerProvider = Provider.of<RestTimerProvider>(context, listen: false);
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);

    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            surfaceTintColor: Colors.transparent,
            title: const Text(
              'Finish Workout',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure that you want to finish workout?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Stop the rest timer and general workout timer
                  restTimerProvider.stopRestTimer();
                  timerProvider.stopTimer();
                  timerProvider.resetTimer();
                  // Close the dialog
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  WorkoutSession savedWorkout =
                  objectBox.saveCurrentWorkoutSession();
                  FirebaseWorkoutsService.createWorkoutSession(savedWorkout);
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return const CongratulationScreen();
                      },
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = 0.0;
                        const end = 1.0;
                        const curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return ScaleTransition(
                          scale: offsetAnimation,
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 500), // Set to 0.5 seconds
                    ),
                  );
                },
                child: const Text(
                  'Finish Workout',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          );
        });
  }

  void removeSet(int exerciseSetId) {
    setState(() {
      objectBox.removeSetFromExercise(exerciseSetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final restTimerProvider = Provider.of<RestTimerProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  bool everySetCompleted = objectBox
                      .currentWorkoutSessionService
                      .getCurrentWorkoutSession()
                      .exercisesSetsInfo
                      .every((exercisesSetsInfo) {
                    return exercisesSetsInfo.exerciseSets.every((exerciseSet) {
                      return exerciseSet.isCompleted;
                    });
                  });
                  bool isNotEmpty = objectBox.currentWorkoutSessionService
                      .getCurrentWorkoutSession()
                      .exercisesSetsInfo
                      .isNotEmpty;
                  if (isNotEmpty) {
                    if (everySetCompleted) {
                      _delete(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please complete all sets",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Color(0xFF1A1A1A),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please add at least one exercise",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Color(0xFF1A1A1A),
                      ),
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Finish",
                    style: TextStyle(
                      color: Color(0xFFE1F0CF),
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: const Color(0xFF1A1A1A),
        title: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: GestureDetector(
            onTap: () {
              if (restTimerProvider.isRestTimerRunning) {
                _showTimerDetailsDialog(context, restTimerProvider);
              }
            },
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: restTimerProvider.isRestTimerEnabled &&
                  restTimerProvider.isRestTimerRunning
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      " ${TimerProvider.formatDuration(restTimerProvider.currentRestTimerDuration)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              secondChild: GestureDetector(
                onTap: () async {
                  await _showScrollTimePicker(context, restTimerProvider);
                  setState(() {
                    _isSetTimeVisible = !_isSetTimeVisible;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        " ${_formatTime(restTimerProvider.restTimerMinutes, restTimerProvider.restTimerSeconds)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      backgroundColor: const Color(0xFF1A1A1A),
      body: StreamBuilder<CurrentWorkoutSession>(
        stream:
        objectBox.currentWorkoutSessionService.watchCurrentWorkoutSession(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  ExerciseTile(
                    exerciseData: exerciseData,
                    exercisesSetsInfo:
                    snapshot.data!.exercisesSetsInfo.toList(),
                    selectExercise: selectExercise,
                    removeSet: removeSet,
                    timerProvider: timerProvider,
                  ),
                  Row(
                    children: [
                      const Text(
                        'Rest Timer',
                        style: TextStyle(
                          color: Colors.white, // Set the text color to white
                        ),
                      ),
                      Switch(
                        value: restTimerProvider.isRestTimerEnabled,
                        onChanged: (value) {
                          if (value) {
                            // Start rest timer
                            restTimerProvider.startRestTimer(context);
                          } else {
                            // Stop rest timer
                            restTimerProvider.stopRestTimer();
                          }
                          restTimerProvider.toggleRestTimer(value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //objectBox.test();
        },
        child: const Icon(Icons.add),
      ),
    );
  }


  String _formatTime(int minutes, int seconds) {
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }


  Future<void> _showScrollTimePicker(BuildContext context, RestTimerProvider restTimerProvider) async {
    // Check if the rest timer is running
    if (restTimerProvider.isRestTimerRunning) {
      _showTimerDetailsDialog(context, restTimerProvider);
    } else {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.black,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            color: Colors.black,
            child: RestTimePicker(restTimerProvider: restTimerProvider),
          );
        },
      );
    }
  }

  void _showTimerDetailsDialog(BuildContext context, RestTimerProvider restTimerProvider) {
    showDialog(
      context: context, // or Navigator.of(context)
      builder: (BuildContext context) {
        return TimerDetailsDialog(
          restTimerProvider: restTimerProvider,
        );
      },
    );
  }


}
