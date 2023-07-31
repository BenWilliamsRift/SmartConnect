import 'package:actuatorapp2/bluetooth/bluetooth_manager.dart';
import 'package:test/test.dart';

void main() {
  BluetoothManager bluetoothManager = BluetoothManager(test: true);
  group("Converting Hex to Int", () {
    test("Hex: 20", () {
      int num = bluetoothManager.hexStringToInt("20");
      expect(num, 32);
    });

    test("Hex: 32", () {
      int num = bluetoothManager.hexStringToInt("32");
      expect(num, 50);
    });

    test("Hex: 00", () {
      int num = bluetoothManager.hexStringToInt("00");
      expect(num, 0);
    });
  });
}
