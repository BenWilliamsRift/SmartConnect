import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../actuator/actuator.dart';
import '../bluetooth/bluetooth_message_handler.dart';
import '../color_manager.dart';
import '../date_time.dart';
import '../settings.dart';
import '../string_consts.dart';

class Style {
  static double buttonHeight = 50;
  static double buttonWidth = 100;

  static num _padding = 6.0;
  static double padding = _padding.toDouble();
  static SizedBox sizedWidth = SizedBox(width: padding * 2);
  static SizedBox sizedHeight = SizedBox(height: padding * 2);
  static Color darkBlue = ColorManager.darkBlue;

  static const num _large = 22;
  static const num _normal = 18;
  static const num _small = 14;

  static TextStyle subtitle = TextStyle(
    fontSize: _small - 2,
    color: Settings.isDarkMode
        ? ColorManager.subtitleDark
        : ColorManager.subtitleLight,
  );

  static TextStyle largeText = TextStyle(
    fontSize: _large.toDouble(),
  );
  static TextStyle normalText = TextStyle(
    fontSize: _normal.toDouble(),
  );
  static TextStyle smallText = TextStyle(
    fontSize: _small.toDouble(),
  );
  static double borderRadius = 8.0;
  static ShapeBorder listTileShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(Style.borderRadius)),
      side: BorderSide(color: ColorManager.listTileBorder));

  static void update() {
    _padding = 4.0;
    padding = _padding.toDouble();
    sizedWidth = SizedBox(width: padding * 2);
    sizedHeight = SizedBox(height: padding * 2);

    subtitle = TextStyle(
      fontSize: _small - 2,
      color: Settings.isDarkMode
          ? ColorManager.subtitleDark
          : ColorManager.subtitleLight,
    );

    largeText = TextStyle(
      fontSize: _large.toDouble(),
    );
    normalText = TextStyle(
      fontSize: _normal.toDouble(),
    );
    smallText = TextStyle(
      fontSize: _small.toDouble(),
    );
    borderRadius = 8.0;
    listTileShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Style.borderRadius)),
        side: BorderSide(color: ColorManager.listTileBorder));
  }
}

String getTitle() {
  if (Actuator.connectedActuator.boardNumber == null) {
    return StringConsts.actuators.noConnectedActuator;
  }

  return StringConsts.actuators.title +
      Actuator.connectedActuator.boardNumber.toString();
}

class SwitchTile extends StatefulWidget {
  final bool initValue;
  final Function(bool value)? callback;
  final Function()? setValue;
  final Text title;
  final Text? subtitle;
  final bool visible;
  final bool touchInputDisabled;

  const SwitchTile(
      {Key? key,
      required this.initValue,
      required this.callback,
      this.setValue,
      required this.title,
      this.subtitle,
      this.visible = true,
      this.touchInputDisabled = false})
      : super(key: key);

