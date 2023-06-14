import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../bluetooth/bluetooth_message_handler.dart';
import 'actuator/actuator.dart';
import 'bluetooth/bluetooth_manager.dart';
import 'color_manager.dart';
import 'string_consts.dart';

class AssetManager {
  static Image loading = const Image(
      image: AssetImage("assets/loading.gif"),
      filterQuality: FilterQuality.high,
      width: 256,
      height: 256);
  static Image actuatorImage = const Image(
      image: AssetImage("assets/angle_ring.png"),
      filterQuality: FilterQuality.high);
  static Image logo =
  const Image(image: AssetImage("assets/logo.png"), width: 40, height: 40);
  static String hexFileName = "assets/actuator_hexs/actuator_hex.txt";
  static Image locked = const Image(
      image: AssetImage("assets/locked.png"), width: 40, height: 40);

  // Load files
  static Future<String> loadAsset(String assetName) async {
    return await rootBundle.loadString(assetName);
  }

  static Future<String> getActuatorHex() async {
    return await rootBundle.loadString(AssetManager.hexFileName);
  }
}

class Vec2{
  double x, y;

  Vec2(this.x, this.y);

  get offset => Offset(x, y);

  static double degreesToRadians(double angle) => angle * (pi / 180);

  void rotateAroundAPoint(
      double angle, double distanceToRotPoint, Vec2 pointOfRot) {
    angle = degreesToRadians(angle);
    // transform angle so that 0 degrees points up
    angle += (45 * (pi / 180));
    angle *= -1;

    x = distanceToRotPoint * cos(angle) +
        distanceToRotPoint * sin(angle) +
        pointOfRot.x;
    y = -distanceToRotPoint * sin(angle) +
        distanceToRotPoint * cos(angle) +
        pointOfRot.y;
  }
}

double lineThickness = 5;

class _CirclePainter extends CustomPainter {
  double radius;
  double thickness;
  Color color;
  bool filled;

  _CirclePainter(
      {required this.radius, required this.color, this.thickness = 2, this.filled=false});

  @override
  void paint(Canvas canvas, Size size) {
    var outerPaint = Paint()
      ..color = color
      ..strokeWidth = lineThickness;

    Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, outerPaint);

