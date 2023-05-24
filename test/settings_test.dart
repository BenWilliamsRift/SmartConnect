import 'package:actuatorapp2/settings.dart';
import 'package:test/test.dart';

void main() {
  group("Temperature Conversion", () {
    group("Converting from fahrenheit to celcius", () {
      test("0F", () {
        Settings.selectedTemperatureUnits = Settings.celsius;
        int result = Settings.convertTemperatureUnits(
            temp: 0, source: Settings.fahrenheit);

        expect(result, -18);
      });

      test("100F", () {
        Settings.selectedTemperatureUnits = Settings.celsius;
        int result = Settings.convertTemperatureUnits(
            temp: 100, source: Settings.fahrenheit);

        expect(result, 38);
      });
    });

    group("Converting from celcius to fahrenheit", () {
      test("Converting from celcius to fahrenheit", () {
        Settings.selectedTemperatureUnits = Settings.fahrenheit;
        int result =
            Settings.convertTemperatureUnits(temp: 0, source: Settings.celsius);

        expect(result, 32);
      });

      test("Converting from celcius to fahrenheit", () {
        Settings.selectedTemperatureUnits = Settings.fahrenheit;
        int result = Settings.convertTemperatureUnits(
            temp: 100, source: Settings.celsius);

        expect(result, 212);
      });
    });
  });

  group("Torque Conversion", () {
    group("Converting from Newton metres to foot pounds", () {
      test("100Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: 100,
                source: Settings.newtonMeter,
                wanted: Settings.footPound),
            73.75);
      });
      test("1000Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: 1000,
                source: Settings.newtonMeter,
                wanted: Settings.footPound),
            737.46);
      });
      test("-100Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: -100,
                source: Settings.newtonMeter,
                wanted: Settings.footPound),
            -73.75);
      });
    });
    group("Converting from Newton metres to inch pounds", () {
      test("100Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: 100,
                source: Settings.newtonMeter,
                wanted: Settings.inchPound),
            885.1);
      });
      test("1000Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: 1000,
                source: Settings.newtonMeter,
                wanted: Settings.inchPound),
            8851.0);
      });
      test("-100Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: -100,
                source: Settings.newtonMeter,
                wanted: Settings.inchPound),
            -885.1);
      });
    });

    group("Converting from foot pounds to Newton metres", () {
      test("100Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: 100,
                source: Settings.footPound,
                wanted: Settings.newtonMeter),
            135.58);
      });
      test("1000Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: 1000,
                source: Settings.footPound,
                wanted: Settings.newtonMeter),
            1355.82);
      });
      test("-100Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: -100,
                source: Settings.footPound,
                wanted: Settings.newtonMeter),
            -135.58);
      });
    });
    group("Converting from foot pounds to inch pounds", () {
      test("100Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: 100,
                source: Settings.footPound,
                wanted: Settings.inchPound),
            1200);
      });
      test("1000Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: 1000,
                source: Settings.footPound,
                wanted: Settings.inchPound),
            12000);
      });
      test("-100Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: -100,
                source: Settings.footPound,
                wanted: Settings.inchPound),
            -1200);
      });
    });

    group("Converting from inch pounds to Newton metres", () {
      test("100Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: 100,
                source: Settings.inchPound,
                wanted: Settings.newtonMeter),
            11.30);
      });
      test("1000Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: 1000,
                source: Settings.inchPound,
                wanted: Settings.newtonMeter),
            112.98);
      });
      test("-100Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: -100,
                source: Settings.inchPound,
                wanted: Settings.newtonMeter),
            -11.3);
      });
    });
    group("Converting from inch pounds to foot pounds", () {
      test("100Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: 100,
                source: Settings.inchPound,
                wanted: Settings.footPound),
            8.33);
      });
      test("1000Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: 1000,
                source: Settings.inchPound,
                wanted: Settings.footPound),
            83.33);
      });
      test("-100Nm", () {
        expect(
            Settings.convertTorqueUnits(
                torque: -100,
                source: Settings.inchPound,
                wanted: Settings.footPound),
            -8.33);
      });
    });
  });
}
