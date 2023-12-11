import 'package:flutter/material.dart';
import 'package:group_project/models/exercise.dart';
import 'package:group_project/pages/components/crop_image.dart';
import 'package:group_project/pages/exercise/exercise_detail.dart';

class ExerciseListItem extends StatelessWidget {
  final Exercise exercise;
  final String searchText;

  const ExerciseListItem(
      {super.key, required this.exercise, required this.searchText});

  @override
  Widget build(BuildContext context) {
    final exerciseName = exercise.name;
    final exerciseBodyPart = exercise.bodyPart.target!.name;

    // Check if the exercise name or category contains the search text
    final containsSearchText =
        exerciseName.toLowerCase().contains(searchText.toLowerCase());
    if (searchText.isEmpty || containsSearchText) {
      return Material(
        color: const Color(0xFF1A1A1A),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseDetailScreen(exercise),
              ),
            );
          },
          child: ListTile(
            horizontalTitleGap: -20,
            leading: SizedBox(
              height: 120,
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(300.0),
                child: exercise.imagePath == ''
                    ? Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1F0CF),
                          borderRadius: BorderRadius.circular(300.0),
                        ),
                        child: Center(
                          child: Text(
                            exercise.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                            ),
                          ),
                        ),
                      )
                    : ClipPath(
                        clipper: MyClipperPath(),
                        child: Container(
                          height: 60,
                          width: 80,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: Image.asset(exercise.imagePath).image,
                            fit: BoxFit.contain, //or whatever BoxFit you want
                          )),
                        ),
                      ),
              ),
            ),
            title: Text(
              exercise.name,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              exerciseBodyPart,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}