import 'package:actuatorapp2/encrypter.dart';
import 'package:test/test.dart';

void main() {
  EncrypterDecrypter encrypterDecrypter = EncrypterDecrypter();
  const String testString = "TEST_STRING";
  const String testStringEncrypted = "y+XN3zCpYox/ie678gPC7A==";
  test("Encrypting Data", () {
    expect(encrypterDecrypter.encrypt(testString), testStringEncrypted);
  });
  test("Decrypting Data", () {
    expect(encrypterDecrypter.decrypt(testStringEncrypted), testString);
  });
}
