import 'package:flutter/material.dart';
import 'package:group_project/pages/home/components/reaction_button.dart';
import 'package:group_project/services/firebase/firebase_friends_post.dart';

class FriendsPostCarousel extends StatefulWidget {
  const FriendsPostCarousel({super.key});

  @override
  State<FriendsPostCarousel> createState() => _FriendsPostCarouselState();
}

class _FriendsPostCarouselState extends State<FriendsPostCarousel> {
  Stream<List<FriendPostPair>>? friendsPostStream;
  bool displayHoldInstruction = false;

  @override
  void initState() {
    super.initState();
    fetchFriendsPosts();
  }

  void fetchFriendsPosts() async {
    final firebaseFriendsPost = FirebaseFriendsPost();
    final stream = await firebaseFriendsPost.initFriendsPostStream();
    setState(() {
      friendsPostStream = stream;
    });
  }

  void showHoldInstruction() {
    setState(() {
      displayHoldInstruction = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        displayHoldInstruction = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return friendsPostStream != null
        ? StreamBuilder<List<FriendPostPair>>(
            stream: friendsPostStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final List<FriendPostPair> friendPostPairs = snapshot.data!;
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: friendPostPairs.length,
                  itemBuilder: (context, index) {
                    final friendPostPair = friendPostPairs[index];
                    final post = friendPostPair.post;
                    final friendName = friendPostPair.friendName;
                    return Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(8),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    // TODO: Use the friend's profile picture
                                    backgroundImage: AssetImage(
                                      'assets/icons/defaultimage.jpg',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    friendName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  //TODO: Handle the onPressed event
                                },
                                color: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  post.firstImageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 20,
                                left: 20,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    post.secondImageUrl,
                                    fit: BoxFit.cover,
                                    width: 100,
                                  ),
                                ),
                              ),
                              displayHoldInstruction
                                  ? Positioned.fill(
                                      child: Opacity(
                                        opacity: 0.5,
                                        child: Container(
                                          color: const Color(0xFF000000),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              displayHoldInstruction
                                  ? const Positioned.fill(
                                      child: Center(
                                        child: Text(
                                          'Hold the emoji button to react',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: Column(
                                  children: [
                                    const Icon(Icons.comment_sharp,
                                        color: Colors.white,
                                        size: 30,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            blurRadius: 10,
                                          ),
                                        ]),
                                    const SizedBox(height: 10),
                                    ReactionButton(
                                      post: post,
                                      showHoldInstruction: showHoldInstruction,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              post.caption,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}

//TODO make friends second post viewable when swipe to right