    if (!filled) {
      var innerPaint = Paint()
        ..color = ColorManager.angleRingBackground
        ..strokeWidth = lineThickness;

      canvas.drawCircle(center, radius - thickness, innerPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class _LinePainter extends CustomPainter {
  Color color;

  late Vec2 startPos;
  late Vec2 endPos;
  late double radius;
  late double lineThickness;
  double length;

  late double angle;

  _LinePainter(
      {required this.color,
      required this.radius,
      required this.angle,
      required this.lineThickness,
      this.length = 8});

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;

    startPos = Vec2(-radius + width + length, (height - 50) / 2);
    endPos = Vec2(-radius + width, 0);

    startPos.rotateAroundAPoint(angle, startPos.x + lineThickness / 2, Vec2(width / 2, height / 2));
    // to account for extra length added by the rounded corners of the line
    endPos.rotateAroundAPoint(angle, endPos.x + lineThickness / 2, Vec2(width / 2, height / 2));

    Paint paint = Paint()
      ..color = color
      ..strokeWidth = lineThickness
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(startPos.offset, endPos.offset, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _ArcPainter extends CustomPainter {
    Color color;

  late Rect rect;
  late double radius;

  late double angle;

  _ArcPainter(
      {required this.color,
      required this.radius,
      required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    double lineThickness = 5;
    double width = size.width;
    double height = size.height;

    rect = Rect.fromCenter(center: Offset(width / 2, height / 2), width: width - lineThickness / 2, height: height - lineThickness / 2);

    Paint paint = Paint()
      ..color = color
      ..strokeWidth = lineThickness
      ..strokeCap = StrokeCap.round;

    double closedAngle = (Actuator.connectedActuator.settings.closedAngle % 360) - 90;
    double firstAngle = closedAngle;
    double secondAngle =  angle;

    canvas.drawArc(rect, Vec2.degreesToRadians(firstAngle), Vec2.degreesToRadians(secondAngle), true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ActuatorIndicator extends StatefulWidget {
  const ActuatorIndicator({Key? key, required this.radius}) : super(key: key);

  final double radius;

  @override
  State<ActuatorIndicator> createState() => _ActuatorIndicatorState();
}

class _ActuatorIndicatorState extends State<ActuatorIndicator> {
  late double radius;

  late _CirclePainter angleRing;
  late _LinePainter open;
  late _LinePainter closed;
  late _LinePainter angleLine;
  late _ArcPainter angleArc;

  @override
  void initState() {
    super.initState();

    radius = widget.radius;
  }

  Timer? t;

  List<int> previousAngles = [];

  int averageAngle() {
    int angle = 0;
    for (int a in previousAngles) {
      angle = max(angle, a);
    }

    return angle;
  }

  @override
  void dispose() {
    super.dispose();
    t?.cancel();
  }

  BluetoothMessageHandler bluetoothMessageHandler = BluetoothMessageHandler();

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      bluetoothMessageHandler.requestAngle();
      setState(() {});
    });

    int actualAngle =
        Actuator.connectedActuator.settings.angle.truncate() % 360;

    // reduce jumpiness in angle values
    previousAngles.add(actualAngle);
    if (previousAngles.length > 3) {
      previousAngles.removeAt(0);
    }

    int angle = (averageAngle());

    angleRing =
        _CirclePainter(radius: radius, color: ColorManager.angleRingColor);
    open = _LinePainter(
        color: ColorManager.open,
        radius: radius,
        angle: Actuator.connectedActuator.settings.openAngle % 360,
        lineThickness: 5);
    closed = _LinePainter(
        color: ColorManager.close,
        radius: radius,
        angle: Actuator.connectedActuator.settings.closedAngle % 360,
        lineThickness: 5);
    angleLine = _LinePainter(
        color: ColorManager.angleLineColor,
        radius: radius,
        angle: angle.truncateToDouble(),
        lineThickness: 3,
        length: radius / 1.45);
    angleArc = _ArcPainter(
        color: ColorManager.angleRingColor,
        radius: radius,
        angle: angle.toDouble()
    );

    return CustomPaint(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: Stack(
          children: [
            Center(
                child: CustomPaint(
                    child: CustomPaint(
                        size: Size(radius * 2, radius * 2),
                        painter: angleRing))),
            // Center(
            //     child: CustomPaint(
            //         child: CustomPaint(
            //             size: Size(radius * 2, radius * 2), painter: angleArc))),
            Center(
                child: CustomPaint(
                    child: CustomPaint(
                        size: Size(radius / 3.4, 10), painter: angleLine))),
            Center(
                child: CustomPaint(
                    child: CustomPaint(
                        size: Size(radius / 3.4, 10), painter: closed))),
            Center(
                child: CustomPaint(
                    child:
                        CustomPaint(size: Size(radius / 3.4, 10), painter: open))),

            BluetoothManager.isActuatorConnected ? Container() : Center(heightFactor: 0, child: Text(style: const TextStyle(fontSize: 20), StringConsts.bluetooth.notConnected)),
            BluetoothManager.isActuatorConnected ? Container() : Center(child: CustomPaint(size: Size(radius * 2, radius * 2), painter: _CirclePainter(radius: radius + radius / 6, color: ColorManager.disabledRing, filled: true))),
          ],
        ),
      ),
    );
  }
}

class ActuatorConnectedIndicator extends StatefulWidget {
  const ActuatorConnectedIndicator({Key? key}) : super(key: key);

  @override
  State<ActuatorConnectedIndicator> createState() =>
      _ActuatorConnectedIndicatorState();
}

class _ActuatorConnectedIndicatorState
    extends State<ActuatorConnectedIndicator> {

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
        child: CustomPaint(
            size: const Size(50, 50),
            painter: _CirclePainter(radius: 10, color: Actuator.connectedDeviceAddress != null ? Colors.green : Colors.red, thickness: 5)));
  }
}

class ColorNotifier extends ChangeNotifier {
  Color color = Colors.red;

  void updateColor(Color newColor) {
    color = newColor;
    notifyListeners();
  }
}
