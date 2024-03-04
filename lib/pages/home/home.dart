import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:group_project/constants/upload_enums.dart';
import 'package:group_project/main.dart';
import 'package:group_project/pages/complete_workout/capture_image/upload_image_provider.dart';
import 'package:group_project/pages/home/components/current_user_post.dart';
import 'package:group_project/pages/home/components/display_image_stack.dart';
import 'package:group_project/constants/themes/app_colours.dart';
import 'package:group_project/pages/home/components/display_post_image_screen.dart';
import 'package:group_project/pages/home/components/friends_post.dart';
import 'package:group_project/services/firebase/firebase_friends_post.dart';
import 'package:group_project/services/firebase/firebase_posts_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late bool? showCursor;
  String caption = '';
  int _current = 0;
  late Stream<List<FriendPostPair>> friendsPostStream;
  FirebaseFriendsPost firebaseFriendsPost = FirebaseFriendsPost();

  late List<Map<String, dynamic>> imageList;

  @override
  void initState() {
    super.initState();

    imageList = objectBox.postService
        .getActivePosts()
        .asMap()
        .entries
        .map((entry) {
      final item = entry.value;
      return {
        'firstImageUrl': item.firstImageUrl,
        'secondImageUrl': item.secondImageUrl,
        'postId': item.id,
        'workoutSessionId': item.workoutSession.targetId,
      };
    }).toList();

    fetchFriendsPosts();

    fetchCaption(imageList.isNotEmpty
        ? imageList[_current]['workoutSessionId']
        : 0); // Adjusted for index out of range
    context.read<UploadImageProvider>().getSharedPreferences();
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getBool(UploadEnums.isUploading) == true) {
        context.read<UploadImageProvider>().setUploadError(true);
        context.read<UploadImageProvider>().setIsUploading(false);
      }
    });
  }

  Future<bool> firebasePostsNotEmpty() async {
    try {
      // Call the method from FirebasePostsService to check if Firebase has posts
      final hasPosts = await FirebasePostsService().firebasePostsNotEmpty();
      return hasPosts;
    } catch (e) {
      // Handle any errors here
      return false;
    }
  }

  void fetchFriendsPosts() async {
    FirebaseFriendsPost().initFriendsPostStream().then((stream) {
      setState(() {
        friendsPostStream = stream;
      });
    });
  }

  void fetchCaption(int workoutSessionId) async {
    String fetchedCaption =
    await FirebasePostsService.getCaption(workoutSessionId);
    setState(() {
      caption = fetchedCaption;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UploadImageProvider uploadImageProvider =
    context.watch<UploadImageProvider>();
    bool hasImages = imageList.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColours.primary,
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                const SizedBox(height: 5),
                if (hasImages) const SizedBox(height: 1),
                // Display CarouselSlider if imageList is not empty
                if (hasImages)
                  CarouselSlider.builder(
                    itemCount: imageList.length,
                    options: CarouselOptions(
                      aspectRatio: 0.9,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      enlargeFactor: 0.2,
                      viewportFraction: 0.45,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                          fetchCaption(
                              imageList[index]['workoutSessionId']);
                        });
                      },
                    ),
                    itemBuilder: (context, index, realIndex) {
                      final firstImage =
                      imageList[index]['firstImageUrl']!;
                      final secondImage =
                      imageList[index]['secondImageUrl']!;
                      final postId = imageList[index]['postId']!;
                      final workoutSessionId =
                      imageList[index]['workoutSessionId']!;
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 5),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius:
                              const BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              child: DisplayImageStack(
                                firstImageUrl: firstImage,
                                secondImageUrl: secondImage,
                                index: index,
                                current: _current,
                                postId: postId,
                                workoutSessionId:
                                workoutSessionId,
                              ),
                            ),
                            uploadImageProvider.uploadError
                                ? const Text(
                              'There was an error uploading your workout. Please try again.',
                              style: TextStyle(
                                  color: Colors.red),
                              textAlign: TextAlign.center,
                            )
                                : Container(
                              width: 100,
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 1,
                                  vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                    color: Colors.transparent),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: TextField(
                                showCursor: false,
                                textAlign:
                                TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white),
                                enableInteractiveSelection:
                                false,
                                decoration:
                                const InputDecoration(
                                  alignLabelWithHint: true,
                                  hintText: 'Add a caption..',
                                  hintStyle: TextStyle(
                                      color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding:
                                  EdgeInsets.only(
                                      left: 16),
                                ),
                                onChanged: (caption) {
                                  FirebasePostsService
                                      .saveCaption(
                                      workoutSessionId,
                                      caption);
                                },
                                controller:
                                TextEditingController(
                                    text: caption),
                              ),
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin:
                                  const EdgeInsets.all(5),
                                  padding:
                                  const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.grey),
                                  ),
                                  child: const Icon(Icons.favorite,
                                      color: Colors.grey),
                                ),
                                Container(
                                  margin:
                                  const EdgeInsets.all(5),
                                  padding:
                                  const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.grey),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DisplayPostImageScreen(
                                                imagePath: imageList[index]['firstImageUrl'],
                                                imagePath2: imageList[index]['secondImageUrl'],
                                                workoutSessionId: imageList[index]['workoutSessionId'],
                                              ),
                                        ),
                                      );
                                    },
                                    child: const Icon(Icons.comment,
                                        color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  )
                else
                // Adding Current User's Post conditionally
                FutureBuilder<bool>(
                  future: firebasePostsNotEmpty(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Return a loading indicator if the future is not resolved yet
                      return CircularProgressIndicator();
                    } else {
                      // If the future is resolved, check if Firebase has posts
                      if (snapshot.hasData && snapshot.data!) {
                        // If Firebase has posts, display the CurrentUserPost widget
                        return CurrentUserPost();
                      } else {
                        // If Firebase does not have posts, display the "Start a Workout" UI
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                //TODO TO GO TO START NEW WORKOUT PAGE
                              },
                              child: Container(
                                height: 200,
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  // Add gray border
                                  borderRadius: BorderRadius.circular(8), // Optional: Add border radius
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            // Add space between the icon and the text
                            Text(
                              'Start a Workout & Add a post!',
                              style: TextStyle(
                                fontFamily: 'Dancing Script',
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                          ],
                        );
                      }
                    }
                  },
                ),
                // Adding Friends' Posts Carousel
                const FriendsPostCarousel(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
