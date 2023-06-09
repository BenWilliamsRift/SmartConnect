import 'dart:async';

import "package:http/http.dart" as http;

class WebController {
  static Uri loginURL =
      Uri.https("riftdev.co.uk", "/php/androidRetrievePasswords.php");

  Future<String> login(String username, String password) async {
    var response = await http
        .post(loginURL, body: {"username": username, "password": password});

    return response.body;
  }

  // Sync features for actuator
  Future<String> getFeaturePasswords() async {
    var url = Uri.https("riftdev.co.uk", "/passwords.html");
    var response = await http.post(url);

    return response.body;
  }
}
