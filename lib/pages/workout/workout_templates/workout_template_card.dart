import 'package:flutter/material.dart';
import 'package:group_project/constants/themes/app_colours.dart';
import 'package:group_project/models/workout_template.dart';
import 'package:group_project/models/exercise.dart';
import 'package:group_project/pages/workout/workout_templates/components/template_menu_anchor.dart';

class WorkoutTemplateCard extends StatelessWidget {
  final WorkoutTemplate workoutTemplateData;
  final List<Exercise> exerciseData;

  const WorkoutTemplateCard({
    super.key,
    required this.workoutTemplateData,
    required this.exerciseData,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(
          color: AppColours.secondary,
          width: 1,
        ),
      ),
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        workoutTemplateData.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      TemplateMenuAnchor(
                        workoutTemplateId: workoutTemplateData.id,
                      )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      workoutTemplateData.exercisesSetsInfo.asMap().entries.map(
                    (entry) {
                      final exercise = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          '${exercise.exerciseSets.length} × ${exercise.exercise.target!.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
                // FractionallySizedBox(
                //   widthFactor: 1,
                //   child: ElevatedButton(
                //     onPressed: () async {
                //       await showModalBottomSheet(
                //         context: context,
                //         builder: (context) => StartNewWorkout(
                //           exerciseData: exerciseData,
                //         ),
                //       );
                //     },
                //     style: ButtonStyle(
                //       backgroundColor: MaterialStateProperty.all<Color>(
                //         AppColours.secondary,
                //       ),
                //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                //         RoundedRectangleBorder(
                //           side: const BorderSide(
                //               color: Color(0xFFE1F0CF), width: 1.0),
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //       ),
                //     ),
                //     child: const Text(
                //       'Start Workout',
                //       style: TextStyle(
                //         color: Colors.black,
                //         fontSize: 16,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
