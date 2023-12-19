import 'package:flutter/material.dart';
import 'package:group_project/constants/themes/app_colours.dart';
import 'package:group_project/models/exercise.dart';
import 'package:group_project/pages/components/crop_image.dart';
import 'package:group_project/pages/exercise/components/exercises_list_filters.dart';

class ChooseExercise extends StatefulWidget {
  final List<Exercise> exercises;
  final List<dynamic> selectedExercises; //TODO
  final void Function(Exercise selectedExercise) selectExercise;

  const ChooseExercise({
    super.key,
    required this.exercises,
    required this.selectedExercises,
    required this.selectExercise,
  });

  @override
  _ChooseExerciseState createState() => _ChooseExerciseState();
}

class _ChooseExerciseState extends State<ChooseExercise> {
  List<Exercise> filteredExercises = [];
  bool isAnyExerciseSelected = false;
  List<String> selectedCategory = [];
  String selectedBodyPart = '';


  @override
  void initState() {
    super.initState();
    filteredExercises = widget.exercises;
  }

  void filterExercises(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredExercises = widget.exercises;
      } else {
        filteredExercises = widget.exercises
            .where((exercise) =>
                exercise.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }




  void setSelectedBodyPart(String bodyPart) {
    setState(() {
      selectedBodyPart = bodyPart;
    });
  }

  void addSelectedCategory(String category) {
    setState(() {
      selectedCategory.add(category);
    });
  }

  void removeSelectedCategory(String category) {
    setState(() {
      selectedCategory.remove(category);
    });
  }


  void submitSelectedExercise(Exercise selectedExercise) {
    if (selectedExercise.isSelected) {
      widget.selectExercise(selectedExercise);
    }
  }

  //change bool isSelected state
  void _selectExercise(Exercise selectedExercise) {
    setState(() {
      selectedExercise.isSelected = !selectedExercise.isSelected;
      checkSelectionStatus();
    });
  }

  // called after pressing FAB
  void deselectAllExercises() {
    for (var exercise in widget.exercises) {
      exercise.isSelected = false;
    }
  }

  //check if an exercise is selected
  void checkSelectionStatus() {
    setState(() {
      isAnyExerciseSelected = widget.exercises.any((exercise) => exercise.isSelected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
            "Choose Exercises",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          )
        ),
        backgroundColor:  AppColours.primary,
      ),
      body: Container(
        color: const Color(0xFF1A1A1A),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              ExercisesListFilters(
                  filterExercises: filterExercises,
                  selectedBodyPart: selectedBodyPart,
                  setSelectedBodyPart: setSelectedBodyPart,
                  selectedCategory: selectedCategory,
                  addSelectedCategory: addSelectedCategory,
                  removeSelectedCategory: removeSelectedCategory
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    return Material(
                      color: const Color(0xFF1A1A1A),
                      child: InkWell(
                        onTap: () {
                          _selectExercise(exercise);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            tileColor: exercise.isSelected ? Colors.grey[800] : null,
                            horizontalTitleGap: -10,
                            leading: SizedBox(
                              height: 100,
                              width: 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(300.0),
                                child: exercise.imagePath == ''
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE1F0CF),
                                          borderRadius:
                                              BorderRadius.circular(300.0),
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
                                            image: Image.asset(exercise.imagePath)
                                                .image,
                                            fit: BoxFit
                                                .contain, //or whatever BoxFit you want
                                          )),
                                        ),
                                      ),
                              ),
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                exercise.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                ),
                              ),
                            ),
                            subtitle: Text(
                              exercise.bodyPart.target!.name,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isAnyExerciseSelected
          ? FloatingActionButton(
        onPressed: () {
          for (final exercise in widget.exercises) {
            submitSelectedExercise(exercise);
          }
          deselectAllExercises();
          Navigator.pop(context);
        },
        backgroundColor: AppColours.secondary,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
