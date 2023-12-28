import 'package:flutter/material.dart';
import 'package:group_project/main.dart';

class TemplateMenuAnchor extends StatelessWidget {
  final int workoutTemplateId;

  const TemplateMenuAnchor({
    super.key,
    required this.workoutTemplateId,
  });

  void _deleteWorkoutTemplateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Delete workout template?',
            style: TextStyle(color: Color(0xFFE1F0CF)),
          ),
          content: const Text(
            'This action cannot be undone.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                        (states) => const Color(0xFF333333),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Colors.red,
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    onPressed: () {
                      objectBox.workoutTemplateService
                          .deleteWorkoutTemplate(workoutTemplateId);
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: MaterialStateColor.resolveWith(
          (states) => const Color(0xFF333333),
        ),
        surfaceTintColor: MaterialStateColor.resolveWith(
          (states) => const Color(0xFF333333),
        ),
      ),
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          icon: const Icon(
            Icons.more_vert,
            color: Color(0xFFE1F0CF),
          ),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
      menuChildren: List<MenuItemButton>.generate(2, (index) {
        switch (index) {
          case 0:
            return MenuItemButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                ),
                surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xFF333333)),
              ),
              child: const Text(
                'Edit',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              onPressed: () {
                // TODO edit workout template
              },
            );
          case 1:
            return MenuItemButton(
              style: ButtonStyle(
                surfaceTintColor: MaterialStateProperty.all(
                  Colors.transparent,
                ),
                backgroundColor: MaterialStateProperty.all(
                  const Color(0xFF333333),
                ),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                _deleteWorkoutTemplateDialog(context);
              },
            );
          default:
            throw Exception('Invalid menu item index');
        }
      }),
    );
  }
}
