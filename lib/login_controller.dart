import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'actuator pages/connect.dart';
import 'encrypter.dart';
import 'actuator/actuator.dart';
import 'actuator/actuator_settings.dart';
import 'asset_manager.dart';
import 'bluetooth/bluetooth_manager.dart';
import 'color_manager.dart';
import 'main.dart';
import 'person_data.dart';
import 'preference_manager.dart';
import 'settings.dart';
import 'string_consts.dart';
import 'web_controller.dart';

class LoginController {
  static const username = "Username is incorrect";
  static const password = "Passwords is incorrect";
  static const usernamePassword = "Username or Password is in correct";
  static const network = "A network error occurred";
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    Key? key,
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.controller,
    required this.showLoading,
  }) : super(key: key);

  final Key? fieldKey;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldSetter<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool showLoading;
  final TextEditingController? controller;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofillHints: const [AutofillHints.password],
      key: widget.fieldKey,
      restorationId: 'password_text_field',
      obscureText: _obscureText,
      // maxLength: 16,
      keyboardType:
          widget.showLoading ? TextInputType.none : TextInputType.text,
      controller: widget.controller,
      onSaved: widget.onSaved,
      onChanged: widget.onChanged,
      validator: widget.validator,
      // onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        filled: true,
        hintText: widget.hintText,
        labelText: widget.labelText,
        helperText: widget.helperText,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          hoverColor: ColorManager.passwordFieldHoverColor,
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            semanticLabel: _obscureText
                ? StringConsts.login.showPassword
                : StringConsts.login.hidePassword,
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with RestorationMixin {
  PersonData person = PersonData();

  final String riftDevUrl = "www.riftdev.co.uk";
  final String _registerUrl = "https://www.riftdev.co.uk/register/";
  late final String loginUrl;
  late final String featurePassword;

  List<Actuator> actuators = [];

  late TextEditingController emailController;
  late TextEditingController passwordController;

  _LoginPageState() {
    loginUrl = "$riftDevUrl/php/androidRetrievePasswords.php";
    featurePassword = "$riftDevUrl/passwords.html";
    emailController = TextEditingController();
    passwordController = TextEditingController();
    encrypterAndDecrypter = EncrypterDecrypter();
    signOut();
    PreferenceManager.loadSettingsPrefs();
  }

  int lastSentSerialisedSetting = 0;

  bool offlineMode = false;
  bool isLoggedIn = false;
  bool showLoading = false;

  void writeToLoginDetailsToPrefs() {
    if (Settings.saveLoginDetails) {
      PreferenceManager.writeString(
          "${PreferenceManager.loginPrefix}-${PreferenceManager.loginTimeSuffix}", DateTime.now().toString());
    }
  }

  Future<void> _registerAccount() async {
    if (!await launchUrl(Uri.parse(_registerUrl))) {
      // ignore: use_build_context_synchronously
      showSnackBar(
          context,
          StringConsts.login.failedToOpenRegisterPage,
          null,
          SnackBarAction(
              label: StringConsts.login.copyRegisterUrl,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: _registerUrl));
              }));
    }
  }

  void signIn(final String username, final String password) {
    logIn(username);
    saveUsernamePassword(username, password);

    if (error != null) {
      showSnackBar(context, error!, null, null);
    }
  }

  void clearUsernamePasswordLastLogin() {
    PreferenceManager.removeString("${PreferenceManager.loginPrefix}-${PreferenceManager.loginDetailsSuffix}");
  }

  void signOut() {
    if (isLoggedIn) {
      isLoggedIn = false;
      Actuator.connectedActuator.disconnect();

      clearUsernamePasswordLastLogin();
      routeToPage(context, const LoginPage(), removeStack: true);
    }
  }

  void saveUsernamePassword(String username, String password) async {
    String data = encrypterAndDecrypter.encrypt("$username|$password");

    PreferenceManager.writeString("${PreferenceManager.loginPrefix}-${PreferenceManager.loginDetailsSuffix}", data);
  }

  String? error;

  void getPasswords() async {
    Object? webResponse;

    WebController webController = WebController();

    webResponse = await webController.getFeaturePasswords();

    // ignore: unnecessary_null_comparison
    if (webResponse == null) {
      error = StringConsts.network.failedToUpdateFeaturePassword;
      return;
    }

    String passwords = webResponse.toString();

    passwords = passwords.replaceAll("<br>", "\n");

    // Write to file here
    BluetoothManager.passwords = passwords;

    // featurePasswordsIntoActuators(response.toString());
  }

  void updateFeaturePasswords() {
    getPasswords();

    // show connect screen
    showSnackBar(context, StringConsts.network.finishedSyncingData, null, null);

    routeToPage(context, const ConnectToActuatorPage());
  }

  void featurePasswordsIntoActuators(String passwords) {
    // Read passwords from file here
    // Then get board number after connection

    List<String> line = [];

    if (line.length < ActuatorConstants.numberOfFeatures) {
      return;
    }

    for (int i = 0; i < ActuatorConstants.numberOfFeatures; i++) {
      Actuator.connectedActuator.settings.setFeaturePassword(i, line[i + 1]);
    }
  }

  void logIn(String username) {
    showSnackBar(context, StringConsts.login.complete, null, null);
    Actuator.connectedActuator.disconnect();

    isLoggedIn = true;
    updateFeaturePasswords();
    routeToPage(context, const ConnectToActuatorPage());

    // hide loading spinner
    setState(() {
      showLoading = false;
    });
  }

  late FocusNode _password;

  @override
  dispose() {
    super.dispose();
    _password.dispose();
  }

  final RestorableInt _autoValidateMode = RestorableInt(AutovalidateMode.disabled.index);

  @override
  String? get restorationId => "login_form";

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_autoValidateMode, "autovalidate_mode");
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      GlobalKey<FormFieldState<String>>();

  Future<bool> validateUsername(String username, String password) {
    WebController webController = WebController();
    Future<String> response = webController.login(username, password);

    Future<bool> value = response.then((value) {
      Actuator.passwords = value.toString().replaceAll("<br>", "\n");

      // Save password to file for quick login next time
      PreferenceManager.writeString("${PreferenceManager.actuatorPrefix}-${PreferenceManager.passwordsSuffix}", Actuator.passwords);

      if (value != "0") {
        return true;
      } else {
        showSnackBar(context, StringConsts.network.failedToGetLoginData, null, null);
        return false;
      }
    });

    return value;
  }

  void _handleSubmitted() {
    final form = _formKey.currentState!;
    if (!form.validate()) {
      _autoValidateMode.value = AutovalidateMode.always.index;
      showSnackBar(context, StringConsts.login.formErrors, null, null);
    } else {
      form.save();

      // show loading spinner
      setState(() {
        showLoading = true;
      });

      // Delay for 10 secs
      Future.delayed(const Duration(seconds: 10), () {
        // Check if login was successful
        if (!isLoggedIn) {
          setState(() {
            // if not successful tell user
            if (showLoading) {
              showLoading = false;
              showSnackBar(
                  context,
                  StringConsts.login.usernameOrPasswordWrongOrNetworkError,
                  6,
                  null);
            }
          });
        }
      });
      Future<bool> validated =
          validateUsername(person.email, person.password);

      // Delay the login for 1.5 secs
      Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
        validated.then((value) {
          if (value == true) {
            showSnackBar(context, StringConsts.login.complete, null, null);
            PersonData.username = person.email;
            PersonData.currentEmail = person.email;

            signIn(person.email, person.password);
            // only call on manual logins
            writeToLoginDetailsToPrefs();
          } else {
            showSnackBar(context, StringConsts.login.usernameOrPasswordWrong,
                null, null);
          }
        }).onError((error, stackTrace) {
          if (kDebugMode) {
            print("VALIDATED ERROR: $error, stack: $stackTrace");
          }
        }).whenComplete(() {
          setState(() {
            showLoading = false;
          });
        });
      });
  }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return StringConsts.login.emailRequired;
    }
    if (!value.contains("@")) {
      return StringConsts.login.emailNotCorrect;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return StringConsts.login.passwordRequired;
    }

    return null;
  }

  late EncrypterDecrypter encrypterAndDecrypter;

  @override
  void initState() {
    super.initState();
    _password = FocusNode();
    PreferenceManager.loadSettingsPrefs();

    Future.delayed(const Duration(milliseconds: 10), () {setState(() {});});

    BluetoothManager.initBluetoothResponse();
  }

  bool detailsSet = false;

  void _getLastLoginDetails() {
    if (passwordController.text.isNotEmpty) {
      return;
    }
    if (Settings.saveLoginDetails) {
      String? loginDetails = PreferenceManager.getString("${PreferenceManager.loginPrefix}-${PreferenceManager.loginDetailsSuffix}");
      if (loginDetails != null) {
        Future.delayed(const Duration(milliseconds: 100), () {
          String details = encrypterAndDecrypter.decrypt(loginDetails);
          setState(() {
            emailController.text = details.split("|")[0];
            passwordController.text = details.split("|")[1];
            detailsSet = true;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!detailsSet) {
      _getLastLoginDetails();
      Future.delayed(const Duration(milliseconds: 200), () {setState(() {});});
    }

    const sizedBox = SizedBox(height: 24);

    return Scaffold(
      appBar: AppBar(
        title: const Text(StringConsts.appTitle),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                setState(() {
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) {return const SettingsPage(login: true);}));
                });
              })
        ],
      ),
      body: Stack(
        children: [
          Form(
              autovalidateMode:
                  AutovalidateMode.values[_autoValidateMode.value],
              key: _formKey,
              child: Scrollbar(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AutofillGroup(
                          child: Column(children: [
                        sizedBox,
                        TextFormField(
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          controller: emailController,
                          decoration: InputDecoration(
                            filled: true,
                            hintText: StringConsts.login.yourEmailAddress,
                            labelText: StringConsts.login.email,
                          ),
                          keyboardType: showLoading
                              ? TextInputType.none
                              : TextInputType.emailAddress,
                          onSaved: (value) {
                            person.email = value!;
                            _password.requestFocus();
                          },
                          validator: _validateEmail,
                        ),
                        sizedBox,
                        PasswordField(
                          showLoading: showLoading,
                          key: _passwordFieldKey,
                          controller: passwordController,
                          textInputAction: TextInputAction.next,
                          focusNode: _password,
                          labelText: StringConsts.login.password,
                          onSaved: (value) {
                            setState(() {
                              passwordController.text = value!;
                              person.password = value;
                            });
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                          validator: _validatePassword,
                        ),
                        sizedBox,
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _handleSubmitted();
                                primaryFocus?.unfocus();
                              });
                            },
                            child: Text(StringConsts.login.fieldSubmit),
                          ),
                        ),
                        sizedBox,
                        Center(
                            child: ElevatedButton(
                          onPressed: _registerAccount,
                          child: Text(StringConsts.login.registerAccount),
                        )),
                        sizedBox,
                      ]))))),
          showLoading ? Center(child: AssetManager.loading) : const Center()
        ],
      ),
      floatingActionButton: SizedBox(
        width: 400,
        child: Center(
          heightFactor: 0,
          child: Text(
            StringConsts.appVersionTitle + StringConsts.appVersion,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 12),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
