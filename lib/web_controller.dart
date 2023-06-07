import 'dart:async';

import "package:http/http.dart" as http;

class WebController {
  static Uri loginURL =
      Uri.https("riftdev.co.uk", "/php/androidRetrievePasswords.php");
  static Uri featurePasswordsUrl =
      Uri.https("riftdev.co.uk", "/passwords.html");
  static Uri setGroupingUrl =
      Uri.https("https://riftdev.co.uk", "/php/checkAccessPassword.php");

  Future<String> login(String username, String password) async {
    var response = await http
        .post(loginURL, body: {"username": username, "password": password});

    return response.body;
  }

  // Sync features for actuator
  Future<String> getFeaturePasswords() async {
    var response = await http.post(featurePasswordsUrl);

    return response.body;
  }

  Future<String> checkAccessCodeRequest(String password) async {
    var response =
        await http.post(featurePasswordsUrl, body: {"password": password});

    return response.body;
  }
}