  @override
  State<SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<SwitchTile> {
  late bool value;
  Function(bool value)? callback;
  late Text title;
  late Text? subtitle;
  late bool visible;
  late bool touchInputDisabled;
  Function()? setValue;

  bool waitingForResponse = false;

  @override
  void initState() {
    super.initState();
    value = widget.initValue;
  }

  @override
  Widget build(BuildContext context) {
    callback = widget.callback;
    title = widget.title;
    subtitle = widget.subtitle;
    visible = widget.visible;
    touchInputDisabled = widget.touchInputDisabled;
    setValue = widget.setValue;

    if (setValue != null) {
      value = setValue!() ?? value;
    }

    return visible
        ? Card(
            margin: EdgeInsets.all(Style.padding),
            child: ListTile(
              title: title,
              subtitle: subtitle,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  waitingForResponse
                      ? const CircularProgressIndicator()
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Switch(
                      value: value,
                      onChanged: (bool value) {
                        if (touchInputDisabled) {
                          setState(() {});
                          return;
                        } else {
                          setState(() {
                            this.value = value;
                            // TODO waitingForResponse = true;
                            // run a custom callback if needed
                            if (callback != null) {
                              callback?.call(value);
                            }
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ))
        : Container();
  }
}

class TextTile extends StatefulWidget {
  final Text text;
  final Text title;
  final Text? subtitle;
  final bool compact;
  final Function()? update;

  const TextTile(
      {Key? key,
      required this.text,
      required this.title,
      this.subtitle,
      this.compact = false,
      this.update})
      : super(key: key);

  @override
  State<TextTile> createState() => _TextTileState();
}

class _TextTileState extends State<TextTile> {
  late Text text;
  late Text title;
  late Text? subtitle;
  late bool compact;
  late Function() update;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    if (timer == null) {
      // update the value of text
      update = widget.update ?? () {};
      timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        update.call();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    timer?.cancel();
    timer = null;
  }

  @override
  Widget build(BuildContext context) {
    text = widget.text;
    title = widget.title;
    subtitle = widget.subtitle;
    compact = widget.compact;

    return !compact
        ? Card(
            margin: EdgeInsets.all(Style.padding),
            child: ListTile(title: title, subtitle: subtitle, trailing: text))
        : SizedBox(
            height: 30,
            child: ListTile(
                title: title,
                trailing: text,
                visualDensity: VisualDensity.compact,
                dense: true));
  }
}

class DropDownTile extends StatefulWidget {
  final List<String> items;
  final String value;
  final Function(String? value) onChanged;
  final Text title;
  final Text? subtitle;

  const DropDownTile(
      {Key? key,
      required this.items,
      required this.value,
      required this.onChanged,
      required this.title,
      this.subtitle})
      : super(key: key);

  @override
  State<DropDownTile> createState() => _DropDownTile();
}

class _DropDownTile extends State<DropDownTile> {
  late List<String> items;
  late String value;
  late Function(String? value) onChanged;
  late Text title;
  late Text? subtitle;

  @override
  Widget build(BuildContext context) {
    items = widget.items;
    value = widget.value;
    onChanged = widget.onChanged;
    title = widget.title;
    subtitle = widget.subtitle;

    return Card(
        margin: EdgeInsets.all(Style.padding),
        child: ListTile(
            title: title,
            subtitle: subtitle,
            trailing: DropdownButton<String>(
                value: value,
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    this.value = onChanged.call(value!);
                  });
                })));
  }
}

class Button extends StatefulWidget {
  final ButtonStyle? style;
  final Color? backgroundColor;
  final Function() onPressed;
  final Widget child;

  const Button(
      {Key? key,
      this.style,
      this.backgroundColor,
      required this.onPressed,
      required this.child})
      : super(key: key);

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  late ButtonStyle style;
  late Color backgroundColor;
  late Function() onPressed;
  late Widget child;

  @override
  Widget build(BuildContext context) {
    style = widget.style ??
        ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith(
                (states) => Colors.transparent.withOpacity(0)),
            shadowColor: MaterialStateProperty.resolveWith(
                (states) => Colors.transparent.withOpacity(0)));
    backgroundColor =
        widget.backgroundColor ?? ColorManager.defaultButtonBackground;
    onPressed = widget.onPressed;
    child = widget.child;

    return SizedBox(
      width: Style.buttonWidth,
      height: Style.buttonHeight,
      child: Card(
        color: backgroundColor,
        child: ElevatedButton(
          onPressed: onPressed,
          style: style,
          child: child,
        ),
      ),
    );
  }
}

class IconButtonTile extends StatefulWidget {
  final Color? backgroundColor;
  final Icon icon;
  final Function() onPressed;
  final Function() onReleased;

  const IconButtonTile(
      {Key? key,
      this.backgroundColor,
      required this.icon,
      required this.onPressed,
      required this.onReleased})
      : super(key: key);

  @override
  State<IconButtonTile> createState() => _IconButtonTileState();
}

class _IconButtonTileState extends State<IconButtonTile> {
  late Color? backgroundColor;
  late Icon icon;
  late Function() onPressed;
  late Function() onReleased;

  @override
  Widget build(BuildContext context) {
    backgroundColor = widget.backgroundColor;
    icon = widget.icon;
    onPressed = widget.onPressed;
    onReleased = widget.onReleased;

    return Card(
        color: backgroundColor,
        child: HoldButton(
          onPressed: onPressed,
          onReleased: onReleased,
          backgroundColor: backgroundColor,
          buttonEnabled: false,
          child: IconButton(onPressed: () {}, icon: icon),
        ));
  }
}

class TextInputTile extends StatefulWidget {
  final Text title;
  final Text? subtitle;
  final String? initialValue;
  final TextInputType keyboardType;
  final Function(String? newValue) onSaved;
  final TextEditingController? controller;

  const TextInputTile(
      {Key? key,
      this.initialValue,
      required this.onSaved,
      required this.title,
      this.keyboardType = TextInputType.number,
      this.subtitle,
      this.controller})
      : super(key: key);

  @override
  State<TextInputTile> createState() => _TextInputTileState();
}

class _TextInputTileState extends State<TextInputTile> {
  late Text title;
  late Text? subtitle;
  // late String initialValue;
  late Function(String? newValue) onSaved;
  late TextEditingController controller;
  late TextInputType keyboardType;

  @override
  void initState() {
    super.initState();

    controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    onSaved = widget.onSaved;
    title = widget.title;
    subtitle = widget.subtitle;
    keyboardType = widget.keyboardType;

    return Card(
      child: ListTile(
          title: title,
          subtitle: subtitle,
          trailing: SizedBox(
              width: 100,
              child: Card(
                margin: EdgeInsets.all(Style.padding),
                child: TextField(
                    textAlign: TextAlign.center,
                    style: Style.normalText,
                    controller: controller,
                    keyboardType: keyboardType,
                    decoration: const InputDecoration(border: InputBorder.none),
                    onChanged: (value) {},
                    onSubmitted: (String? value) {
                      setState(() {
                        controller.text = value ?? controller.text;
                        onSaved.call(value);
                      });
                    }),
              ))),
    );
  }
}

class TimePickerRot extends StatefulWidget {
  final int value;
  final Function(int) callback;
  final int mini;
  final int maxi;
  final int sensitivity;
  final String text;

  const TimePickerRot(
      {Key? key,
      required this.value,
      required this.mini,
      required this.maxi,
      required this.text,
      required this.sensitivity,
      required this.callback})
      : super(key: key);

  @override
  State<TimePickerRot> createState() => _TimePickerRotState();
}

class _TimePickerRotState extends State<TimePickerRot> {
  double prevPos = 0;

  late Function(int) callback;

  late int value;
  late final TextEditingController controller;

  late int numMax;
  late int numMin;

  late String text;

  late int sensitivity;

  @override
  void initState() {
    super.initState();

    value = widget.value;
    callback = widget.callback;
    text = widget.text;
    numMin = widget.mini;
    numMax = widget.maxi;
    sensitivity = widget.sensitivity;
    controller = TextEditingController(text: value.toString());
  }

  @override
  void dispose() {
    super.dispose();

    controller.dispose();
  }

  int loopNum(int num) {
    if (num < numMin) {
      return numMax - 1;
    }
    if (num > numMax - 1) {
      return numMin;
    }
    return num;
  }

  void parseNum(int num) {
    value = min(numMax - 1, max(num, numMin));
    controller.text = value.toString();
    setState(() {});
    callback(value);
  }

  @override
  Widget build(BuildContext context) {
    SizedBox sizedBox = const SizedBox(height: 10);

    return GestureDetector(
      onVerticalDragStart: (details) {
        prevPos = details.localPosition.dy;
      },
      onVerticalDragUpdate: (details) {
        if (details.localPosition.dy > prevPos + sensitivity) {
          value -= 1;
          if (value < numMin) {
            value = numMax - 1;
          }
          value = max(value, numMin);
          prevPos = details.localPosition.dy;
        }
        if (details.localPosition.dy < prevPos - sensitivity) {
          value += 1;
          if (value >= numMax) {
            value = numMin;
          }
          value = min(value, numMax - 1);
          prevPos = details.localPosition.dy;
        }
        parseNum(value);
      },
      child: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(children: [
          sizedBox,
          Text(text, textAlign: TextAlign.center),
          sizedBox,
          ElevatedButton(
            onPressed: () {
              parseNum(loopNum(value - 1));
            },
            child: Text(loopNum(value - 1).toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: ColorManager.timePickerRotTextColor)),
          ),
          sizedBox,
          SizedBox(
            width: 20,
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.next,
              enableInteractiveSelection: false,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2)
              ],
              keyboardType: TextInputType.number,
              onChanged: (newValue) {
                parseNum(int.parse(newValue));
                controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length));
              },
              onSaved: (newValue) {
                parseNum(int.parse(newValue ?? value.toString()));
              },
            ),
          ),
          sizedBox,
          ElevatedButton(
            onPressed: () {
              parseNum(loopNum(value + 1));
            },
            child: Text(loopNum(value + 1).toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: ColorManager.timePickerRotTextColor)),
          ),
        ]),
      ),
    );
  }
}

