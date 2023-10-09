import 'dart:async';

import "package:http/http.dart" as http;

import 'String_consts.dart';

class WebController {
  static const String riftDevUrl = "riftdev.co.uk";
  static const String registerUrl = "https://www.riftdev.co.uk/register/";

  static String get featurePassword => "$riftDevUrl/passwords.html";

  static Uri loginURL =
      Uri.https(riftDevUrl, "/php/androidRetrievePasswords.php");
  static Uri featurePasswordsUrl = Uri.https(riftDevUrl, "/passwords.html");
  static Uri setGroupingUrl =
      Uri.https(riftDevUrl, "/php/checkAccessPassword.php");

  Future<String> login(String username, String password) async {
    var response = await http.post(loginURL, body: {
      "username": username,
      "password": password
    }).onError((error, stackTrace) {
      return Future.delayed(const Duration(milliseconds: 1), () {
        return http.Response(StringConsts.network.error, 400);
      });
      // return error
    });

    return response.body;
  }

  // Sync features for actuator
  Future<String> getFeaturePasswords() async {
    var response = await http.post(featurePasswordsUrl);

    return response.body;
  }

  Future<String> checkAccessCodeRequest(String password) async {
    var response =
    await http.post(setGroupingUrl, body: {"password": password});

    return response.body;
  }
}
