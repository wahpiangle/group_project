import 'package:flutter/material.dart';
import 'package:group_project/constants/themes/app_colours.dart';
import 'package:group_project/pages/workout/components/timer/rest_time_picker.dart';
import 'package:group_project/pages/workout/components/timer/resttimer_details_dialog.dart';
import 'custom_timer_provider.dart';

class CustomTimerPickerDialog extends StatelessWidget {
  final CustomTimerProvider customTimerProvider;
  final void Function(BuildContext) showCustomTimerDetailsDialog;

  const CustomTimerPickerDialog({
    super.key,
    required this.customTimerProvider,
    required this.showCustomTimerDetailsDialog,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColours.primaryBright,
      surfaceTintColor: Colors.transparent,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const Spacer(),
              const Text(
                'Rest Timer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.help, color: Colors.white),
                onPressed: () {
                  showAboutRestTimerDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            height: 295,
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(150),
              border: Border.all(color: AppColours.secondary, width: 5),
            ),
            child: ClipOval(
              child: Container(
                color: AppColours.secondary,
                child: CustomTimerPicker(
                  customTimerProvider: customTimerProvider,
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          Container(
            height: 50,
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            child: ElevatedButton(
              onPressed: () {
                customTimerProvider.resetCustomTimer(
                  customTimerProvider.customTimerMinutes * 60 +
                      customTimerProvider.customTimerSeconds,
                  context,
                );
                Navigator.of(context).pop();
                showCustomTimerDetailsDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC1C1C1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'Start Rest Timer',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
