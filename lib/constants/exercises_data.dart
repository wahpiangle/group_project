import 'package:group_project/models/exercise.dart';

import 'bodypart_data.dart';
import 'category_data.dart';

Map<String, Map<String, String>> exerciseMap = {
  'Bench Press': {'Chest': 'Barbell'},
  'Incline Bench Press': {'Chest': 'Barbell'},
  'Decline Bench Press': {'Chest': 'Barbell'},
};

List<Exercise> generateExerciseData() {
  List<Exercise> exerciseData = [];
  exerciseMap.forEach((key, value) {
    Exercise exercise = Exercise(name: key);
    exercise.bodyPart.target = bodyPartData.firstWhere((element) {
      return element.name == value.keys.first;
    });
    exercise.category.target = categoryData.firstWhere((element) {
      return element.name == value.values.first;
    });
    exerciseData.add(exercise);
  });
  return exerciseData;
}
