import 'package:group_project/models/exercises_sets_info.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class WorkoutSession {
  @Id()
  int id;
  String title;
  String note;

  @Property(type: PropertyType.date)
  DateTime date = DateTime.now();

  bool isCurrentEditing;
  int duration;
  String imageUrl;

  // 1 workout session can have multiple exercises
  // each exercise can have multiple sets
  final exercisesSetsInfo = ToMany<ExercisesSetsInfo>();

  WorkoutSession({
    this.id = 0,
    this.title = 'Workout',
    this.note = '',
    required this.date,
    this.isCurrentEditing = false,
    this.duration = 0,
    this.imageUrl = '',
  });
}