class TimePicker extends StatefulWidget {
  const TimePicker({
    Key? key,
    required this.confirmAction,
    required this.startTime,
    this.monthsMax,
    this.monthsMin,
    this.weeksMax,
    this.weeksMin,
    this.daysMax,
    this.daysMin,
    this.hourMax,
    this.hourMin,
    this.minuteMax,
    this.minuteMin,
    this.secondMax,
    this.secondMin,
    this.sensitivity,
  }) : super(key: key);

  final void Function(Delay) confirmAction;
  final Delay startTime;

  final int? monthsMax;
  final int? monthsMin;
  final int? weeksMax;
  final int? weeksMin;
  final int? daysMax;
  final int? daysMin;
  final int? hourMax;
  final int? hourMin;
  final int? minuteMax;
  final int? minuteMin;
  final int? secondMax;
  final int? secondMin;

  final int? sensitivity;

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late Delay time;

  late int monthsMax;
  late int monthsMin;
  late int weeksMax;
  late int weeksMin;
  late int daysMax;
  late int daysMin;
  late int hourMax;
  late int hourMin;
  late int minuteMax;
  late int minuteMin;
  late int secondMax;
  late int secondMin;

  late int sensitivity;

  @override
  void initState() {
    super.initState();
    time = widget.startTime;

    monthsMax = widget.monthsMax ?? Actuator.monthsMax;
    monthsMin = widget.monthsMin ?? Actuator.monthsMin;
    weeksMax = widget.weeksMax ?? Actuator.weeksMax;
    weeksMin = widget.weeksMin ?? Actuator.weeksMin;
    daysMax = widget.daysMax ?? Actuator.daysMax;
    daysMin = widget.daysMin ?? Actuator.daysMin;

    hourMax = widget.hourMax ?? Actuator.hourMax;
    hourMin = widget.hourMin ?? Actuator.hourMin;
    minuteMax = widget.minuteMax ?? Actuator.minuteMax;
    minuteMin = widget.minuteMin ?? Actuator.minuteMin;
    secondMax = widget.secondMax ?? Actuator.secondMax;
    secondMin = widget.secondMin ?? Actuator.secondMin;
    // lower is more sensitive
    sensitivity = widget.sensitivity ?? Settings.scrollSensitivity;
  }

