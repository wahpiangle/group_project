import 'package:flutter/material.dart';
import 'package:group_project/main.dart';
import 'package:group_project/models/exercise.dart';
import 'package:group_project/pages/components/crop_image.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Stream<List<Exercise>> streamExercises;

  @override
  void initState() {
    super.initState();
    streamExercises = objectBox.watchAllExercise();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
          stream: streamExercises,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: ClipPath(
                      clipper: MyClipperPath(),
                      child: Container(
                        height:500,
                        width: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: Image.asset(snapshot.data![index].imagePath).image,
                            fit: BoxFit.fill, //or whatever BoxFit you want
                          )
                        )
                      )
                    ),
                    title: Text(snapshot.data![index].name),
                    subtitle: Text(snapshot.data![index].bodyPart.target!.name),
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ));
  }
}
