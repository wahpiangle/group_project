import 'package:flutter/material.dart';
import 'package:group_project/constants/themes/app_colours.dart';
import 'package:group_project/main.dart';
import 'package:group_project/models/workout_template.dart';
import 'package:group_project/pages/workout/workout_templates/workout_template_card.dart';
import 'package:group_project/pages/workout/workout_templates/create_template_page.dart';

class WorkoutTemplates extends StatefulWidget {
  const WorkoutTemplates({super.key});

  @override
  State<WorkoutTemplates> createState() => _WorkoutTemplatesState();
}

class _WorkoutTemplatesState extends State<WorkoutTemplates> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Workout Templates',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTemplatePage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.add,
                color: Colors.black,
                size: 18,
              ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  AppColours.secondary,
                ),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
                  horizontal: 8,
                )),
              ),
              label: const Text(
                'Template',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.6,
          margin: const EdgeInsets.only(top: 10),
          child: StreamBuilder<List<WorkoutTemplate>>(
            stream: objectBox.workoutTemplateService.watchWorkoutTemplates(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final workoutTemplate = snapshot.data![index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: WorkoutTemplateCard(
                        workoutTemplateData: workoutTemplate,
                        exerciseData:
                            objectBox.exerciseService.getAllExercises(),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
