import 'package:flutter/material.dart';

import '../settings.dart';

class TimePicker extends StatefulWidget {
  const TimePicker({Key? key}) : super(key: key);

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  TimeOfDay selectedTime = TimeOfDay.now();

  void _selectTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );

    if (timeOfDay != null && timeOfDay != selectedTime) {
      setState(() {
        selectedTime = timeOfDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _selectTime(context);
      },
      child: Text(
          "${Settings.twelveHourTime ? selectedTime.hour > 12 ? selectedTime.hour - 12 : selectedTime.hour : selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, "0")}${Settings.twelveHourTime ? selectedTime.hour > 12 ? ' PM' : ' AM' : ""}"),
    );
  }
}
