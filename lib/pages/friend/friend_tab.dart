import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:group_project/constants/themes/app_colours.dart';
import 'package:group_project/pages/friend/current_friend.dart';
import 'package:group_project/pages/friend/friend_request.dart';
import 'package:group_project/pages/friend/friend_suggestion.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key, required this.title});
  final String title;

  @override
  FriendPageState createState() => FriendPageState();
}

class FriendPageState extends State<FriendPage> with SingleTickerProviderStateMixin {
  late int currentPage;
  late TabController tabController;
  final List<Color> colors = [AppColours.secondaryDark, AppColours.secondaryDark, AppColours.secondaryDark];
  List<Contact> contacts = [];

  @override
  void initState() {
    currentPage = 0;
    tabController = TabController(length: 3, vsync: this);
    tabController.animation!.addListener(() {
      final value = tabController.animation!.value.round();
      if (value != currentPage && mounted) {
        changePage(value);
      }
    });
    super.initState();
    _checkAndRequestContactPermission();
  }

  Future<void> _checkAndRequestContactPermission() async {
    var status = await Permission.contacts.status;

    if (!status.isGranted) {
      await _requestContactsPermission();
    }
  }

  Future<void> _requestContactsPermission() async {
    var result = await Permission.contacts.request();
    if (result.isGranted) {
      await _getContacts();
    } else if (result.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Permission Required'),
            content: const Text('Contacts permission is required to use this feature. Please grant the permission in settings.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _getContacts() async {
    List<Contact> fetchedContacts = await FlutterContacts.getContacts(withProperties: true);

    if (mounted) {
      setState(() {
        contacts = fetchedContacts;
      });
    }
  }

  Future<void> _checkContactsPermissionAndFetch() async {
    var status = await Permission.contacts.status;
    if (status.isGranted) {
      await _getContacts();
    }
  }

  void changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _checkContactsPermissionAndFetch();

    final Color unselectedColor = colors[currentPage].computeLuminance() < 0.2 ? Colors.black : Colors.white;
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColours.primary,
        appBar: AppBar(
          title: const FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              "Friend",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 23,
              ),
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColours.primary,
          actions: [
            IconButton(
              icon: Theme(
                data: ThemeData(iconTheme: const IconThemeData(color: Colors.white)),
                child: const Icon(Icons.arrow_forward_ios),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: BottomBar(
          fit: StackFit.expand,
          icon: (width, height) => Center(
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: null,
              icon: Icon(
                Icons.arrow_upward_rounded,
                color: unselectedColor,
                size: width,
              ),
            ),
          ),
          borderRadius: BorderRadius.circular(500),
          duration: const Duration(seconds: 1),
          curve: Curves.decelerate,
          showIcon: true,
          width: MediaQuery.of(context).size.width * 0.8,
          barColor: colors[currentPage].computeLuminance() > 0.2 ? AppColours.primaryBright : Colors.white,
          start: 2,
          end: 0,
          offset: 10,
          barAlignment: Alignment.bottomCenter,
          iconHeight: 35,
          iconWidth: 35,
          reverse: false,
          hideOnScroll: false,
          scrollOpposite: false,
          onBottomBarHidden: () {},
          onBottomBarShown: () {},
          body: (context, controller) => TabBarView(
            controller: tabController,
            dragStartBehavior: DragStartBehavior.down,
            physics: const BouncingScrollPhysics(),
            children: [
              FriendSuggestionsTab(contacts: contacts),
              const CurrentFriendsTab(),
              const FriendRequestsTab(),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomTab(
                text: "Suggestions",
                color: currentPage == 0 ? colors[0] : unselectedColor,
                onTap: () {
                  tabController.animateTo(0);
                },
              ),
              CustomTab(
                text: "Friends",
                color: currentPage == 1 ? colors[1] : unselectedColor,
                onTap: () {
                  tabController.animateTo(1);
                },
              ),
              CustomTab(
                text: "Requests",
                color: currentPage == 2 ? colors[2] : unselectedColor,
                onTap: () {
                  tabController.animateTo(2);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTab extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const CustomTab({super.key, required this.text, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 40,
        width: 100,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
