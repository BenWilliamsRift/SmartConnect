import 'package:encrypt/encrypt.dart';

class EncrypterDecrypter {

  // Encryption key
  static const String rawKey = "charlieismyfavoritecatintheworld";

  late Encrypter encrypter;
  late IV iv;

  void getKey() {
    final Key key = Key.fromUtf8(rawKey);
    iv = IV.fromLength(16);
    encrypter = Encrypter(AES(key));
  }

  EncrypterDecrypter() {
    getKey();
  }

  String encrypt(String data) {
    return encrypter.encrypt(data, iv: iv).base64;
  }

  String decrypt(String data) {
    return encrypter.decrypt(Encrypted.fromBase64(data), iv: iv);
  }
}
