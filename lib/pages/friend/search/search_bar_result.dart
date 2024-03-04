import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_project/constants/themes/app_colours.dart';
import 'package:group_project/services/firebase/firebase_friends_service.dart';
import 'search_helper.dart';

class SearchBarResult extends StatefulWidget {
  final Map<String, dynamic> user;

  const SearchBarResult({super.key, required this.user});

  @override
  SearchBarResultState createState() => SearchBarResultState();
}

class SearchBarResultState extends State<SearchBarResult> {
  bool friendRequestSent = false;

  @override
  Widget build(BuildContext context) {
    bool isCurrentUserFriend = (widget.user['friends'] as List<dynamic>?)
            ?.contains(FirebaseAuth.instance.currentUser?.uid) ??
        false;

    return ListTile(
      leading: ImageDisplay.buildUserProfileImage(widget.user['photoUrl']),
      title: Text(
        widget.user['name'] ?? '',
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        widget.user['username'] ?? '',
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      trailing: FractionallySizedBox(
        widthFactor: 0.22,
        heightFactor: 0.6,
        child: isCurrentUserFriend
            ? Container()
            : ElevatedButton(
                onPressed: () {
                  if (!friendRequestSent && widget.user['UID'] != null) {
                    setState(() {
                      friendRequestSent = true;
                    });
                    FirebaseFriendsService.addFriend(widget.user['UID']);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: friendRequestSent
                      ? AppColours.secondaryLight
                      : AppColours.secondary,
                  padding: const EdgeInsets.all(8),
                  textStyle: const TextStyle(fontSize: 11),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: friendRequestSent
                      ? const Text(
                          'Requested',
                          key: Key('requestedText'),
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        )
                      : const Text(
                          'Add',
                          key: Key('addText'),
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
      ),
    );
  }
}