  late TimePickerRot monthRot = TimePickerRot(
      value: time.months,
      mini: monthsMin,
      maxi: monthsMax,
      text: StringConsts.months,
      callback: (int num) {
        time.months = num;
      },
      sensitivity: sensitivity);
  late TimePickerRot weekRot = TimePickerRot(
      value: time.weeks,
      mini: weeksMin,
      maxi: weeksMax,
      text: StringConsts.weeks,
      callback: (int num) {
        time.weeks = num;
      },
      sensitivity: sensitivity);
  late TimePickerRot dayRot = TimePickerRot(
      value: time.days,
      mini: daysMin,
      maxi: daysMax,
      text: StringConsts.days,
      callback: (int num) {
        time.days = num;
      },
      sensitivity: sensitivity);
  late TimePickerRot hourRot = TimePickerRot(
      value: time.hours,
      mini: hourMin,
      maxi: hourMax,
      text: StringConsts.hours,
      callback: (int num) {
        time.hours = num;
      },
      sensitivity: sensitivity);
  late TimePickerRot minuteRot = TimePickerRot(
      value: time.minutes,
      mini: minuteMin,
      maxi: minuteMax,
      text: StringConsts.minutes,
      callback: (int num) {
        time.minutes = num;
      },
      sensitivity: sensitivity);
  late TimePickerRot secondRot = TimePickerRot(
      value: time.seconds,
      mini: secondMin,
      maxi: secondMax,
      text: StringConsts.seconds,
      callback: (int num) {
        time.seconds = num;
      },
      sensitivity: sensitivity);

  @override
  Widget build(BuildContext context) {
    SizedBox sizedBox = const SizedBox(height: 10);

    return AlertDialog(
      title: const Text(StringConsts.timePickerTitle),
      content: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Row(children: [
                Expanded(flex: 2, child: sizedBox),
                monthRot,
                Expanded(flex: 2, child: sizedBox),
                weekRot,
                Expanded(flex: 2, child: sizedBox),
                dayRot,
                Expanded(flex: 2, child: sizedBox),
              ]),
              sizedBox,
              sizedBox,
              sizedBox,
              Row(children: [
                Expanded(flex: 2, child: sizedBox),
                hourRot,
                Expanded(flex: 2, child: sizedBox),
                minuteRot,
                Expanded(flex: 2, child: sizedBox),
                secondRot,
                Expanded(flex: 2, child: sizedBox),
              ]),
            ],
          )),
      actions: [
        TextButton(
          child: const Text(StringConsts.cancel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text(StringConsts.confirm),
          onPressed: () {
            widget.confirmAction(time);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class TimePickerTile extends StatefulWidget {
  final Text title;
  final Text timeText;
  final Delay time;
  final Function(Delay) callback;

  const TimePickerTile(
      {Key? key,
      required this.title,
      required this.timeText,
      required this.time,
      required this.callback})
      : super(key: key);

  @override
  State<TimePickerTile> createState() => _TimePickerTileState();
}

class _TimePickerTileState extends State<TimePickerTile> {
  late Text title;
  late Text timeText;
  late Delay time;
  late Function(Delay) callback;

  Future<void> _showTimePicker() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return TimePicker(
              startTime: time,
              confirmAction: (time) {
                setState(() {
                  time = Delay.copyFrom(time);
                  callback.call(time);
                });
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    title = widget.title;
    timeText = widget.timeText;
    time = widget.time;
    callback = widget.callback;

    return Card(
        margin: EdgeInsets.all(Style.padding),
        child: ListTile(
            title: title,
            trailing: Button(
                onPressed: () {
                  _showTimePicker();
                },
                child: timeText)));
  }
}

class HoldButton extends StatefulWidget {
  final Function() onPressed;
  final Function()? onDoubleTap;
  final Function() onReleased;
  final Widget child;
  final Color? backgroundColor;
  final bool buttonEnabled;

  const HoldButton(
      {Key? key,
      required this.onPressed,
      required this.onReleased,
      required this.child,
      required this.backgroundColor,
      this.buttonEnabled = true,
      this.onDoubleTap})
      : super(key: key);

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton> {
  late Function() onPressed;
  late Function() onReleased;
  late Function()? onDoubleTap;
  late Widget child;
  late Color? backgroundColor;
  late bool buttonEnabled;

  bool onTapUpCalled = false;

  @override
  Widget build(BuildContext context) {
    onPressed = widget.onPressed;
    onReleased = widget.onReleased;
    onDoubleTap = widget.onDoubleTap;
    child = widget.child;
    backgroundColor = widget.backgroundColor;
    buttonEnabled = widget.buttonEnabled;

    if (buttonEnabled) {
      child = Button(
          onPressed: () {}, backgroundColor: backgroundColor, child: child);
    }

    return GestureDetector(
        onTapDown: (details) {
          onPressed();
        },
        onDoubleTap: () {
          onDoubleTap!();
        },
        onTapUp: (details) {
          onTapUpCalled = true;
          onReleased();
        },
        onLongPressUp: () {
          if (onTapUpCalled) return;
          onReleased();
        },
        child: child);
  }
}

class AutoManualButton extends StatefulWidget {
  const AutoManualButton({Key? key}) : super(key: key);

  @override
  State<AutoManualButton> createState() => _AutoManualButtonState();
}

class _AutoManualButtonState extends State<AutoManualButton> {
  double radius = 4;
  double width = Style.buttonWidth;
  // ignore: unused_field
  double _animatedWidth = 0;
  Duration fastDuration = const Duration(milliseconds: 250);
  Duration slowDuration = const Duration(seconds: 1, milliseconds: 100);
  late Duration animationDuration;
  bool complete = false;

  @override
  void initState() {
    super.initState();
    animationDuration = slowDuration;
    bluetoothMessageHandler.requestAutoManual();
  }

  BluetoothMessageHandler bluetoothMessageHandler = BluetoothMessageHandler();

  void getWidth() {
    // todo fix width for auto manual button
    width = (MediaQuery.of(context).size.width - Style.padding) / 3;
  }

  void _cancel() {
    // Cancel request if auto manual hasn't been activated
    bluetoothMessageHandler.stopActuator();
    bluetoothMessageHandler.requestAutoManual();
    setState(() {});
  }

  // ignore: unused_element
  void _startAnimation(bool reversed) {
    if (reversed) {
      setState(() {
        _animatedWidth = 0;
      });
    } else {
      setState(() {
        _animatedWidth = width;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        bluetoothMessageHandler.requestAutoManual();
      });
    });

    return GestureDetector(
      onLongPress: () {
        setState(() {
          bluetoothMessageHandler.setAutoManual();
        });
      },
      onTapUp: (details) => _cancel(),
      onLongPressUp: () => _cancel(),
      child: Button(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (Actuator.connectedActuator.settings.autoManual == 1) {
            return ColorManager.companyYellow;
          } else {
            return ColorManager.blue25;
          }
        })),
        onPressed: () {},
        child: Center(
            child: Text(
          style: Style.normalText.copyWith(color: Colors.white),
          StringConsts.actuators.autoOrManual,
        )),
      ),
    );
  }
}

void confirmationMessage(
    {required BuildContext context,
    required String text,
    required Function yesAction,
    Function? noAction}) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(title: Text(text), actions: [
          TextButton(
            onPressed: () {
              if (noAction != null) {
                noAction();
              }
              Navigator.of(context).pop();
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              yesAction();
              Navigator.of(context).pop();
            },
            child: const Text("Yes"),
          ),
        ]);
      });
}
